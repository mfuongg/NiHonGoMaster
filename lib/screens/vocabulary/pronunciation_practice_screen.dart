import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../services/ai_practice_evaluator.dart';
import '../../services/feedback_audio_service.dart';
import '../../services/tts_service.dart';
import '../../utils/theme.dart';

class PronunciationPracticeScreen extends StatefulWidget {
  final String level;
  final List<VocabularyWord>? words;
  final String? title;

  const PronunciationPracticeScreen({
    super.key,
    required this.level,
    this.words,
    this.title,
  });

  @override
  State<PronunciationPracticeScreen> createState() =>
      _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState
    extends State<PronunciationPracticeScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();

  final List<Map<String, dynamic>> _speeds = const [
    {'label': '0.5×', 'rate': 0.5},
    {'label': '1.0×', 'rate': 1.0},
    {'label': '1.5×', 'rate': 1.5},
  ];

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  List<VocabularyWord> _words = [];
  int _currentIndex = 0;
  int _speedIndex = 1;

  bool _isLoading = true;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _isChecking = false;
  bool _showMeaning = false;
  bool _speechReady = false;
  bool _handledAutoStop = false;

  String? _speechLocaleId;
  String _liveTranscript = '';
  String _speechStatus = 'Sẵn sàng';
  String? _speechError;

  PracticeCheckResult? _currentResult;

  int _correctCount = 0;
  int _incorrectCount = 0;
  int _skippedCount = 0;

  VocabularyWord? get _currentWord =>
      _words.isEmpty ? null : _words[_currentIndex];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _prepareSpeech();
      await _loadWords();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _prepareSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() => _speechStatus = status);
        if (_isListening &&
            !_handledAutoStop &&
            (status == 'done' || status == 'notListening')) {
          _handledAutoStop = true;
          _finishListeningAndEvaluate();
        }
      },
      onError: (error) {
        if (!mounted) return;
        final hasTranscript = _liveTranscript.trim().isNotEmpty;
        setState(() {
          _speechError = error.errorMsg;
          _isListening = false;
          _speechStatus = hasTranscript ? 'Có bản ghi, AI đang chấm...' : 'Lỗi micro';
        });
        if (hasTranscript && !_handledAutoStop) {
          _handledAutoStop = true;
          _finishListeningAndEvaluate();
        }
      },
    );

    String? localeId;
    if (available) {
      final locales = await _speech.locales();
      for (final locale in locales) {
        final id = locale.localeId;
        if (id.toLowerCase().startsWith('ja')) {
          localeId = id;
          break;
        }
      }
      localeId ??= locales.isNotEmpty ? locales.first.localeId : 'ja_JP';
    }

    if (!mounted) return;
    setState(() {
      _speechReady = available;
      _speechLocaleId = localeId ?? 'ja_JP';
      _speechStatus = available
          ? 'Nhấn micro để ghi âm. AI sẽ ưu tiên nhận diện tiếng Nhật rồi chấm ngay sau khi dừng.'
          : 'Thiết bị chưa hỗ trợ nhận diện giọng nói';
    });
  }

  Future<void> _loadWords() async {
    List<VocabularyWord> source;
    if (widget.words != null && widget.words!.isNotEmpty) {
      source = List.from(widget.words!)..shuffle();
      source = source.take(12).toList();
    } else {
      final vocab = context.read<VocabularyProvider>();
      await vocab.ensureLoaded();
      source = vocab.getQuizWords(widget.level, 12);
    }

    if (!mounted) return;
    setState(() {
      _words = source;
      _isLoading = false;
      _resetCurrentState();
    });

    if (_currentWord != null) {
      await _speakWord(_currentWord!);
    }
  }

  void _resetCurrentState() {
    _showMeaning = false;
    _liveTranscript = '';
    _speechError = null;
    _speechStatus = 'Nhấn micro để ghi âm và AI sẽ kiểm tra';
    _currentResult = null;
    _isListening = false;
    _isChecking = false;
    _handledAutoStop = false;
  }

  Future<void> _playResultSound(bool isCorrect) async {
    try {
      final player = isCorrect
          ? FeedbackAudioService.instance.playCorrect()
          : FeedbackAudioService.instance.playWrong();
      await player.timeout(const Duration(seconds: 2));
    } catch (_) {
      
    }
  }

  Future<void> _speakWord(VocabularyWord word) async {
    if (_isSpeaking) {
      await TtsService.instance.stop();
      if (!mounted) return;
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    try {
      await TtsService.instance.speakJapanese(
        word.japanese,
        rate: _speeds[_speedIndex]['rate'] as double,
      );
    } finally {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    }
  }

  Future<void> _startListening() async {
    if (!_speechReady || _currentWord == null) return;
    await TtsService.instance.stop();
    await _speech.stop();
    await Future<void>.delayed(const Duration(milliseconds: 160));
    setState(() {
      _handledAutoStop = false;
      _isListening = true;
      _liveTranscript = '';
      _speechError = null;
      _currentResult = null;
      _speechStatus = 'Đang ghi âm tiếng Nhật...';
    });

    try {
      await _speech.listen(
        localeId: _speechLocaleId ?? 'ja_JP',
        partialResults: true,
        listenFor: const Duration(seconds: 9),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _liveTranscript = result.recognizedWords.trim();
          });
          if (result.finalResult && _isListening && !_handledAutoStop) {
            _handledAutoStop = true;
            _finishListeningAndEvaluate();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _isChecking = false;
        _speechError = e.toString();
        _speechStatus = 'Không thể bắt đầu ghi âm. Hãy thử lại.';
      });
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    _handledAutoStop = true;
    await _speech.stop();
    await _finishListeningAndEvaluate();
  }

  Future<void> _finishListeningAndEvaluate() async {
    if (_isChecking) return;
    final word = _currentWord;
    if (word == null) return;

    if (mounted) {
      setState(() {
        _isListening = false;
        _isChecking = true;
        _speechStatus = 'AI đang kiểm tra phát âm...';
      });
    }

    try {
      final result = AiPracticeEvaluator.evaluatePronunciation(
        word: word,
        recognizedText: _liveTranscript,
      );

      if (!mounted) return;
      setState(() {
        _currentResult = result;
        _isChecking = false;
        _showMeaning = true;
        _speechStatus = result.isCorrect ? 'Phát âm đạt' : 'Cần thử lại';
      });
      unawaited(_playResultSound(result.isCorrect));
    } catch (_) {
      final fallback = AiPracticeEvaluator.evaluatePronunciation(
        word: word,
        recognizedText: '',
      );
      if (!mounted) return;
      setState(() {
        _currentResult = fallback;
        _isChecking = false;
        _showMeaning = true;
        _speechStatus = 'AI chưa chấm được, đã chuyển sang gợi ý an toàn';
      });
      unawaited(_playResultSound(false));
    } finally {
      if (mounted && _isChecking) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _retryCurrentWord() async {
    await _speech.stop();
    if (!mounted) return;
    setState(_resetCurrentState);
  }

  void _commitCurrentResult({required bool skipped}) {
    final word = _currentWord;
    if (skipped || _currentResult == null) {
      _skippedCount++;
      return;
    }

    if (_currentResult!.isCorrect) {
      _correctCount++;
      if (word != null) {
        context.read<ProgressProvider>().markVocabLearned(word.id);
      }
    } else {
      _incorrectCount++;
    }
  }

  Future<void> _goToNext({bool skipped = false}) async {
    await _speech.stop();
    await TtsService.instance.stop();
    _commitCurrentResult(skipped: skipped);

    if (_currentIndex >= _words.length - 1) {
      _showResultDialog();
      return;
    }

    final nextWord = _words[_currentIndex + 1];
    if (!mounted) return;
    setState(() {
      _currentIndex++;
      _resetCurrentState();
    });
    await _speakWord(nextWord);
  }

  void _showResultDialog() {
    final total = _words.length;
    context.read<ProgressProvider>().recordTestResult(
          widget.level,
          _correctCount,
          total,
          mode: 'pronunciation_ai',
          title: widget.title ?? 'AI Pronunciation Practice',
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎙 Hoàn thành luyện phát âm AI', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI đã chấm xong $total từ của cấp ${widget.level}.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryBox(
                  label: 'Đúng',
                  value: '$_correctCount',
                  color: AppTheme.successGreen,
                  icon: Icons.check_circle_rounded,
                ),
                _SummaryBox(
                  label: 'Sai',
                  value: '$_incorrectCount',
                  color: AppTheme.errorRed,
                  icon: Icons.cancel_rounded,
                ),
                _SummaryBox(
                  label: 'Bỏ qua',
                  value: '$_skippedCount',
                  color: AppTheme.textMedium,
                  icon: Icons.skip_next_rounded,
                ),
              ],
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
                _currentIndex = 0;
                _correctCount = 0;
                _incorrectCount = 0;
                _skippedCount = 0;
                _isLoading = true;
                _resetCurrentState();
              });
              _loadWords();
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
    final word = _currentWord;
    final total = _words.length;
    final currentNum = total == 0 ? 0 : (_currentIndex + 1).clamp(1, total);


    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title ?? '🎙 Phát âm AI ${widget.level}'),
        actions: [
          IconButton(
            tooltip: 'Làm lại',
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _correctCount = 0;
                _incorrectCount = 0;
                _skippedCount = 0;
                _isLoading = true;
                _resetCurrentState();
              });
              _loadWords();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : word == null
              ? const Center(child: Text('Không có từ vựng'))
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      _buildProgress(currentNum, total, levelColor),
                      const SizedBox(height: 14),
                      _buildSpeedSelector(levelColor),
                      const SizedBox(height: 14),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        child: _buildWordCard(word, levelColor),
                      ),
                      const SizedBox(height: 12),
                      _buildRecognizerPanel(levelColor),
                      const SizedBox(height: 12),
                      _buildActionButtons(word, levelColor),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProgress(int curr, int total, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            '$curr / $total',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : curr / total,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('✅$_correctCount', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Text('❌$_incorrectCount', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSpeedSelector(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_speeds.length, (index) {
          final selected = _speedIndex == index;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => _speedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _speeds[index]['label'] as String,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textMedium,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWordCard(VocabularyWord word, Color color) {
    final titleFontSize = word.japanese.length >= 4
        ? 40.0
        : word.japanese.length == 3
            ? 46.0
            : 52.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.92), color],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      constraints: const BoxConstraints(minHeight: 260),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening
                    ? Icons.mic_rounded
                    : _isSpeaking
                        ? Icons.graphic_eq_rounded
                        : Icons.record_voice_over_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                word.japanese,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: titleFontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.hiragana,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            word.romaji,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white60,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (_showMeaning) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    word.vietnamese,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.english,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Nghe mẫu → ghi âm → AI ưu tiên tiếng Nhật và chấm ngay rồi mới sang từ tiếp theo.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognizerPanel(Color color) {
    final result = _currentResult;
    final passed = result?.isCorrect ?? false;
    final scorePercent = ((result?.score ?? 0) * 100).round();
    final statusColor = result == null
        ? color
        : passed
        ? AppTheme.successGreen
        : AppTheme.errorRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: result == null
              ? color.withOpacity(0.18)
              : statusColor.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      result == null
                          ? Icons.smart_toy_outlined
                          : passed
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: statusColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      result == null
                          ? 'Đang chờ bản ghi'
                          : passed
                          ? 'Đạt'
                          : 'Cần thử lại',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (result != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$scorePercent%',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result == null ? _speechStatus : result.feedback,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: statusColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI nhận diện:',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  _liveTranscript.isEmpty ? 'Chưa có bản ghi âm.' : _liveTranscript,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                if (_speechError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _speechError!,
                    style: const TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (result != null) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Mức khớp $scorePercent%',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Mục tiêu: ${result.matchedTarget}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          
          if (result != null && result.suggestions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: statusColor.withOpacity(0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: statusColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Gợi ý chi tiết từ AI',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...result.suggestions.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(tip, style: const TextStyle(fontSize: 13, height: 1.45)),
                  )),
                  if (result.encouragement.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        result.encouragement,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ], 
      ), 
    ); 
  }

  Widget _buildActionButtons(VocabularyWord word, Color color) {
    final lastCard = _currentIndex >= _words.length - 1;
    final canProceed = _currentResult != null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _speakWord(word),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: color.withOpacity(0.35)),
                  foregroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(_isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded),
                label: Text(_isSpeaking ? 'Dừng mẫu' : 'Nghe mẫu'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: !_speechReady || _isChecking
                    ? null
                    : _isListening
                        ? _stopListening
                        : _startListening,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: _isListening ? AppTheme.errorRed : color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _isChecking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded),
                label: Text(
                  _isChecking
                      ? 'AI đang chấm'
                      : _isListening
                          ? 'Dừng ghi âm'
                          : 'Ghi âm & AI chấm',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: _retryCurrentWord,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMedium,
                ),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: _showMeaning
                    ? () => setState(() => _showMeaning = false)
                    : () => setState(() => _showMeaning = true),
                icon: Icon(
                  _showMeaning ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                ),
                label: Text(_showMeaning ? 'Ẩn nghĩa' : 'Xem nghĩa'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentBlue,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _goToNext(skipped: true),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppTheme.textMedium,
                  side: BorderSide(color: AppTheme.textMedium.withOpacity(0.28)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Bỏ qua'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: canProceed ? () => _goToNext() : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppTheme.successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(lastCard ? Icons.assessment_rounded : Icons.arrow_forward_rounded),
                label: Text(lastCard ? 'Xem tổng kết' : 'Từ tiếp theo'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
        ),
      ],
    );
  }
}
