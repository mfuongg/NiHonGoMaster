import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../data/kanji_data.dart';
import '../../models/kanji.dart';
import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../utils/theme.dart';
import '../vocabulary/flashcard_screen.dart';
import '../vocabulary/listening_practice_screen.dart';
import '../vocabulary/pronunciation_practice_screen.dart';
import '../vocabulary/vocabulary_quiz_screen.dart';
import '../vocabulary/word_matching_screen.dart';
import '../vocabulary/writing_practice_screen.dart';

class KanjiScreen extends StatefulWidget {
  const KanjiScreen({super.key});

  @override
  State<KanjiScreen> createState() => _KanjiScreenState();
}

class _KanjiScreenState extends State<KanjiScreen> {
  static const List<String> _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  final TextEditingController _searchController = TextEditingController();
  String _selectedLevel = 'N5';
  String _searchQuery = '';
  List<KanjiItem> _displayedKanji = [];

  @override
  void initState() {
    super.initState();
    _loadKanji();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadKanji() {
    setState(() {
      _displayedKanji = _searchQuery.trim().isEmpty
          ? KanjiData.getKanjiByLevel(_selectedLevel)
          : KanjiData.search(_searchQuery);
    });
  }

  List<VocabularyWord> _practiceWordsForLevel() {
    return KanjiData.getPracticeWordsByLevel(_selectedLevel, limit: 24);
  }

  void _openPractice(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _openKanjiPractice(String mode) {
    final words = _practiceWordsForLevel();
    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có bộ từ luyện kanji cho cấp độ này.')),
      );
      return;
    }

    final titlePrefix = switch (mode) {
      'flashcard' => '🈶 Flashcard Kanji',
      'quiz' => '🈶 Quiz Kanji',
      'listening' => '🈶 Luyện nghe Kanji',
      'pronunciation' => '🈶 Phát âm Kanji',
      'matching' => '🈶 Nối từ Kanji',
      _ => '🈶 Luyện viết Kanji',
    };
    final title = '$titlePrefix $_selectedLevel';

    switch (mode) {
      case 'flashcard':
        _openPractice(FlashcardScreen(level: _selectedLevel, words: words, title: title));
        break;
      case 'quiz':
        _openPractice(VocabularyQuizScreen(level: _selectedLevel, words: words, title: title));
        break;
      case 'listening':
        _openPractice(ListeningPracticeScreen(level: _selectedLevel, words: words, title: title));
        break;
      case 'pronunciation':
        _openPractice(PronunciationPracticeScreen(level: _selectedLevel, words: words, title: title));
        break;
      case 'matching':
        _openPractice(WordMatchingScreen(level: _selectedLevel, words: words, title: title));
        break;
      case 'writing':
        _openPractice(WritingPracticeScreen(level: _selectedLevel, words: words, title: title));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progress, _) {
        final currentLevelColor = AppTheme.jlptColor(_selectedLevel);
        final practiceCount = _practiceWordsForLevel().length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('🈶 Kanji'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(108),
              child: Container(
                color: AppTheme.primaryRed,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _levels.map((level) {
                          final isSelected = _selectedLevel == level;
                          final kanjiList = KanjiData.getKanjiByLevel(level);
                          final learned = kanjiList
                              .where((k) => progress.isKanjiLearned(k.id))
                              .length;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedLevel = level);
                                _loadKanji();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$level ($learned/${kanjiList.length})',
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.jlptColor(level)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.96),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.55)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (q) {
                          _searchQuery = q;
                          _loadKanji();
                        },
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm kanji hoặc từ vựng kanji...',
                          hintStyle: TextStyle(color: AppTheme.textMedium),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.textMedium,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Hiển thị ${_displayedKanji.length} mục • Bộ luyện có $practiceCount từ kanji',
                            style: const TextStyle(
                              color: AppTheme.textMedium,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _KanjiPracticePanel(
                      level: _selectedLevel,
                      count: practiceCount,
                      color: currentLevelColor,
                      onFlashcard: () => _openKanjiPractice('flashcard'),
                      onQuiz: () => _openKanjiPractice('quiz'),
                      onListening: () => _openKanjiPractice('listening'),
                      onPronunciation: () => _openKanjiPractice('pronunciation'),
                      onMatching: () => _openKanjiPractice('matching'),
                      onWriting: () => _openKanjiPractice('writing'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _displayedKanji.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryDark.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Icon(
                                  Icons.translate_rounded,
                                  color: AppTheme.primaryDark,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Chưa tìm thấy kanji phù hợp',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hãy thử từ khóa khác hoặc đổi cấp độ JLPT nhé.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : AnimationLimiter(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.8,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: _displayedKanji.length,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              columnCount: 3,
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: _KanjiCard(
                                    kanji: _displayedKanji[index],
                                    isLearned: progress.isKanjiLearned(
                                      _displayedKanji[index].id,
                                    ),
                                    onTap: () => _showKanjiDetail(
                                      context,
                                      _displayedKanji[index],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showKanjiDetail(BuildContext context, KanjiItem kanji) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KanjiDetailSheet(kanji: kanji),
    );
  }
}

class _KanjiPracticePanel extends StatelessWidget {
  final String level;
  final int count;
  final Color color;
  final VoidCallback onFlashcard;
  final VoidCallback onQuiz;
  final VoidCallback onListening;
  final VoidCallback onPronunciation;
  final VoidCallback onMatching;
  final VoidCallback onWriting;

  const _KanjiPracticePanel({
    required this.level,
    required this.count,
    required this.color,
    required this.onFlashcard,
    required this.onQuiz,
    required this.onListening,
    required this.onPronunciation,
    required this.onMatching,
    required this.onWriting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Luyện Kanji $level',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$count từ',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Đầy đủ flashcard, quiz, luyện nghe, phát âm, nối từ và luyện viết cho bộ kanji của cấp độ đang chọn.',
            style: TextStyle(color: AppTheme.textMedium, height: 1.45),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PracticeShortcut(label: 'Flashcard', icon: Icons.style_rounded, color: const Color(0xFFE74C3C), onTap: onFlashcard),
              _PracticeShortcut(label: 'Quiz', icon: Icons.quiz_rounded, color: const Color(0xFF3498DB), onTap: onQuiz),
              _PracticeShortcut(label: 'Nghe', icon: Icons.headphones_rounded, color: const Color(0xFFF39C12), onTap: onListening),
              _PracticeShortcut(label: 'Phát âm', icon: Icons.mic_rounded, color: const Color(0xFF8E44AD), onTap: onPronunciation),
              _PracticeShortcut(label: 'Nối từ', icon: Icons.hub_rounded, color: const Color(0xFF00BCD4), onTap: onMatching),
              _PracticeShortcut(label: 'Viết', icon: Icons.edit_rounded, color: const Color(0xFF27AE60), onTap: onWriting),
            ],
          ),
        ],
      ),
    );
  }
}

class _PracticeShortcut extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PracticeShortcut({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanjiCard extends StatelessWidget {
  final KanjiItem kanji;
  final bool isLearned;
  final VoidCallback onTap;

  const _KanjiCard({
    required this.kanji,
    required this.isLearned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.jlptColor(kanji.jlptLevel);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isLearned
              ? Border.all(color: AppTheme.successGreen, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLearned)
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 8, top: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.successGreen,
                    size: 16,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                kanji.kanji,
                style: TextStyle(
                  fontSize: kanji.kanji.length > 2 ? 26 : 44,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                kanji.vietnamese.split(',').first.trim(),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                (kanji.exampleReadings.isNotEmpty
                        ? kanji.exampleReadings.first
                        : kanji.kunyomi.isEmpty
                            ? kanji.onyomi.split('、').first
                            : kanji.kunyomi.split('、').first)
                    .trim(),
                style: TextStyle(fontSize: 11, color: color),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanjiDetailSheet extends StatelessWidget {
  final KanjiItem kanji;
  const _KanjiDetailSheet({required this.kanji});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.jlptColor(kanji.jlptLevel);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            kanji.kanji,
                            style: TextStyle(
                              fontSize: kanji.kanji.length > 2 ? 40 : 90,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _InfoChip(label: kanji.jlptLevel, color: color),
                      const SizedBox(width: 8),
                      _InfoChip(label: '${kanji.strokeCount} ký tự', color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle('Cách đọc'),
                  Row(
                    children: [
                      Expanded(
                        child: _ReadingBox(
                          label: 'Kana',
                          reading: kanji.onyomi.isEmpty ? '-' : kanji.onyomi,
                          color: const Color(0xFF6C5CE7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ReadingBox(
                          label: 'Romaji / Gợi nhớ',
                          reading: kanji.kunyomi.isEmpty ? '-' : kanji.kunyomi,
                          color: const Color(0xFF00B894),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle('Ý nghĩa'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🇻🇳 ${kanji.vietnamese}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '🇬🇧 ${kanji.english}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (kanji.radicalMeaning.isNotEmpty)
                          Text(
                            '🔑 ${kanji.radicalMeaning}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (kanji.exampleWords.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle('Từ ví dụ'),
                    ...List.generate(kanji.exampleWords.length, (i) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(left: BorderSide(color: color, width: 3)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              kanji.exampleWords[i],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (i < kanji.exampleReadings.length)
                                    Text(
                                      kanji.exampleReadings[i],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  if (i < kanji.exampleMeanings.length)
                                    Text(
                                      kanji.exampleMeanings[i],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 24),
                  Consumer<ProgressProvider>(
                    builder: (context, progress, _) {
                      final isLearned = progress.isKanjiLearned(kanji.id);
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (!isLearned) progress.markKanjiLearned(kanji.id);
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            isLearned ? Icons.check_circle : Icons.school,
                          ),
                          label: Text(
                            isLearned ? 'Đã học ✓' : 'Đánh dấu đã học',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isLearned ? AppTheme.successGreen : color,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _SectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _InfoChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _ReadingBox({
    required String label,
    required String reading,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reading,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
