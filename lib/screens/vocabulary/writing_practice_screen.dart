import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../services/ai_practice_evaluator.dart';
import '../../services/feedback_audio_service.dart';
import '../../services/tts_service.dart';
import '../../utils/theme.dart';

class WritingPracticeScreen extends StatefulWidget {
  final String level;
  final List<VocabularyWord>? words;
  final String? title;

  const WritingPracticeScreen({
    super.key,
    required this.level,
    this.words,
    this.title,
  });

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.japanese);

  List<VocabularyWord> _words = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showGuide = true;
  bool _isSpeaking = false;
  bool _isChecking = false;

  int _correctCount = 0;
  int _incorrectCount = 0;
  int _skippedCount = 0;

  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  PracticeCheckResult? _currentResult;
  String _recognizedText = '';

  VocabularyWord? get _currentWord =>
      _words.isEmpty ? null : _words[_currentIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWords());
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _loadWords() async {
    List<VocabularyWord> source;
    if (widget.words != null && widget.words!.isNotEmpty) {
      source = List.from(widget.words!)..shuffle();
      source = source.take(10).toList();
    } else {
      final vocab = context.read<VocabularyProvider>();
      await vocab.ensureLoaded();
      source = vocab.getQuizWords(widget.level, 10);
    }

    if (!mounted) return;
    setState(() {
      _words = source;
      _isLoading = false;
      _resetCanvasState();
    });
    if (_currentWord != null) {
      await _speakWord(_currentWord!);
    }
  }

  void _resetCanvasState() {
    _showGuide = true;
    _strokes.clear();
    _currentStroke = [];
    _recognizedText = '';
    _currentResult = null;
    _isChecking = false;
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
    setState(() => _isSpeaking = true);
    try {
      await TtsService.instance.speakJapanese(word.japanese, rate: 1.0);
    } finally {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _startStroke(Offset pos) {
    setState(() {
      _currentStroke = [pos];
      _currentResult = null;
      _recognizedText = '';
    });
  }

  void _appendStroke(Offset pos) {
    setState(() => _currentStroke.add(pos));
  }

  void _endStroke() {
    if (_currentStroke.isEmpty) return;
    setState(() {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });
  }

  void _undoLastStroke() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
      _currentResult = null;
      _recognizedText = '';
    });
  }

  void _clearCanvas() {
    setState(_resetCanvasState);
  }

  Rect? _calculateStrokeBounds() {
    final points = <Offset>[
      for (final stroke in _strokes) ...stroke,
      ..._currentStroke,
    ];
    if (points.isEmpty) return null;

    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final point in points.skip(1)) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Future<Uint8List> _renderStrokesAsPng() async {
    const double outputSize = 1600;
    const double padding = 180;
    final bounds = _calculateStrokeBounds();
    if (bounds == null) {
      throw Exception('Không có nét viết để xử lý');
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, outputSize, outputSize),
      backgroundPaint,
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFF2F4F8)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(outputSize / 2, 0), Offset(outputSize / 2, outputSize), gridPaint);
    canvas.drawLine(Offset(0, outputSize / 2), Offset(outputSize, outputSize / 2), gridPaint);

    final contentWidth = bounds.width <= 1 ? 1.0 : bounds.width;
    final contentHeight = bounds.height <= 1 ? 1.0 : bounds.height;
    final scale = math.min(
      (outputSize - padding * 2) / contentWidth,
      (outputSize - padding * 2) / contentHeight,
    );
    final dx = (outputSize - contentWidth * scale) / 2 - bounds.left * scale;
    final dy = (outputSize - contentHeight * scale) / 2 - bounds.top * scale;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 24 / scale;

    final allStrokes = <List<Offset>>[
      ..._strokes,
      if (_currentStroke.isNotEmpty) _currentStroke,
    ];

    for (final stroke in allStrokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 10 / scale, strokePaint..style = PaintingStyle.fill);
        strokePaint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, strokePaint);
    }
    canvas.restore();

    final image = await recorder.endRecording().toImage(outputSize.toInt(), outputSize.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Không xuất được ảnh chữ viết');
    }
    return byteData.buffer.asUint8List();
  }

  Future<void> _checkWritingWithAi() async {
    final word = _currentWord;
    if (word == null || (_strokes.isEmpty && _currentStroke.isEmpty)) return;

    setState(() {
      _isChecking = true;
      _currentResult = null;
      _recognizedText = '';
    });

    File? imageFile;
    try {
      final Uint8List pngBytes = await _renderStrokesAsPng();
      final tempDir = await getTemporaryDirectory();
      imageFile = File(
        '${tempDir.path}/nihongo_handwriting_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await imageFile.writeAsBytes(pngBytes, flush: true);

      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognized = await _textRecognizer
          .processImage(inputImage)
          .timeout(const Duration(seconds: 8));
      final extractedText = recognized.blocks
          .expand((block) => block.lines)
          .map((line) => line.text)
          .join(' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      final result = AiPracticeEvaluator.evaluateWriting(
        word: word,
        recognizedText: extractedText,
      );

      if (!mounted) return;
      setState(() {
        _recognizedText = extractedText;
        _currentResult = result;
        _isChecking = false;
      });
      unawaited(_playResultSound(result.isCorrect));
    } catch (_) {
      final result = AiPracticeEvaluator.evaluateWriting(
        word: word,
        recognizedText: '',
      );
      if (!mounted) return;
      setState(() {
        _currentResult = result;
        _recognizedText = '';
        _isChecking = false;
      });
      unawaited(_playResultSound(false));
    } finally {
      try {
        if (imageFile != null && await imageFile.exists()) {
          await imageFile.delete();
        }
      } catch (_) {}
      if (mounted && _isChecking) {
        setState(() => _isChecking = false);
      }
    }
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

  Future<void> _nextWord({bool skipped = false}) async {
    _commitCurrentResult(skipped: skipped);
    if (_currentIndex >= _words.length - 1) {
      await TtsService.instance.stop();
      _showResultDialog();
      return;
    }

    final next = _words[_currentIndex + 1];
    if (!mounted) return;
    setState(() {
      _currentIndex++;
      _resetCanvasState();
    });
    await _speakWord(next);
  }

  void _showResultDialog() {
    final total = _words.length;
    context.read<ProgressProvider>().recordTestResult(
          widget.level,
          _correctCount,
          total,
          mode: 'writing_ai',
          title: widget.title ?? 'AI Writing Practice',
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('✏️ Hoàn thành luyện viết AI', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI đã chấm ${widget.level} với ${_words.length} từ.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryChip(
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.successGreen,
                  label: 'Đúng',
                  value: '$_correctCount',
                ),
                _SummaryChip(
                  icon: Icons.cancel_rounded,
                  color: AppTheme.errorRed,
                  label: 'Sai',
                  value: '$_incorrectCount',
                ),
                _SummaryChip(
                  icon: Icons.skip_next_rounded,
                  color: AppTheme.textMedium,
                  label: 'Bỏ qua',
                  value: '$_skippedCount',
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
                _resetCanvasState();
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
    final curr = total == 0 ? 0 : (_currentIndex + 1).clamp(1, total);
    final screenHeight = MediaQuery.of(context).size.height;
    final canvasHeight = screenHeight >= 900
        ? 420.0
        : screenHeight >= 780
            ? 360.0
            : 310.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title ?? '✏️ Luyện viết AI ${widget.level}'),
        actions: [
          IconButton(
            tooltip: _showGuide ? 'Ẩn gợi ý' : 'Hiện gợi ý',
            onPressed: () => setState(() => _showGuide = !_showGuide),
            icon: Icon(
              _showGuide ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Tải lại',
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _correctCount = 0;
                _incorrectCount = 0;
                _skippedCount = 0;
                _isLoading = true;
                _resetCanvasState();
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
                      _buildProgress(curr, total, levelColor),
                      const SizedBox(height: 12),
                      _buildWordInfoBar(word, levelColor),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: canvasHeight,
                        child: _buildCanvas(word, levelColor),
                      ),
                      const SizedBox(height: 12),
                      _buildAiPanel(levelColor),
                      const SizedBox(height: 12),
                      _buildToolBar(levelColor),
                      const SizedBox(height: 10),
                      _buildActionRow(levelColor),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProgress(int curr, int total, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            '$curr / $total từ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : curr / total,
                minHeight: 7,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('✅$_correctCount', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWordInfoBar(VocabularyWord word, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.vietnamese,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  word.english,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniPill(label: word.japanese, color: color),
                    _MiniPill(label: word.hiragana, color: color.withOpacity(0.9)),
                    _MiniPill(label: word.romaji, color: AppTheme.textMedium),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _speakWord(word),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isSpeaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                color: color,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(VocabularyWord word, Color color) {
    return RepaintBoundary(
      key: _canvasKey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.32), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(color: color.withOpacity(0.14)),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Khung viết lớn • ưu tiên nét đậm, gọn',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (_showGuide)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      word.japanese,
                      style: TextStyle(
                        fontSize: word.japanese.length > 2 ? 118 : 138,
                        fontWeight: FontWeight.w900,
                        color: color.withOpacity(0.08),
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) => _startStroke(e.localPosition),
              onPointerMove: (e) => _appendStroke(e.localPosition),
              onPointerUp: (_) => _endStroke(),
              onPointerCancel: (_) => _endStroke(),
              child: GestureDetector(
                onPanUpdate: (_) {},
                child: CustomPaint(
                  painter: _StrokePainter(
                    strokes: _strokes,
                    currentStroke: _currentStroke,
                    strokeColor: AppTheme.textDark,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            if (_strokes.isEmpty && _currentStroke.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.draw_rounded, size: 46, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text(
                      'Viết to hơn trong khung này rồi bấm “AI kiểm tra”.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'App sẽ render nét vẽ sang ảnh trắng - mực đen để AI đọc chữ ổn định hơn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiPanel(Color levelColor) {
    final result = _currentResult;
    final passed = result?.isCorrect ?? false;
    final scorePercent = ((result?.score ?? 0) * 100).round();
    final statusColor = result == null
        ? levelColor
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
              ? levelColor.withOpacity(0.18)
              : statusColor.withOpacity(0.28),
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
                          ? Icons.auto_awesome_rounded
                          : passed
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: statusColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      result == null
                          ? 'Chờ AI chấm'
                          : passed
                          ? 'Đạt'
                          : 'Chưa đạt',
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
            result?.feedback ?? 'AI sẽ nhận diện nét chữ của bạn, chấm mức khớp và gợi ý từ gần nhất.',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: statusColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
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
                  'AI đọc được:',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  _recognizedText.isEmpty ? 'Chưa có kết quả nhận diện.' : _recognizedText,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                if (result != null) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniPill(
                        label: 'Mức khớp $scorePercent%',
                        color: statusColor,
                      ),
                      _MiniPill(
                        label: 'Gần nhất: ${result.matchedTarget}',
                        color: levelColor,
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
                    child: Text(tip,
                        style: const TextStyle(fontSize: 13, height: 1.45)),
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

  Widget _buildToolBar(Color levelColor) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _strokes.isEmpty ? null : _undoLastStroke,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              side: BorderSide(color: AppTheme.textMedium.withOpacity(0.4)),
              foregroundColor: AppTheme.textMedium,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.undo_rounded, size: 18),
            label: const Text('Xóa nét'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: (_strokes.isEmpty && _currentStroke.isEmpty) ? null : _clearCanvas,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              foregroundColor: AppTheme.errorRed,
              side: BorderSide(color: AppTheme.errorRed.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Xóa tất cả'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _showGuide = !_showGuide),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              foregroundColor: levelColor,
              side: BorderSide(color: levelColor.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(
              _showGuide ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: 18,
            ),
            label: Text(_showGuide ? 'Ẩn gợi ý' : 'Gợi ý'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(Color levelColor) {
    final lastCard = _currentIndex >= _words.length - 1;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _nextWord(skipped: true),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppTheme.textMedium,
                  side: BorderSide(color: AppTheme.textMedium.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Bỏ qua'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: (_strokes.isEmpty && _currentStroke.isEmpty) || _isChecking
                    ? null
                    : _checkWritingWithAi,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: levelColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_isChecking ? 'AI đang chấm' : 'AI kiểm tra'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: _strokes.isEmpty && _currentStroke.isEmpty ? null : _clearCanvas,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Viết lại'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.textMedium),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: _currentWord == null ? null : () => _speakWord(_currentWord!),
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Nghe lại'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.accentBlue),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _currentResult == null ? null : () => _nextWord(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppTheme.successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: Icon(lastCard ? Icons.assessment_rounded : Icons.arrow_forward_rounded),
                label: Text(lastCard ? 'Xem tổng kết' : 'Sang từ tiếp theo'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _SummaryChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
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
            fontWeight: FontWeight.w900,
            color: color,
            fontSize: 22,
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

class _StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;

  _StrokePainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    void drawStroke(List<Offset> points) {
      if (points.isEmpty) return;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    for (final stroke in strokes) {
      drawStroke(stroke);
    }
    drawStroke(currentStroke);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    paint.strokeWidth = 0.5;
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
