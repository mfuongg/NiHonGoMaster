import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../services/feedback_audio_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

enum _NotebookQuizDirection {
  japaneseToVietnamese,
  vietnameseToJapanese,
}

class NotebookQuizScreen extends StatefulWidget {
  final List<VocabularyWord> words;
  final String title;
  final String levelLabel;

  const NotebookQuizScreen({
    super.key,
    required this.words,
    this.title = 'Quiz sổ tay từ vựng',
    this.levelLabel = 'Sổ tay',
  });

  @override
  State<NotebookQuizScreen> createState() => _NotebookQuizScreenState();
}

class _NotebookQuizScreenState extends State<NotebookQuizScreen> {
  List<VocabularyWord> _quizWords = [];
  List<VocabularyWord> _optionWords = [];
  int _correctWordIndex = 0;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  _NotebookQuizDirection _direction = _NotebookQuizDirection.japaneseToVietnamese;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  void _startQuiz() {
    final shuffled = [...widget.words]..shuffle();
    setState(() {
      _quizWords = shuffled.length > 20 ? shuffled.sublist(0, 20) : shuffled;
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _score = 0;
    });
    _generateOptions();
  }

  void _generateOptions() {
    if (_quizWords.isEmpty || _currentIndex >= _quizWords.length) return;

    final correctWord = _quizWords[_currentIndex];
    final wrongWords = List<VocabularyWord>.from(widget.words)
      ..removeWhere((word) => word.id == correctWord.id)
      ..shuffle();

    final options = [correctWord, ...wrongWords.take(3)]..shuffle();

    setState(() {
      _selectedAnswer = null;
      _answered = false;
      _optionWords = options;
      _correctWordIndex = options.indexWhere((word) => word.id == correctWord.id);
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    final isCorrect = index == _correctWordIndex;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (isCorrect) {
        _score++;
        context.read<ProgressProvider>().addXP(AppConstants.xpVocabQuiz);
      }
    });

    if (isCorrect) {
      FeedbackAudioService.instance.playCorrect();
    } else {
      FeedbackAudioService.instance.playWrong();
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _quizWords.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _generateOptions();
    } else {
      _showResult();
    }
  }

  void _switchDirection(_NotebookQuizDirection direction) {
    if (_direction == direction) return;
    setState(() {
      _direction = direction;
    });
    _startQuiz();
  }

  void _showResult() {
    final percent = _quizWords.isEmpty ? 0 : (_score / _quizWords.length * 100).toInt();
    context.read<ProgressProvider>().recordTestResult(
          _dominantLevel(_quizWords),
          _score,
          _quizWords.length,
          title: '${widget.title} • ${_direction == _NotebookQuizDirection.japaneseToVietnamese ? 'Nhật → Việt' : 'Việt → Nhật'}',
          mode: 'notebook_quiz',
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Kết quả quiz sổ tay', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              percent >= 80 ? '📚✨' : percent >= 60 ? '👍' : '💪',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 12),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: percent >= 60 ? AppTheme.successGreen : AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: 8),
            Text('$_score / ${_quizWords.length} câu đúng'),
            const SizedBox(height: 14),
            Text(
              percent >= 80
                  ? 'Bạn đang nhớ rất chắc các từ đã lưu trong sổ tay.'
                  : percent >= 60
                      ? 'Kết quả khá tốt. Hãy ôn lại vài từ khó rồi thử lại nhé.'
                      : 'Nên xem lại sổ tay và luyện thêm trước khi làm lại quiz.',
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Thoát'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startQuiz();
            },
            child: const Text('Làm lại'),
          ),
        ],
      ),
    );
  }

  String _dominantLevel(List<VocabularyWord> words) {
    if (words.isEmpty) return 'N5';
    final counts = <String, int>{};
    for (final word in words) {
      counts[word.jlptLevel] = (counts[word.jlptLevel] ?? 0) + 1;
    }

    var bestLevel = 'N5';
    var bestCount = 0;
    counts.forEach((level, count) {
      if (count > bestCount) {
        bestLevel = level;
        bestCount = count;
      }
    });
    return bestLevel;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.length < 4) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Cần ít nhất 4 từ trong sổ tay để tạo quiz. Hãy lưu thêm từ vựng rồi thử lại nhé.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_quizWords.isEmpty || _optionWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentWord = _quizWords[_currentIndex];
    final levelColor = AppTheme.jlptColor(_dominantLevel(_quizWords));
    final isJapaneseToVietnamese =
        _direction == _NotebookQuizDirection.japaneseToVietnamese;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _quizWords.length,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(levelColor),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _NotebookInfoChip(
                          icon: Icons.menu_book_rounded,
                          label: widget.levelLabel,
                          color: levelColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NotebookInfoChip(
                          icon: Icons.star_rounded,
                          label: 'Điểm $_score',
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _NotebookDirectionButton(
                            selected: isJapaneseToVietnamese,
                            label: 'Nhật → Việt',
                            onTap: () => _switchDirection(
                              _NotebookQuizDirection.japaneseToVietnamese,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _NotebookDirectionButton(
                            selected: !isJapaneseToVietnamese,
                            label: 'Việt → Nhật',
                            onTap: () => _switchDirection(
                              _NotebookQuizDirection.vietnameseToJapanese,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeIn(
                    key: ValueKey('${currentWord.id}_${_direction.name}'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [levelColor, levelColor.withOpacity(0.72)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: levelColor.withOpacity(0.24),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Câu ${_currentIndex + 1}/${_quizWords.length}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (isJapaneseToVietnamese) ...[
                            Text(
                              currentWord.japanese,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 54,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentWord.hiragana,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentWord.romaji,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ] else ...[
                            Text(
                              currentWord.vietnamese,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentWord.english,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isJapaneseToVietnamese
                                  ? 'Chọn nghĩa tiếng Việt đúng'
                                  : 'Chọn từ tiếng Nhật đúng',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _optionWords.length,
                      itemBuilder: (context, index) {
                        final option = _optionWords[index];
                        final isCorrect = index == _correctWordIndex;
                        final isSelected = index == _selectedAnswer;

                        Color bgColor = Colors.white;
                        Color borderColor = Colors.grey.shade200;
                        Color textColor = AppTheme.textDark;

                        if (_answered) {
                          if (isCorrect) {
                            bgColor = AppTheme.successGreen.withOpacity(0.10);
                            borderColor = AppTheme.successGreen;
                            textColor = AppTheme.successGreen;
                          } else if (isSelected) {
                            bgColor = AppTheme.errorRed.withOpacity(0.10);
                            borderColor = AppTheme.errorRed;
                            textColor = AppTheme.errorRed;
                          }
                        }

                        return GestureDetector(
                          onTap: () => _selectAnswer(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: borderColor, width: 1.6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: borderColor.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: isJapaneseToVietnamese
                                      ? Text(
                                          option.vietnamese,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              option.japanese,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${option.hiragana} • ${option.romaji}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: textColor.withOpacity(0.78),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                                if (_answered && isCorrect)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.successGreen,
                                  )
                                else if (_answered && isSelected)
                                  const Icon(
                                    Icons.cancel,
                                    color: AppTheme.errorRed,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_answered)
                    FadeInUp(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          child: Text(
                            _currentIndex < _quizWords.length - 1
                                ? 'Câu tiếp theo'
                                : 'Xem kết quả',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotebookDirectionButton extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _NotebookDirectionButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppTheme.textDark : AppTheme.textMedium,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotebookInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _NotebookInfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
