import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/feedback_audio_service.dart';
import '../../services/tts_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class KanaScreen extends StatefulWidget {
  const KanaScreen({super.key});

  @override
  State<KanaScreen> createState() => _KanaScreenState();
}

class _KanaScreenState extends State<KanaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedKana;
  bool _isQuizMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔤 Bảng chữ Kana'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KanaQuizScreen()),
            ),
            child: const Text('Quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Hiragana　ひ'),
            Tab(text: 'Katakana　カ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _KanaTable(
            table: AppConstants.hiraganaTable,
            title: 'Hiragana',
            color: const Color(0xFF6C5CE7),
          ),
          _KanaTable(
            table: AppConstants.katakanaTable,
            title: 'Katakana',
            color: const Color(0xFF00B894),
          ),
        ],
      ),
    );
  }
}

class _KanaTable extends StatefulWidget {
  final Map<String, List<List<String>>> table;
  final String title;
  final Color color;

  const _KanaTable({
    required this.table,
    required this.title,
    required this.color,
  });

  @override
  State<_KanaTable> createState() => _KanaTableState();
}

class _KanaTableState extends State<_KanaTable> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final columns = ['a', 'i', 'u', 'e', 'o'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Bảng chữ ${widget.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          
          Row(
            children: [
              const SizedBox(width: 32),
              ...columns.map((col) => Expanded(
                child: Center(
                  child: Text(
                    col,
                    style: TextStyle(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 8),

          
          ...widget.table.entries.map((entry) {
            final rowKey = entry.key;
            final rows = entry.value;
            return Column(
              children: rows.map((row) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          rowKey == 'vowels' ? '' : rowKey,
                          style: TextStyle(
                            color: widget.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...List.generate(row.length, (i) {
                        final cell = i < row.length ? row[i] : '';
                        if (cell.isEmpty) {
                          return const Expanded(child: SizedBox());
                        }
                        final parts = cell.split('/');
                        final kana = parts[0];
                        final romaji = parts.length > 1 ? parts[1] : '';
                        final isSelected = _selected == kana;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                _selected = isSelected ? null : kana;
                              });
                              await TtsService.instance.speakJapanese(kana, rate: 0.55);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? widget.color
                                    : widget.color.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? widget.color
                                      : widget.color.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    kana,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : widget.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (romaji.isNotEmpty)
                                    Text(
                                      romaji,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? Colors.white70
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


class KanaQuizScreen extends StatefulWidget {
  const KanaQuizScreen({super.key});

  @override
  State<KanaQuizScreen> createState() => _KanaQuizScreenState();
}

class _KanaQuizScreenState extends State<KanaQuizScreen> {
  final List<Map<String, String>> _kanaList = [];
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  List<String> _options = [];
  bool _isHiragana = true;

  @override
  void initState() {
    super.initState();
    _buildKanaList();
    _generateOptions();
  }

  void _buildKanaList() {
    final table = _isHiragana
        ? AppConstants.hiraganaTable
        : AppConstants.katakanaTable;

    for (final rows in table.values) {
      for (final row in rows) {
        for (final cell in row) {
          if (cell.isNotEmpty) {
            final parts = cell.split('/');
            _kanaList.add({'kana': parts[0], 'romaji': parts.length > 1 ? parts[1] : ''});
          }
        }
      }
    }
    _kanaList.shuffle();
    if (_kanaList.length > 20) {
      _kanaList.removeRange(20, _kanaList.length);
    }
  }

  void _generateOptions() {
    if (_currentIndex >= _kanaList.length) return;
    final correct = _kanaList[_currentIndex]['romaji']!;
    final allRomaji = _kanaList.map((k) => k['romaji']!).toSet().toList()
      ..remove(correct)
      ..shuffle();
    final wrongs = allRomaji.take(3).toList();
    _options = [correct, ...wrongs]..shuffle();
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    final isCorrect = answer == _kanaList[_currentIndex]['romaji'];
    setState(() {
      _selectedAnswer = _options.indexOf(answer);
      _answered = true;
      if (isCorrect) _score++;
    });

    if (isCorrect) {
      FeedbackAudioService.instance.playCorrect();
    } else {
      FeedbackAudioService.instance.playWrong();
    }
  }

  void _next() {
    if (_currentIndex < _kanaList.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      _generateOptions();
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Kết quả', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_score / ${_kanaList.length}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text('${(_score / _kanaList.length * 100).toInt()}% đúng'),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_kanaList.isEmpty) return const Scaffold(body: Center(child: Text('Không có dữ liệu')));

    final current = _kanaList[_currentIndex];
    final correct = current['romaji']!;
    final color = _isHiragana ? const Color(0xFF6C5CE7) : const Color(0xFF00B894);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${_isHiragana ? "Hiragana" : "Katakana"}'),
        backgroundColor: color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _kanaList.length,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 8),
            Text('${_currentIndex + 1} / ${_kanaList.length}'),
            const SizedBox(height: 24),

            
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Center(
                child: Text(
                  current['kana']!,
                  style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Âm đọc của chữ này là gì?', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: _options.map((option) {
                final isSelected = _options.indexOf(option) == _selectedAnswer;
                final isCorrectOption = option == correct;

                Color bgColor = Colors.white;
                Color borderColor = Colors.grey.shade200;

                if (_answered) {
                  if (isCorrectOption) {
                    bgColor = AppTheme.successGreen.withOpacity(0.1);
                    borderColor = AppTheme.successGreen;
                  } else if (isSelected) {
                    bgColor = AppTheme.primaryRed.withOpacity(0.1);
                    borderColor = AppTheme.primaryRed;
                  }
                }

                return GestureDetector(
                  onTap: () => _selectAnswer(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_currentIndex < _kanaList.length - 1 ? 'Tiếp theo →' : 'Xem kết quả'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
