import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/jlpt_test_data.dart';
import '../../models/quiz.dart';
import '../../models/study_history.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/study_history_provider.dart';
import '../../utils/theme.dart';

class JLPTScreen extends StatelessWidget {
  const JLPTScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

    return DefaultTabController(
      length: levels.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📝 Luyện thi JLPT'),
          bottom: TabBar(
            isScrollable: true,
            tabs: levels
                .map(
                  (level) => Tab(text: '$level • ${JLPTTestData.getTestsByLevel(level).length} đề'),
                )
                .toList(),
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF93D1),
                    Color(0xFF8B5CF6),
                    Color(0xFF57B6FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kho đề JLPT mô phỏng ✨',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mỗi cấp độ N5–N1 hiện có 5 đề, mỗi đề 10 câu với dạng câu hỏi sát JLPT hơn: đọc hiểu từ vựng theo ngữ cảnh, điền từ và ngữ pháp khó hơn.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                children: levels
                    .map(
                      (level) => _JLPTLevelView(
                        level: level,
                        tests: JLPTTestData.getTestsByLevel(level),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JLPTLevelView extends StatelessWidget {
  final String level;
  final List<JLPTTest> tests;

  const _JLPTLevelView({required this.level, required this.tests});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.jlptColor(level);

    if (tests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz_outlined, size: 56, color: color),
              const SizedBox(height: 12),
              Text(
                'Chưa có đề $level',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hiện tại app chưa có đề cho cấp độ này. Hãy thử cấp độ khác nhé.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        level,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        test.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoPill(
                      icon: Icons.fact_check_outlined,
                      label: '${test.questions.length} câu hỏi',
                      color: color,
                    ),
                    _InfoPill(
                      icon: Icons.timer_outlined,
                      label: '${test.timeMinutes} phút',
                      color: AppTheme.accentOrange,
                    ),
                    _InfoPill(
                      icon: Icons.verified_rounded,
                      label: 'Kiểm tra đáp án rõ ràng',
                      color: AppTheme.accentBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Bao gồm từ vựng theo ngữ cảnh, kanji, điền từ và ngữ pháp mô phỏng JLPT của cấp độ $level. Sau khi chọn đáp án, bạn bấm nút kiểm tra để xem lời giải chi tiết.',
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TestScreen(test: test)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Bắt đầu làm bài'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class TestScreen extends StatefulWidget {
  final JLPTTest test;
  const TestScreen({super.key, required this.test});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _currentIndex = 0;
  int? _selected;
  bool _answered = false;
  bool _completed = false;
  int _score = 0;
  late final DateTime _startedAt;
  late final ValueNotifier<int> _timer;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _timer = ValueNotifier(widget.test.timeMinutes * 60);
    _startTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _timer.dispose();
    super.dispose();
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _completed) {
        timer.cancel();
        return;
      }
      if (_timer.value <= 1) {
        _timer.value = 0;
        timer.cancel();
        _finishTest();
        return;
      }
      _timer.value -= 1;
    });
  }

  void _select(int index) {
    if (_answered || _completed) return;
    setState(() => _selected = index);
  }

  void _checkAnswer() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy chọn đáp án trước khi kiểm tra nhé.')),
      );
      return;
    }

    setState(() {
      _answered = true;
      if (_selected == widget.test.questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _next() {
    if (_currentIndex == widget.test.questions.length - 1) {
      _finishTest();
      return;
    }
    setState(() {
      _currentIndex++;
      _selected = null;
      _answered = false;
    });
  }

  Future<void> _finishTest() async {
    if (_completed) return;
    _completed = true;
    _ticker?.cancel();

    final total = widget.test.questions.length;
    final wrong = total - _score;
    final duration = DateTime.now().difference(_startedAt);
    final auth = context.read<AuthProvider>();
    final history = StudyHistory(
      id: const Uuid().v4(),
      userId: auth.currentUser?.uid ?? 'guest',
      testId: widget.test.id,
      title: widget.test.title,
      jlptLevel: widget.test.level,
      totalQuestions: total,
      correctAnswers: _score,
      wrongAnswers: wrong,
      scorePercent: (_score / total) * 100,
      timeTakenSeconds: duration.inSeconds,
      completedAt: DateTime.now(),
    );

    await context.read<StudyHistoryProvider>().addHistory(history);
    context.read<ProgressProvider>().recordTestResult(
          widget.test.level,
          _score,
          total,
          title: widget.test.title,
          mode: 'jlpt',
        );

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(history: history),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.test.questions[_currentIndex];
    final color = AppTheme.jlptColor(widget.test.level);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test.title),
        backgroundColor: color,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _timer,
            builder: (context, value, _) {
              final m = (value ~/ 60).toString().padLeft(2, '0');
              final s = (value % 60).toString().padLeft(2, '0');
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '$m:$s',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Câu ${_currentIndex + 1}/${widget.test.questions.length}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          'Điểm $_score',
                          style: TextStyle(color: color, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / widget.test.questions.length,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    if (question.questionJp.isNotEmpty)
                      Text(
                        question.questionJp,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      question.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final isCorrect = index == question.correctIndex;
                    final isSelected = index == _selected;
                    Color border = Colors.grey.shade300;
                    Color bg = Theme.of(context).cardColor;
                    Color textColor = AppTheme.textDark;

                    if (_answered) {
                      if (isCorrect) {
                        border = AppTheme.successGreen;
                        bg = AppTheme.successGreen.withOpacity(0.1);
                        textColor = AppTheme.successGreen;
                      } else if (isSelected) {
                        border = AppTheme.errorRed;
                        bg = AppTheme.errorRed.withOpacity(0.1);
                        textColor = AppTheme.errorRed;
                      }
                    } else if (isSelected) {
                      border = color;
                      bg = color.withOpacity(0.08);
                      textColor = color;
                    }

                    return GestureDetector(
                      onTap: () => _select(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border, width: 1.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: border.withOpacity(0.18),
                              child: Text(String.fromCharCode(65 + index)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.options[index],
                                    style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
                                  ),
                                  if (_answered && isCorrect) ...[
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Đáp án đúng',
                                      style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.w700),
                                    ),
                                  ] else if (_answered && isSelected) ...[
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Bạn đã chọn',
                                      style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_answered)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giải thích',
                        style: TextStyle(fontWeight: FontWeight.w800, color: color),
                      ),
                      const SizedBox(height: 6),
                      Text(question.explanation, style: const TextStyle(height: 1.4)),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _answered ? _next : _checkAnswer,
                  icon: Icon(_answered ? Icons.arrow_forward_rounded : Icons.verified_rounded),
                  label: Text(
                    _answered
                        ? (_currentIndex == widget.test.questions.length - 1 ? 'Nộp bài' : 'Câu tiếp theo')
                        : 'Kiểm tra đáp án',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final StudyHistory history;
  const _ResultDialog({required this.history});

  @override
  Widget build(BuildContext context) {
    final color = history.scorePercent >= 60 ? AppTheme.successGreen : AppTheme.errorRed;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Kết quả bài test', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            history.jlptLevel,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.jlptColor(history.jlptLevel)),
          ),
          const SizedBox(height: 8),
          Text(history.title, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            '${history.scorePercent.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ScoreBox(label: 'Đúng', value: '${history.correctAnswers}', color: AppTheme.successGreen),
              _ScoreBox(label: 'Sai', value: '${history.wrongAnswers}', color: AppTheme.errorRed),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Kết quả đã được lưu vào lịch sử học tập để bạn xem lại trên dashboard.',
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
      ],
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
