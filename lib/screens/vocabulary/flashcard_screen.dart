import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../providers/auth_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../services/feedback_audio_service.dart';
import '../../services/tts_service.dart';
import '../../utils/theme.dart';

class FlashcardScreen extends StatefulWidget {
  final String level;
  final List<VocabularyWord>? words;
  final String? title;

  const FlashcardScreen({
    super.key,
    required this.level,
    this.words,
    this.title,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _showBack = false;
  bool _isSpeaking = false;
  bool _isSubmitting = false;
  bool _answeredCurrentCard = false;
  bool? _lastAnswerKnown;
  bool _hasRecordedSessionResult = false;
  final Map<String, bool> _sessionAnswers = {};
  final Set<String> _skippedCards = <String>{};
  List<VocabularyWord> _sourceWords = [];
  Color? _answerOverlayColor;
  IconData? _answerOverlayIcon;
  String _answerOverlayText = '';
  int _answerToken = 0;

  int get _knownCount =>
      _sessionAnswers.values.where((isKnown) => isKnown).length;
  int get _unknownCount =>
      _sessionAnswers.values.where((isKnown) => !isKnown).length;
  int get _skippedCount => _skippedCards.length;
  int get _reviewedCount => _knownCount + _unknownCount;
  int get _memoryAccuracyPercent =>
      _reviewedCount == 0 ? 0 : ((_knownCount / _reviewedCount) * 100).round();

  
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutBack,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  @override
  void dispose() {
    _flipController.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _startSession({List<VocabularyWord>? overrideWords}) async {
    if (!mounted) return;
    final vocabProvider = context.read<VocabularyProvider>();
    final auth = context.read<AuthProvider>();
    final flashProvider = context.read<FlashcardProvider>();

    final sessionToken = ++_answerToken;
    setState(() {
      _isLoading = true;
      _showBack = false;
      _isSpeaking = false;
      _isSubmitting = false;
      _answeredCurrentCard = false;
      _lastAnswerKnown = null;
      _hasRecordedSessionResult = false;
      _answerOverlayColor = null;
      _answerOverlayIcon = null;
      _answerOverlayText = '';
      _sessionAnswers.clear();
      _skippedCards.clear();
    });
    _flipController.reset();

    await vocabProvider.ensureLoaded();
    final sourceWords = (overrideWords != null && overrideWords.isNotEmpty)
        ? List<VocabularyWord>.from(overrideWords)
        : (widget.words != null && widget.words!.isNotEmpty)
            ? List<VocabularyWord>.from(widget.words!)
            : vocabProvider.getWordsForFlashcard(widget.level);
    _sourceWords = sourceWords;
    await flashProvider.startSession(
      sourceWords,
      userId: auth.currentUser?.uid ?? 'guest',
    );

    if (!mounted || sessionToken != _answerToken) return;
    setState(() {
      _isLoading = false;
      _showBack = false;
      _isSpeaking = false;
      _isSubmitting = false;
      _answeredCurrentCard = false;
      _lastAnswerKnown = null;
    });
  }

  Future<void> _speak(String text, {double rate = 0.42}) async {
    if (text.trim().isEmpty || _isSpeaking) return;
    setState(() => _isSpeaking = true);
    try {
      await TtsService.instance.speakJapanese(text, rate: rate);
    } finally {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _speakCurrent() async {
    final word = context.read<FlashcardProvider>().currentWord;
    if (word == null) return;
    await _speak(word.japanese);
  }

  Future<void> _speakExample() async {
    final word = context.read<FlashcardProvider>().currentWord;
    if (word == null) return;
    final sentence = word.exampleSentences.isNotEmpty
        ? word.exampleSentences.first
        : '${word.japanese}をべんきょうします。';
    await _speak(sentence, rate: 0.35);
  }

  void _flipCard() {
    setState(() => _showBack = !_showBack);
    if (_showBack) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  Future<void> _answer(bool known) async {
    if (_isSubmitting || _answeredCurrentCard) return;
    final flashProvider = context.read<FlashcardProvider>();
    final progressProvider = context.read<ProgressProvider>();
    final vocabularyProvider = context.read<VocabularyProvider>();
    final word = flashProvider.currentWord;
    if (word == null) return;

    final answerToken = ++_answerToken;
    setState(() {
      _isSubmitting = true;
      _answeredCurrentCard = true;
      _lastAnswerKnown = known;
    });

    _sessionAnswers[word.id] = known;
    _skippedCards.remove(word.id);

    var reviewedAt = DateTime.now();
    var interval = 1;

    try {
      final progress = await flashProvider
          .markAnswer(word, known)
          .timeout(const Duration(seconds: 3));
      reviewedAt = progress.lastReviewed ?? reviewedAt;
      interval = progress.interval;
    } catch (_) {
      
    }

    try {
      await vocabularyProvider
          .updateWordProgress(
            wordId: word.id,
            known: known,
            interval: interval,
            reviewedAt: reviewedAt,
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      
    }

    if (known) {
      try {
        progressProvider.markVocabLearned(word.id);
      } catch (_) {}
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {}
      try {
        await FeedbackAudioService.instance.playCorrect();
      } catch (_) {}
      _showAnswerOverlay(
        color: AppTheme.successGreen,
        icon: Icons.check_circle_rounded,
        text: 'Chính xác! Bạn đã nhớ thẻ này',
      );
    } else {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {}
      try {
        await FeedbackAudioService.instance.playWrong();
      } catch (_) {}
      _showAnswerOverlay(
        color: AppTheme.errorRed,
        icon: Icons.cancel_rounded,
        text: 'Chưa ổn rồi, ôn lại thêm nhé',
      );
    }

    try {
      await TtsService.instance.stop();
    } catch (_) {}

    if (!mounted || answerToken != _answerToken) return;

    setState(() {
      _showBack = true;
      _isSpeaking = false;
      _isSubmitting = false;
      _answeredCurrentCard = true;
      _lastAnswerKnown = known;
    });

    try {
      if (_flipController.value < 1) {
        await _flipController.forward(from: _flipController.value);
      }
    } catch (_) {
      
    }

    _scheduleAdvanceAfterAnswer(word.id);
  }

  void _showAnswerOverlay({
    required Color color,
    required IconData icon,
    required String text,
  }) {
    setState(() {
      _answerOverlayColor = color;
      _answerOverlayIcon = icon;
      _answerOverlayText = text;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _answerOverlayColor = null;
        _answerOverlayIcon = null;
        _answerOverlayText = '';
      });
    });
  }

  void _syncCurrentCardState() {
    final word = context.read<FlashcardProvider>().currentWord;
    final hasAnswer = word != null && _sessionAnswers.containsKey(word.id);

    setState(() {
      _showBack = hasAnswer;
      _isSpeaking = false;
      _isSubmitting = false;
      _answeredCurrentCard = hasAnswer;
      _lastAnswerKnown = word == null ? null : _sessionAnswers[word.id];
    });

    if (hasAnswer) {
      _flipController.value = 1;
    } else {
      _flipController.reset();
    }
  }

  void _scheduleAdvanceAfterAnswer(String wordId) {
    Future.delayed(const Duration(milliseconds: 720), () {
      if (!mounted) return;
      final currentWord = context.read<FlashcardProvider>().currentWord;
      if (currentWord == null || currentWord.id != wordId) return;
      if (!_answeredCurrentCard || _isSubmitting) return;
      _moveToNextCard();
    });
  }

  void _moveToNextCard() {
    final flashProvider = context.read<FlashcardProvider>();
    final isLastCard =
        flashProvider.currentIndex >= flashProvider.sessionWords.length - 1;

    TtsService.instance.stop();

    if (isLastCard) {
      setState(() {
        _showBack = false;
        _isSpeaking = false;
        _isSubmitting = false;
        _answeredCurrentCard = false;
        _lastAnswerKnown = null;
      });
      _flipController.reset();
      _showResultDialog();
      return;
    }

    flashProvider.nextCard();
    _syncCurrentCardState();
  }

  void _moveToPreviousCard() {
    if (_isSubmitting) return;
    final flashProvider = context.read<FlashcardProvider>();
    if (flashProvider.currentIndex <= 0) return;

    TtsService.instance.stop();
    flashProvider.previousCard();
    _syncCurrentCardState();
  }

  void _skipCurrentCard() {
    if (_isSubmitting) return;
    final word = context.read<FlashcardProvider>().currentWord;
    if (word != null && !_sessionAnswers.containsKey(word.id)) {
      _skippedCards.add(word.id);
    }
    HapticFeedback.selectionClick();
    FeedbackAudioService.instance.playSkip().catchError((_) {});
    _moveToNextCard();
  }

  void _handlePrimaryNavigation() {
    if (_answeredCurrentCard) {
      _moveToNextCard();
    } else {
      _skipCurrentCard();
    }
  }

  void _recordSessionResultIfNeeded() {
    if (_hasRecordedSessionResult) return;
    final total = context.read<FlashcardProvider>().sessionWords.length;
    if (total > 0) {
      context.read<ProgressProvider>().recordTestResult(
            widget.level,
            _knownCount,
            total,
            title: widget.title ?? 'Flashcard ${widget.level}',
            mode: 'flashcard',
          );
    }
    _hasRecordedSessionResult = true;
  }

  void _showResultDialog() {
    final flashProvider = context.read<FlashcardProvider>();
    final total = flashProvider.sessionWords.length;
    final reviewedCount = _reviewedCount;
    _recordSessionResultIfNeeded();
    HapticFeedback.mediumImpact();
    FeedbackAudioService.instance.playComplete().catchError((_) {});
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
              'Đã ôn xong $total thẻ cấp ${widget.level}.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn đã trả lời $reviewedCount/$total thẻ và bỏ qua $_skippedCount thẻ.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tỉ lệ nhớ đúng',
                    style: TextStyle(
                      color: AppTheme.textMedium,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_memoryAccuracyPercent%',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ResultBox(
                    label: '✅ Đã nhớ',
                    value: '$_knownCount',
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultBox(
                    label: '❌ Chưa nhớ',
                    value: '$_unknownCount',
                    color: AppTheme.errorRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ResultBox(
              label: '⏭ Đã bỏ qua',
              value: '$_skippedCount',
              color: AppTheme.warningOrange,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : _knownCount / total,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation(AppTheme.successGreen),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'SRS đã cập nhật lịch ôn tập tối ưu cho bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMedium, fontSize: 13),
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
          if (_unknownCount > 0)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startSession(
                  overrideWords: _sourceWords
                      .where((word) => _sessionAnswers[word.id] == false)
                      .toList(),
                );
              },
              child: const Text('Ôn lại thẻ chưa nhớ'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startSession();
            },
            child: const Text('Ôn lại tất cả'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final flashProvider = context.watch<FlashcardProvider>();
    final word = flashProvider.currentWord;
    final total = flashProvider.sessionWords.length;
    final currentNumber =
        total == 0 ? 0 : (flashProvider.currentIndex + 1).clamp(1, total);
    final progressValue = total == 0 ? 0.0 : currentNumber / total;
    final levelColor = AppTheme.jlptColor(widget.level);
    final canGoPrevious = flashProvider.currentIndex > 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title ?? 'Flashcard ${widget.level}'),
        actions: [
          IconButton(
            tooltip: 'Phát âm',
            onPressed: (_isLoading || word == null) ? null : _speakCurrent,
            icon: Icon(
              _isSpeaking
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _startSession,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : word == null
              ? _EmptyFlashcardState(level: widget.level, title: widget.title)
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        
                        _ProgressHeader(
                          currentNumber: currentNumber,
                          total: total,
                          knownCount: _knownCount,
                          unknownCount: _unknownCount,
                          skippedCount: _skippedCount,
                          progressValue: progressValue,
                          levelColor: levelColor,
                        ),
                        const SizedBox(height: 14),

                        
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: _flipCard,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 320),
                                    transitionBuilder: (child, animation) {
                                      final rotate = Tween(begin: 0.0, end: 1.0)
                                          .animate(animation);
                                      return AnimatedBuilder(
                                        animation: rotate,
                                        child: child,
                                        builder: (context, child) {
                                          return child ?? const SizedBox();
                                        },
                                      );
                                    },
                                    child: _showBack
                                        ? _FlashCardBack(
                                            key: ValueKey(
                                                'back_${word.id}_${flashProvider.currentIndex}'),
                                            word: word,
                                            level: widget.level,
                                            onSpeakSentence: _speakExample,
                                          )
                                        : _FlashCardFront(
                                            key: ValueKey(
                                                'front_${word.id}_${flashProvider.currentIndex}'),
                                            word: word,
                                            level: widget.level,
                                            onSpeak: _speakCurrent,
                                            isSpeaking: _isSpeaking,
                                          ),
                                  ),
                                ),
                              ),
                              if (_answerOverlayColor != null)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 180),
                                      opacity: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _answerOverlayColor!.withOpacity(0.14),
                                          borderRadius: BorderRadius.circular(28),
                                          border: Border.all(
                                            color: _answerOverlayColor!.withOpacity(0.34),
                                            width: 3,
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.86),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _answerOverlayColor!.withOpacity(0.22),
                                                  blurRadius: 24,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              _answerOverlayIcon,
                                              color: _answerOverlayColor,
                                              size: 72,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (_answerOverlayIcon != null && _answerOverlayColor != null)
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 220),
                                    opacity: 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _answerOverlayColor,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _answerOverlayColor!.withOpacity(0.35),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(_answerOverlayIcon, color: Colors.white, size: 24),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _answerOverlayText,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        
                        if (!_showBack)
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: canGoPrevious ? _moveToPreviousCard : null,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(52, 52),
                                  padding: EdgeInsets.zero,
                                  foregroundColor: AppTheme.textMedium,
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Icon(Icons.arrow_back_rounded, size: 22),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: _skipCurrentCard,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(52, 52),
                                  padding: EdgeInsets.zero,
                                  foregroundColor: AppTheme.warningOrange,
                                  side: const BorderSide(
                                    color: AppTheme.warningOrange,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Icon(Icons.skip_next_rounded, size: 24),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _flipCard,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    backgroundColor: levelColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  icon: const Icon(Icons.flip_rounded),
                                  label: const Text(
                                    'Lật thẻ xem nghĩa',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: (_isSubmitting || _answeredCurrentCard)
                                          ? null
                                          : () => _answer(false),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(52),
                                        foregroundColor: AppTheme.errorRed,
                                        side: const BorderSide(
                                          color: AppTheme.errorRed,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      icon: const Icon(Icons.close_rounded),
                                      label: const Text(
                                        'Chưa nhớ',
                                        style: TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: (_isSubmitting || _answeredCurrentCard)
                                          ? null
                                          : () => _answer(true),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(52),
                                        backgroundColor: AppTheme.successGreen,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      icon: const Icon(Icons.check_rounded),
                                      label: const Text(
                                        'Đã nhớ',
                                        style: TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_answeredCurrentCard)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (_lastAnswerKnown == true
                                            ? AppTheme.successGreen
                                            : AppTheme.errorRed)
                                        .withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: (_lastAnswerKnown == true
                                              ? AppTheme.successGreen
                                              : AppTheme.errorRed)
                                          .withOpacity(0.25),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _lastAnswerKnown == true
                                            ? Icons.check_circle_rounded
                                            : Icons.cancel_rounded,
                                        color: _lastAnswerKnown == true
                                            ? AppTheme.successGreen
                                            : AppTheme.errorRed,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _lastAnswerKnown == true
                                              ? 'Đã ghi nhận: bạn nhớ thẻ này.'
                                              : 'Đã ghi nhận: bạn chưa nhớ thẻ này.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: _lastAnswerKnown == true
                                                ? AppTheme.successGreen
                                                : AppTheme.errorRed,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningOrange.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppTheme.warningOrange.withOpacity(0.25),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.touch_app_rounded,
                                        color: AppTheme.warningOrange,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Chọn “Đã nhớ” hoặc “Chưa nhớ”, hoặc bấm nút bên dưới để bỏ qua thẻ này.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.warningOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: canGoPrevious ? _moveToPreviousCard : null,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(52, 46),
                                      padding: EdgeInsets.zero,
                                      foregroundColor: AppTheme.textMedium,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Icon(Icons.arrow_back_rounded, size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isSubmitting ? null : _handlePrimaryNavigation,
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(46),
                                        backgroundColor: levelColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      icon: Icon(
                                        _answeredCurrentCard
                                            ? Icons.navigate_next_rounded
                                            : Icons.skip_next_rounded,
                                        size: 20,
                                      ),
                                      label: Text(
                                        _answeredCurrentCard
                                            ? (flashProvider.currentIndex >=
                                                    flashProvider.sessionWords.length - 1
                                                ? 'Xem tổng kết'
                                                : 'Sang flashcard tiếp theo')
                                            : (flashProvider.currentIndex >=
                                                    flashProvider.sessionWords.length - 1
                                                ? 'Bỏ qua & xem tổng kết'
                                                : 'Bỏ qua thẻ này'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}




class _ProgressHeader extends StatelessWidget {
  final int currentNumber;
  final int total;
  final int knownCount;
  final int unknownCount;
  final int skippedCount;
  final double progressValue;
  final Color levelColor;

  const _ProgressHeader({
    required this.currentNumber,
    required this.total,
    required this.knownCount,
    required this.unknownCount,
    required this.skippedCount,
    required this.progressValue,
    required this.levelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _SmallPill(
                label: 'Thẻ $currentNumber/$total',
                color: levelColor,
              ),
              _SmallPill(
                label: '✅ $knownCount',
                color: AppTheme.successGreen,
              ),
              _SmallPill(
                label: '❌ $unknownCount',
                color: AppTheme.errorRed,
              ),
              _SmallPill(
                label: '⏭ $skippedCount',
                color: AppTheme.warningOrange,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(levelColor),
            ),
          ),
        ],
      ),
    );
  }
}




class _FlashCardFront extends StatelessWidget {
  final VocabularyWord word;
  final String level;
  final VoidCallback onSpeak;
  final bool isSpeaking;

  const _FlashCardFront({
    super.key,
    required this.word,
    required this.level,
    required this.onSpeak,
    required this.isSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.jlptColor(level);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.85), color],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'JLPT $level',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSpeak,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isSpeaking
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          
          Center(
            child: Column(
              children: [
                Text(
                  word.japanese,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 56,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  word.hiragana,
                  style: const TextStyle(
                      fontSize: 22, color: Colors.white70, height: 1.3),
                ),
                const SizedBox(height: 6),
                Text(
                  word.romaji,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded,
                    color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  'Chạm vào thẻ hoặc nút bên dưới để lật',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




class _FlashCardBack extends StatelessWidget {
  final VocabularyWord word;
  final String level;
  final VoidCallback onSpeakSentence;

  const _FlashCardBack({
    super.key,
    required this.word,
    required this.level,
    required this.onSpeakSentence,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.jlptColor(level);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SmallPill(label: word.jlptLevel, color: color),
                const Spacer(),
                TextButton.icon(
                  onPressed: onSpeakSentence,
                  icon: const Icon(Icons.record_voice_over_rounded, size: 18),
                  label: const Text('Nghe câu'),
                  style: TextButton.styleFrom(foregroundColor: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              word.vietnamese,
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              word.english,
              style: const TextStyle(
                  fontSize: 17, color: AppTheme.textMedium, height: 1.3),
            ),
            const SizedBox(height: 14),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Gợi nhớ nhanh',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Từ này thuộc nhóm ${word.category}. Hãy nhẩm lại cách đọc rồi chọn mức độ nhớ.',
                    style: const TextStyle(height: 1.4, fontSize: 13),
                  ),
                ],
              ),
            ),
            
            if (word.exampleSentences.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '📖 Ví dụ',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                word.exampleSentences.length > 2
                    ? 2
                    : word.exampleSentences.length,
                (index) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.exampleSentences[index],
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                      if (index < word.exampleTranslations.length) ...[
                        const SizedBox(height: 4),
                        Text(
                          word.exampleTranslations[index],
                          style: const TextStyle(
                              color: AppTheme.textMedium,
                              height: 1.4,
                              fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Center(
              child: Text(
                '↩ Chạm lại để quay về mặt trước',
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class _SmallPill extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EmptyFlashcardState extends StatelessWidget {
  final String level;
  final String? title;
  const _EmptyFlashcardState({required this.level, this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.jlptColor(level).withOpacity(0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.style_rounded,
                  size: 44, color: AppTheme.jlptColor(level)),
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Chưa có flashcard cho $level',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Hãy thử đổi cấp độ hoặc tải lại dữ liệu từ vựng.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
