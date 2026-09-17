import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/study_history.dart';
import '../../models/vocabulary.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/study_history_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../services/feedback_audio_service.dart';
import '../../services/tts_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class ListeningPracticeScreen extends StatefulWidget {
  final String level;
  final List<VocabularyWord>? words;
  final String? title;

  const ListeningPracticeScreen({
    super.key,
    required this.level,
    this.words,
    this.title,
  });

  @override
  State<ListeningPracticeScreen> createState() =>
      _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen> {
  
  static const List<_SpeedOption> _speedOptions = [
    _SpeedOption(label: 'Chậm 0.5x', rate: 0.5, emoji: '🐢'),
    _SpeedOption(label: 'Vừa 1.0x', rate: 1.0, emoji: '🚶'),
    _SpeedOption(label: 'Nhanh 1.5x', rate: 1.5, emoji: '🚀'),
  ];

  List<VocabularyWord> _words = [];
  List<VocabularyWord> _options = [];
  int _correctIndex = 0;
  int _currentIndex = 0;
  int? _selectedIndex;
  int _score = 0;
  int _sentenceIndex = 0;
  int _speedIndex = 1; 
  bool _answered = false;
  bool _isLoading = true;
  bool _autoPlay = true;
  bool _isSpeaking = false;
  DateTime _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPractice());
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  VocabularyWord get _currentWord => _words[_currentIndex];
  double get _currentRate => _speedOptions[_speedIndex].rate;

  Future<void> _loadPractice() async {
    final vocab = context.read<VocabularyProvider>();
    await vocab.ensureLoaded();
    final words = (widget.words != null && widget.words!.isNotEmpty)
        ? (List<VocabularyWord>.from(widget.words!)..shuffle()).take(15).toList()
        : vocab.getQuizWords(widget.level, 15);

    if (!mounted) return;
    setState(() {
      _words = words;
      _currentIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
      _sentenceIndex = 0;
      _startedAt = DateTime.now();
      _isLoading = false;
    });

    _prepareQuestion(playAudio: _autoPlay);
  }

  void _prepareQuestion({bool playAudio = false}) {
    if (_words.isEmpty || _currentIndex >= _words.length) return;
    final currentWord = _words[_currentIndex];
    final pool = List<VocabularyWord>.from(_words)
      ..removeWhere((item) => item.id == currentWord.id)
      ..shuffle();

    final options = [currentWord, ...pool.take(3)]..shuffle();

    setState(() {
      _options = options;
      _correctIndex = options.indexWhere((item) => item.id == currentWord.id);
      _selectedIndex = null;
      _answered = false;
      _sentenceIndex = 0;
    });

    if (playAudio) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _playSentence());
    }
  }

  List<String> _sentencesFor(VocabularyWord word) {
    if (word.exampleSentences.isNotEmpty) {
      return word.exampleSentences;
    }
    return [
      'きょうは${word.japanese}をおぼえます。',
      'せんせいは${word.japanese}といいました。',
      'まいにち${word.japanese}をつかいます。',
    ];
  }

  List<String> _translationsFor(VocabularyWord word) {
    if (word.exampleTranslations.isNotEmpty) {
      return word.exampleTranslations;
    }
    return [
      'Hôm nay mình ghi nhớ từ ${word.vietnamese}.',
      'Thầy cô vừa nói đến từ ${word.vietnamese}.',
      'Mỗi ngày mình đều dùng từ ${word.vietnamese}.',
    ];
  }

  String get _currentSentence {
    final sentences = _sentencesFor(_currentWord);
    return sentences[_sentenceIndex % sentences.length];
  }

  String get _currentTranslation {
    final translations = _translationsFor(_currentWord);
    return translations[_sentenceIndex % translations.length];
  }

  Future<void> _speak(String text, {double? rate}) async {
    if (text.trim().isEmpty) return;
    if (_isSpeaking) {
      await TtsService.instance.stop();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    setState(() => _isSpeaking = true);
    try {
      await TtsService.instance.speakJapanese(text,
          rate: rate ?? _currentRate);
    } finally {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _playWord() async {
    if (_words.isEmpty) return;
    await _speak(_currentWord.japanese, rate: _currentRate);
  }

  Future<void> _playSentence() async {
    if (_words.isEmpty) return;
    await _speak(_currentSentence, rate: _currentRate);
  }

  Future<void> _nextSentence() async {
    if (_words.isEmpty) return;
    final sentenceCount = _sentencesFor(_currentWord).length;
    setState(() =>
        _sentenceIndex = (_sentenceIndex + 1) % sentenceCount);
    if (_autoPlay) {
      await _playSentence();
    }
  }

  void _select(int index) {
    if (_answered) return;
    setState(() => _selectedIndex = index);
  }

  void _checkAnswer() {
    if (_selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hãy chọn một đáp án trước nhé. 👆')),
      );
      return;
    }

    setState(() {
      _answered = true;
      if (_selectedIndex == _correctIndex) {
        _score++;
        context.read<ProgressProvider>().addXP(AppConstants.xpVocabQuiz);
      }
    });

    if (_selectedIndex == _correctIndex) {
      FeedbackAudioService.instance.playCorrect();
    } else {
      FeedbackAudioService.instance.playWrong();
    }
  }

  Future<void> _next() async {
    if (_currentIndex >= _words.length - 1) {
      await _showResults();
      return;
    }

    setState(() => _currentIndex++);
    _prepareQuestion(playAudio: _autoPlay);
  }

  void _restart() {
    setState(() {
      _words.shuffle();
      _currentIndex = 0;
      _score = 0;
      _selectedIndex = null;
      _answered = false;
      _sentenceIndex = 0;
      _startedAt = DateTime.now();
    });
    _prepareQuestion(playAudio: _autoPlay);
  }

  Future<void> _showResults() async {
    final total = _words.length;
    final percent =
        total == 0 ? 0 : (_score / total * 100).round();
    final auth = context.read<AuthProvider>();
    final history = StudyHistory(
      id: const Uuid().v4(),
      userId: auth.currentUser?.uid ?? 'guest',
      testId:
          'listening_${widget.level}_${DateTime.now().millisecondsSinceEpoch}',
      title: widget.title ?? 'Luyện nghe câu ${widget.level}',
      jlptLevel: widget.level,
      totalQuestions: total,
      correctAnswers: _score,
      wrongAnswers: total - _score,
      scorePercent: percent.toDouble(),
      timeTakenSeconds:
          DateTime.now().difference(_startedAt).inSeconds,
      completedAt: DateTime.now(),
    );

    await context.read<StudyHistoryProvider>().addHistory(history);
    context.read<ProgressProvider>().recordTestResult(
          widget.level,
          _score,
          total,
          title: history.title,
          mode: 'listening',
          playbackRate: _currentRate,
        );

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎧 Kết quả luyện nghe',
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: percent >= 60
                    ? AppTheme.successGreen
                    : AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: 8),
            Text('$_score / $total câu đúng'),
            const SizedBox(height: 14),
            Text(
              percent >= 80
                  ? '🎉 Bạn nghe rất tốt! Thử tốc độ Nhanh nhé.'
                  : percent >= 60
                      ? '👍 Ổn rồi, thử tăng tốc độ để thử thách hơn.'
                      : '💪 Luyện thêm ở tốc độ Chậm để bắt kịp nhịp.',
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
            child: const Text('Thoát'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restart();
            },
            child: const Text('Luyện lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = AppTheme.jlptColor(widget.level);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Luyện nghe ${widget.level}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_words.isEmpty || _options.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Luyện nghe ${widget.level}')),
        body: const Center(
            child: Text('Chưa có dữ liệu luyện nghe cho cấp độ này.')),
      );
    }

    final word = _currentWord;
    final progressValue = (_currentIndex + 1) / _words.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Luyện nghe ${widget.level}')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 8),
                children: [
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Câu ${_currentIndex + 1}/${_words.length} • Điểm $_score',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text(
                              '${(progressValue * 100).round()}%',
                              style: TextStyle(
                                  color: levelColor,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                AlwaysStoppedAnimation(levelColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [levelColor, levelColor.withOpacity(0.76)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: levelColor.withOpacity(0.28),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎧 Nghe câu ví dụ và chọn đáp án',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Nghe từ riêng, nghe cả câu, đổi câu ví dụ và thử 3 tốc độ khác nhau.',
                          style: TextStyle(
                              color: Colors.white70, height: 1.4,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 14),

                        
                        const Text(
                          'Tốc độ phát:',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(
                              _speedOptions.length, (index) {
                            final option = _speedOptions[index];
                            final isSelected = _speedIndex == index;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _speedIndex = index),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(
                                      right: index < 2 ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white
                                              .withOpacity(0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        option.emoji,
                                        style: const TextStyle(
                                            fontSize: 18),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        option.label,
                                        style: TextStyle(
                                          color: isSelected
                                              ? levelColor
                                              : Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 14),

                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isSpeaking ? null : _playWord,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: levelColor,
                                minimumSize: const Size(0, 44),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                              ),
                              icon: Icon(
                                _isSpeaking
                                    ? Icons.stop_rounded
                                    : Icons.volume_up_rounded,
                                size: 18,
                              ),
                              label: const Text('Nghe từ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                            ElevatedButton.icon(
                              onPressed:
                                  _isSpeaking ? null : _playSentence,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: levelColor,
                                minimumSize: const Size(0, 44),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                              ),
                              icon: const Icon(
                                  Icons.record_voice_over_rounded,
                                  size: 18),
                              label: const Text('Nghe cả câu',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                            OutlinedButton.icon(
                              onPressed: _nextSentence,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                    color:
                                        Colors.white.withOpacity(0.5)),
                                minimumSize: const Size(0, 44),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                              ),
                              icon: const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 18),
                              label: const Text('Câu ví dụ mới',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        GestureDetector(
                          onTap: () =>
                              setState(() => _autoPlay = !_autoPlay),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                width: 40,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _autoPlay
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius:
                                      BorderRadius.circular(11),
                                ),
                                child: AnimatedAlign(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  alignment: _autoPlay
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: _autoPlay
                                          ? levelColor
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tự phát khi sang câu mới',
                                style: TextStyle(
                                  color: _autoPlay
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  
                  ...List.generate(_options.length, (index) {
                    final option = _options[index];
                    final isCorrect = index == _correctIndex;
                    final isSelected = index == _selectedIndex;

                    Color borderColor = Colors.grey.shade200;
                    Color background = Theme.of(context).cardColor;
                    Color textColor = AppTheme.textDark;

                    if (_answered) {
                      if (isCorrect) {
                        borderColor = AppTheme.successGreen;
                        background =
                            AppTheme.successGreen.withOpacity(0.1);
                        textColor = AppTheme.successGreen;
                      } else if (isSelected) {
                        borderColor = AppTheme.errorRed;
                        background = AppTheme.errorRed.withOpacity(0.1);
                        textColor = AppTheme.errorRed;
                      }
                    } else if (isSelected) {
                      borderColor = levelColor;
                      background = levelColor.withOpacity(0.08);
                      textColor = levelColor;
                    }

                    return GestureDetector(
                      onTap: () => _select(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: borderColor, width: 1.6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: borderColor.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: textColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option.vietnamese,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (_answered && isCorrect)
                              const Icon(Icons.check_circle,
                                  color: AppTheme.successGreen)
                            else if (_answered && isSelected && !isCorrect)
                              const Icon(Icons.cancel,
                                  color: AppTheme.errorRed),
                          ],
                        ),
                      ),
                    );
                  }),

                  
                  if (_answered)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: levelColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: levelColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${word.japanese} • ${word.hiragana}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: levelColor),
                          ),
                          const SizedBox(height: 4),
                          Text('Nghĩa đúng: ${word.vietnamese}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            'Câu đang nghe: $_currentSentence',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: levelColor),
                          ),
                          const SizedBox(height: 4),
                          Text(_currentTranslation,
                              style: const TextStyle(
                                  color: AppTheme.textMedium,
                                  fontSize: 13)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 4),
                ],
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _answered ? _next : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor:
                        _answered ? levelColor : AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: Icon(_answered
                      ? Icons.arrow_forward_rounded
                      : Icons.verified_rounded),
                  label: Text(
                    _answered
                        ? (_currentIndex == _words.length - 1
                            ? 'Xem kết quả 🎯'
                            : 'Câu tiếp theo →')
                        : 'Kiểm tra đáp án ✔',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedOption {
  final String label;
  final double rate;
  final String emoji;

  const _SpeedOption(
      {required this.label, required this.rate, required this.emoji});
}
