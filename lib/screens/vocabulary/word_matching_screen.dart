import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../services/feedback_audio_service.dart';
import '../../providers/progress_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../services/tts_service.dart';
import '../../utils/theme.dart';


const int _kRoundSize = 6;

class WordMatchingScreen extends StatefulWidget {
  final String level;
  final List<VocabularyWord>? words;
  final String? title;

  const WordMatchingScreen({
    super.key,
    required this.level,
    this.words,
    this.title,
  });

  @override
  State<WordMatchingScreen> createState() => _WordMatchingScreenState();
}

class _WordMatchingScreenState extends State<WordMatchingScreen>
    with SingleTickerProviderStateMixin {
  
  List<VocabularyWord> _allWords = [];
  List<VocabularyWord> _roundWords = [];
  List<String> _rightLabels = []; 
  bool _isLoading = true;

  
  int? _selectedLeft; 
  int? _selectedRight; 
  
  final Map<int, int> _matched = {};
  
  final Set<int> _wrongLeft = {};
  final Set<int> _wrongRight = {};

  
  int _totalCorrect = 0;
  int _totalAttempts = 0;
  int _roundNumber = 1;
  int _score = 0;

  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWords());
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  
  Future<void> _loadWords() async {
    List<VocabularyWord> source;
    if (widget.words != null && widget.words!.isNotEmpty) {
      source = List.from(widget.words!)..shuffle();
    } else {
      final vocab = context.read<VocabularyProvider>();
      await vocab.ensureLoaded();
      if (!mounted) return;
      source = vocab.getQuizWords(widget.level, 60);
    }

    if (!mounted) return;
    setState(() {
      _allWords = source;
      _isLoading = false;
    });
    _startRound();
  }

  void _startRound() {
    final startIdx = ((_roundNumber - 1) * _kRoundSize) % _allWords.length;
    final end = min(startIdx + _kRoundSize, _allWords.length);
    List<VocabularyWord> batch;
    if (end - startIdx < _kRoundSize && _allWords.length >= _kRoundSize) {
      batch = (_allWords..shuffle()).take(_kRoundSize).toList();
    } else {
      batch = _allWords.sublist(startIdx, end);
    }
    if (batch.length < 2) batch = (List<VocabularyWord>.from(_allWords)..shuffle()).take(_kRoundSize).toList();

    final rights = batch.map((w) => w.vietnamese).toList()..shuffle();
    setState(() {
      _roundWords = batch;
      _rightLabels = rights;
      _matched.clear();
      _wrongLeft.clear();
      _wrongRight.clear();
      _selectedLeft = null;
      _selectedRight = null;
    });
  }

  
  void _tapLeft(int idx) {
    if (_matched.containsKey(idx)) return; 
    TtsService.instance.speakJapanese(_roundWords[idx].japanese, rate: 1.0);
    setState(() {
      _wrongLeft.clear();
      _wrongRight.clear();
      _selectedLeft = idx;
      _selectedRight = null;
    });
    _tryMatch();
  }

  void _tapRight(int idx) {
    if (_matched.values.contains(idx)) return; 
    setState(() {
      _wrongLeft.clear();
      _wrongRight.clear();
      _selectedRight = idx;
    });
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedLeft == null || _selectedRight == null) return;
    final leftWord = _roundWords[_selectedLeft!];
    final rightVietnamese = _rightLabels[_selectedRight!];
    _totalAttempts++;

    if (leftWord.vietnamese == rightVietnamese) {
      
      _totalCorrect++;
      _score += 10;
      FeedbackAudioService.instance.playCorrect();
      context.read<ProgressProvider>().markVocabLearned(leftWord.id);
      setState(() {
        _matched[_selectedLeft!] = _selectedRight!;
        _selectedLeft = null;
        _selectedRight = null;
      });

      
      if (_matched.length == _roundWords.length) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          if (_allWords.length <= _kRoundSize) {
            _showResultDialog();
          } else if (_roundNumber * _kRoundSize >= _allWords.length) {
            _showResultDialog();
          } else {
            setState(() => _roundNumber++);
            _startRound();
          }
        });
      }
    } else {
      
      FeedbackAudioService.instance.playWrong();
      _shakeController.forward(from: 0);
      setState(() {
        _wrongLeft.add(_selectedLeft!);
        _wrongRight.add(_selectedRight!);
        _selectedLeft = null;
        _selectedRight = null;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() { _wrongLeft.clear(); _wrongRight.clear(); });
      });
    }
  }

  void _showResultDialog() {
    final pct = _totalAttempts == 0
        ? 0
        : (_totalCorrect / _totalAttempts * 100).round();
    context.read<ProgressProvider>().recordTestResult(
          widget.level,
          _totalCorrect,
          _totalAttempts,
          title: widget.title ?? 'Nối từ ${widget.level}',
          mode: 'matching',
        );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 Hoàn thành!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tỉ lệ đúng: $pct%  •  $_totalCorrect / $_totalAttempts cặp',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Điểm: $_score',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.jlptColor(widget.level)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _totalCorrect = 0;
                _totalAttempts = 0;
                _score = 0;
                _roundNumber = 1;
              });
              _loadWords();
            },
            child: const Text('Chơi lại'),
          ),
        ],
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    final levelColor = AppTheme.jlptColor(widget.level);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title ?? '🔗 Nối từ ${widget.level}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⭐ $_score',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _roundWords.isEmpty
              ? const Center(child: Text('Không có từ vựng'))
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        _buildProgressBar(levelColor),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '🇯🇵 Tiếng Nhật',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  '🇻🇳 Nghĩa tiếng Việt',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _shakeAnim,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(_shakeAnim.value, 0),
                                child: child,
                              );
                            },
                            child: _buildMatchingGrid(levelColor),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildHintText(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProgressBar(Color color) {
    final matchedCount = _matched.length;
    final total = _roundWords.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            'Vòng $_roundNumber  •  $matchedCount/$total cặp',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: color, fontSize: 14),
          ),
          const Spacer(),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : matchedCount / total,
                minHeight: 7,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingGrid(Color levelColor) {
    return ListView.builder(
      itemCount: _roundWords.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              
              Expanded(child: _LeftCard(
                word: _roundWords[i],
                index: i,
                isSelected: _selectedLeft == i,
                isMatched: _matched.containsKey(i),
                isWrong: _wrongLeft.contains(i),
                levelColor: levelColor,
                onTap: _tapLeft,
              )),
              const SizedBox(width: 12),
              
              Expanded(child: _RightCard(
                label: _rightLabels[i],
                index: i,
                isSelected: _selectedRight == i,
                isMatched: _matched.values.contains(i),
                isWrong: _wrongRight.contains(i),
                levelColor: levelColor,
                onTap: _tapRight,
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHintText() {
    final allDone = _matched.length == _roundWords.length;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            allDone ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            size: 16,
            color: allDone ? AppTheme.successGreen : AppTheme.accentBlue,
          ),
          const SizedBox(width: 6),
          Text(
            allDone
                ? 'Xuất sắc! Chuyển sang vòng tiếp theo...'
                : 'Chạm vào từ tiếng Nhật rồi chọn nghĩa tiếng Việt tương ứng',
            style: TextStyle(
              fontSize: 12,
              color: allDone ? AppTheme.successGreen : AppTheme.accentBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}




class _LeftCard extends StatelessWidget {
  final VocabularyWord word;
  final int index;
  final bool isSelected;
  final bool isMatched;
  final bool isWrong;
  final Color levelColor;
  final void Function(int) onTap;

  const _LeftCard({
    required this.word,
    required this.index,
    required this.isSelected,
    required this.isMatched,
    required this.isWrong,
    required this.levelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    if (isMatched) {
      bg = AppTheme.successGreen.withOpacity(0.15);
      border = AppTheme.successGreen;
    } else if (isWrong) {
      bg = AppTheme.errorRed.withOpacity(0.12);
      border = AppTheme.errorRed;
    } else if (isSelected) {
      bg = levelColor.withOpacity(0.15);
      border = levelColor;
    } else {
      bg = Theme.of(context).cardColor;
      border = Colors.transparent;
    }

    return GestureDetector(
      onTap: isMatched ? null : () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 2),
          boxShadow: isSelected
              ? [BoxShadow(color: levelColor.withOpacity(0.2), blurRadius: 8)]
              : null,
        ),
        child: Column(
          children: [
            Text(
              word.japanese,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: word.japanese.length > 3 ? 18 : 22,
                fontWeight: FontWeight.w800,
                color: isMatched ? AppTheme.successGreen : levelColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              word.hiragana,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMedium),
            ),
            if (isMatched)
              const Icon(Icons.check_rounded,
                  color: AppTheme.successGreen, size: 16),
          ],
        ),
      ),
    );
  }
}




class _RightCard extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final bool isMatched;
  final bool isWrong;
  final Color levelColor;
  final void Function(int) onTap;

  const _RightCard({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isMatched,
    required this.isWrong,
    required this.levelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    if (isMatched) {
      bg = AppTheme.successGreen.withOpacity(0.15);
      border = AppTheme.successGreen;
    } else if (isWrong) {
      bg = AppTheme.errorRed.withOpacity(0.12);
      border = AppTheme.errorRed;
    } else if (isSelected) {
      bg = AppTheme.accentBlue.withOpacity(0.15);
      border = AppTheme.accentBlue;
    } else {
      bg = Theme.of(context).cardColor;
      border = Colors.transparent;
    }

    return GestureDetector(
      onTap: isMatched ? null : () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppTheme.accentBlue.withOpacity(0.2),
                      blurRadius: 8)
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isMatched ? AppTheme.successGreen : null,
              ),
            ),
            if (isMatched)
              const Icon(Icons.check_rounded,
                  color: AppTheme.successGreen, size: 16),
          ],
        ),
      ),
    );
  }
}
