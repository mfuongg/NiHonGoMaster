import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../services/feedback_audio_service.dart';
import '../../providers/progress_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

enum _QuizDirection {
  japaneseToVietnamese,
  vietnameseToJapanese,
}

class VocabularyQuizScreen extends StatefulWidget {
  final String level;
  final List<VocabularyWord>? words;
  final String? title;

  const VocabularyQuizScreen({
    super.key,
    required this.level,
    this.words,
    this.title,
  });

  @override
  State<VocabularyQuizScreen> createState() => _VocabularyQuizScreenState();
}

class _VocabularyQuizScreenState extends State<VocabularyQuizScreen> {
  List<VocabularyWord> _words = [];
  List<VocabularyWord> _allWords = [];
  List<VocabularyWord> _optionWords = [];
  int _correctWordIndex = 0;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _isLoading = true;
  int _score = 0;
  _QuizDirection _direction = _QuizDirection.japaneseToVietnamese;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuiz());
  }

  Future<void> _loadQuiz() async {
    final vocab = context.read<VocabularyProvider>();
    await vocab.ensureLoaded();

    final allWords = (widget.words != null && widget.words!.isNotEmpty)
        ? List<VocabularyWord>.from(widget.words!)
        : vocab.getWordsForFlashcard(widget.level);
    final quizWords = [...allWords]..shuffle();

    setState(() {
      _allWords = allWords;
      _words = quizWords.length > 20 ? quizWords.sublist(0, 20) : quizWords;
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
      _isLoading = false;
    });

    _generateOptions();
  }

  void _generateOptions() {
    if (_currentIndex >= _words.length || _words.isEmpty) return;

    final correctWord = _words[_currentIndex];
    final wrongWords = List<VocabularyWord>.from(_allWords)
      ..removeWhere((w) => w.id == correctWord.id)
      ..shuffle();

    final allOptionWords = [correctWord, ...wrongWords.take(3)]..shuffle();
    setState(() {
      _selectedAnswer = null;
      _answered = false;
      _optionWords = allOptionWords;
      _correctWordIndex = allOptionWords.indexWhere((w) => w.id == correctWord.id);
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _correctWordIndex) {
        _score++;
        context.read<ProgressProvider>().addXP(AppConstants.xpVocabQuiz);
      }
    });

    if (index == _correctWordIndex) {
      FeedbackAudioService.instance.playCorrect();
    } else {
      FeedbackAudioService.instance.playWrong();
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _generateOptions();
    } else {
      _showResults();
    }
  }

  void _restartQuiz() {
    setState(() {
      _words.shuffle();
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
    });
    _generateOptions();
  }

  void _switchDirection(_QuizDirection direction) {
    if (_direction == direction) return;
    setState(() {
      _direction = direction;
      _words.shuffle();
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
    });
    _generateOptions();
  }

  void _showResults() {
    final percent = _words.isEmpty ? 0 : (_score / _words.length * 100).toInt();
    context.read<ProgressProvider>().recordTestResult(
          widget.level,
          _score,
          _words.length,
          title: widget.title ?? (_direction == _QuizDirection.japaneseToVietnamese
              ? 'Quiz Từ vựng Nhật → Việt'
              : 'Quiz Từ vựng Việt → Nhật'),
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              percent >= 80 ? '🎉' : percent >= 60 ? '👍' : '💪',
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.bold,
                color: percent >= 60 ? AppTheme.successGreen : AppTheme.errorRed,
              ),
            ),
            Text('$_score / ${_words.length} câu đúng'),
            const SizedBox(height: 16),
            Text(
              percent >= 80
                  ? 'Xuất sắc! Bạn đã nắm khá chắc phần từ vựng này.'
                  : percent >= 60
                      ? 'Làm tốt lắm! Chỉ cần ôn thêm một chút nữa.'
                      : 'Mình ôn thêm vài lượt flashcard hoặc luyện nghe nhé.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
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
              _restartQuiz();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Quiz ${widget.level}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_words.isEmpty || _optionWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Quiz ${widget.level}')),
        body: const Center(child: Text('Chưa có dữ liệu quiz cho cấp độ này.')),
      );
    }

    final currentWord = _words[_currentIndex];
    final levelColor = AppTheme.jlptColor(widget.level);
    final isJapaneseToVietnamese = _direction == _QuizDirection.japaneseToVietnamese;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Quiz Từ vựng ${widget.level}')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _words.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            minHeight: 6,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.help_outline_rounded,
                          label: 'Câu ${_currentIndex + 1}/${_words.length}',
                          color: levelColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.star_rounded,
                          label: 'Điểm $_score',
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _DirectionButton(
                            selected: isJapaneseToVietnamese,
                            label: 'Nhật → Việt',
                            onTap: () => _switchDirection(_QuizDirection.japaneseToVietnamese),
                          ),
                        ),
                        Expanded(
                          child: _DirectionButton(
                            selected: !isJapaneseToVietnamese,
                            label: 'Việt → Nhật',
                            onTap: () => _switchDirection(_QuizDirection.vietnameseToJapanese),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeIn(
                    key: ValueKey('${_currentIndex}_${_direction.name}'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [levelColor, levelColor.withOpacity(0.72)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: levelColor.withOpacity(0.26),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (isJapaneseToVietnamese) ...[
                            Text(
                              currentWord.japanese,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 56,
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
                                fontSize: 34,
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
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _optionWords.length,
                      itemBuilder: (context, index) {
                        final optionWord = _optionWords[index];
                        final isCorrect = index == _correctWordIndex;
                        final isSelected = _selectedAnswer == index;

                        Color bgColor = Colors.white;
                        Color borderColor = Colors.grey.shade200;
                        Color textColor = AppTheme.textDark;

                        if (_answered) {
                          if (isCorrect) {
                            bgColor = AppTheme.successGreen.withOpacity(0.10);
                            borderColor = AppTheme.successGreen;
                            textColor = AppTheme.successGreen;
                          } else if (isSelected && !isCorrect) {
                            bgColor = AppTheme.errorRed.withOpacity(0.10);
                            borderColor = AppTheme.errorRed;
                            textColor = AppTheme.errorRed;
                          }
                        }

                        return GestureDetector(
                          onTap: () => _selectAnswer(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
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
                                          optionWord.vietnamese,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              optionWord.japanese,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${optionWord.hiragana} • ${optionWord.romaji}',
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
                                else if (_answered && isSelected && !isCorrect)
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
                            _currentIndex < _words.length - 1
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

class _DirectionButton extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _DirectionButton({
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
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
