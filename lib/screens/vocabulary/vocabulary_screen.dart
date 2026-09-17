import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/community_contribution_section.dart';
import 'flashcard_screen.dart';
import 'listening_practice_screen.dart';
import 'pronunciation_practice_screen.dart';
import 'vocabulary_quiz_screen.dart';
import 'vocabulary_notebook_screen.dart';
import 'word_matching_screen.dart';
import 'writing_practice_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLevel = 'N5';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vocab = context.read<VocabularyProvider>();
      vocab.ensureLoaded();
      vocab.setLevel(_selectedLevel);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openPracticeMode(
    Widget Function(List<VocabularyWord> words) builder,
  ) async {
    final vocab = context.read<VocabularyProvider>();
    await vocab.ensureLoaded();
    final words = List<VocabularyWord>.from(
      vocab.getWordsForFlashcard(_selectedLevel),
    );

    if (!mounted) return;
    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chưa có dữ liệu từ vựng ${_selectedLevel} để bắt đầu luyện tập.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => builder(words)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabularyProvider>(
      builder: (context, vocab, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('📖 Từ vựng'),
            actions: [
              IconButton(
                tooltip: 'Sổ tay từ vựng',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VocabularyNotebookScreen(),
                  ),
                ),
                icon: const Icon(Icons.menu_book_rounded),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(170),
              child: Container(
                color: AppTheme.primaryRed,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['N5', 'N4', 'N3', 'N2', 'N1'].map((level) {
                          final isSelected = _selectedLevel == level;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedLevel = level);
                                vocab.setLevel(level);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  level,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.jlptColor(level)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
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
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.96),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.55)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: vocab.setSearchQuery,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm từ vựng...',
                          hintStyle: TextStyle(color: AppTheme.textMedium),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.textMedium,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCategoryScroller(vocab),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Column(
                  children: [
                    
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.style_rounded,
                            label: 'Flashcard',
                            color: AppTheme.primaryRed,
                            onTap: () => _openPracticeMode(
                              (words) => FlashcardScreen(
                                level: _selectedLevel,
                                words: words,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.quiz,
                            label: 'Quiz',
                            color: AppTheme.accentBlue,
                            onTap: () => _openPracticeMode(
                              (words) => VocabularyQuizScreen(
                                level: _selectedLevel,
                                words: words,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.headphones_rounded,
                            label: 'Luyện nghe',
                            color: AppTheme.accentOrange,
                            onTap: () => _openPracticeMode(
                              (words) => ListeningPracticeScreen(
                                level: _selectedLevel,
                                words: words,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.record_voice_over_rounded,
                            label: 'Phát âm',
                            color: const Color(0xFF8B5CF6),
                            onTap: () => _openPracticeMode(
                              (words) => PronunciationPracticeScreen(
                                level: _selectedLevel,
                                words: words,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.link_rounded,
                            label: 'Nối từ',
                            color: const Color(0xFF0891B2),
                            onTap: () => _openPracticeMode(
                              (words) => WordMatchingScreen(
                                level: _selectedLevel,
                                words: words,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.draw_rounded,
                            label: 'Luyện viết',
                            color: const Color(0xFF059669),
                            onTap: () => _openPracticeMode(
                              (words) => WritingPracticeScreen(
                                level: _selectedLevel,
                                words: words,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tổng ${vocab.getTotalCount(_selectedLevel)} từ • đang hiển thị ${vocab.words.length} từ • yêu thích ${context.watch<ProgressProvider>().progress.favoriteVocabIds.length}',
                        style: const TextStyle(
                          color: AppTheme.textMedium,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (vocab.isSyncing)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Đang đồng bộ',
                          style: TextStyle(
                            color: AppTheme.accentBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: !vocab.isInitialized && vocab.words.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Đang tải danh sách từ vựng...'),
                          ],
                        ),
                      )
                    : vocab.words.isEmpty
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
                                      color: AppTheme.primaryRed.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: const Icon(
                                      Icons.menu_book_rounded,
                                      color: AppTheme.primaryRed,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Chưa tìm thấy từ phù hợp',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Hãy thử đổi cấp độ, danh mục hoặc từ khóa tìm kiếm khác nhé.',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : AnimationLimiter(
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              physics: const BouncingScrollPhysics(),
                              itemCount: vocab.words.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50,
                                    child: FadeInAnimation(
                                      child: _VocabCard(word: vocab.words[index]),
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

  Widget _buildCategoryScroller(VocabularyProvider vocab) {
    return SizedBox(
      height: 44,
      child: Scrollbar(
        thumbVisibility: vocab.categories.length > 5,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: vocab.categories.length,
          itemBuilder: (context, index) {
            final cat = vocab.categories[index];
            final isSelected = vocab.selectedCategory == cat;
            return Padding(
              padding: EdgeInsets.only(
                right: index == vocab.categories.length - 1 ? 0 : 8,
              ),
              child: GestureDetector(
                onTap: () => vocab.setCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.26),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _categoryName(cat),
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.jlptColor(_selectedLevel)
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _categoryName(String cat) {
    const names = {
      'all': 'Tất cả',
      'pronouns': 'Đại từ',
      'verbs': 'Động từ',
      'adjectives': 'Tính từ',
      'nouns': 'Danh từ',
      'places': 'Địa điểm',
      'people': 'Con người',
      'food': 'Thức ăn',
      'time': 'Thời gian',
      'numbers': 'Số đếm',
      'colors': 'Màu sắc',
      'family': 'Gia đình',
      'animals': 'Động vật',
      'nature': 'Thiên nhiên',
      'transport': 'Giao thông',
      'seasons': 'Mùa',
      'greetings': 'Chào hỏi',
      'common': 'Phổ biến',
      'objects': 'Đồ vật',
      'weather': 'Thời tiết',
      'hobbies': 'Sở thích',
      'countries': 'Quốc gia',
      'question_words': 'Từ hỏi',
      'directions': 'Phương hướng',
      'school': 'Trường học',
      'work': 'Công việc',
      'language': 'Ngôn ngữ',
      'study': 'Học tập',
      'communication': 'Giao tiếp',
      'health': 'Sức khỏe',
      'feelings': 'Cảm xúc',
      'personality': 'Tính cách',
      'attitude': 'Thái độ',
      'life': 'Cuộc sống',
      'society': 'Xã hội',
      'activities': 'Hoạt động',
      'household': 'Gia đình',
    };
    return names[cat] ?? cat;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VocabCard extends StatelessWidget {
  final VocabularyWord word;

  const _VocabCard({required this.word});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProgressProvider, SettingsProvider>(
      builder: (context, progress, settings, _) {
        final isLearned = progress.isVocabLearned(word.id);
        final isFavorite = progress.isVocabFavorite(word.id);
        final levelColor = AppTheme.jlptColor(word.jlptLevel);

        return GestureDetector(
          onTap: () => _showWordDetail(context, word),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: isLearned
                  ? Border.all(color: AppTheme.successGreen.withOpacity(0.5))
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    word.japanese,
                    style: TextStyle(
                      fontSize: word.japanese.length > 2 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    word.hiragana,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(width: 6),
                  if (settings.showRomaji)
                    Expanded(
                      child: Text(
                        '(${word.romaji})',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                settings.showVietnamese ? word.vietnamese : word.english,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              trailing: SizedBox(
                width: isLearned ? 96 : 76,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isLearned)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.successGreen,
                        size: 20,
                      ),
                    if (isLearned) const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _showContributionSheet(context, word),
                      child: Icon(
                        Icons.forum_outlined,
                        color: levelColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => progress.toggleFavoriteVocab(word.id),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppTheme.primaryRed : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWordDetail(BuildContext context, VocabularyWord word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WordDetailSheet(word: word),
    );
  }

  void _showContributionSheet(BuildContext context, VocabularyWord word) {
    final levelColor = AppTheme.jlptColor(word.jlptLevel);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.62,
        minChildSize: 0.42,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: levelColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          word.japanese,
                          style: TextStyle(
                            color: levelColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đóng góp cho từ vựng này',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${word.hiragana} • ${word.vietnamese}',
                              style: const TextStyle(
                                color: AppTheme.textMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CommunityContributionSection(
                    itemType: 'vocabulary',
                    itemId: word.id,
                    accentColor: levelColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WordDetailSheet extends StatelessWidget {
  final VocabularyWord word;
  const _WordDetailSheet({required this.word});

  @override
  Widget build(BuildContext context) {
    final levelColor = AppTheme.jlptColor(word.jlptLevel);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: levelColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                word.japanese,
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: levelColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                word.hiragana,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                word.romaji,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade400,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _DetailRow('🇻🇳 Tiếng Việt', word.vietnamese),
                      const SizedBox(height: 8),
                      _DetailRow('🇬🇧 English', word.english),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: levelColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              word.jlptLevel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              word.category,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      if (word.exampleSentences.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        const Text(
                          '📝 Ví dụ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(word.exampleSentences.length, (i) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border(
                                left: BorderSide(color: levelColor, width: 3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word.exampleSentences[i],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: levelColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (i < word.exampleTranslations.length)
                                  Text(
                                    word.exampleTranslations[i],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 22),
                      CommunityContributionSection(
                        itemType: 'vocabulary',
                        itemId: word.id,
                        accentColor: levelColor,
                      ),
                      const SizedBox(height: 24),
                      Consumer<ProgressProvider>(
                        builder: (context, progress, _) {
                          final isLearned = progress.isVocabLearned(word.id);
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (!isLearned) {
                                  progress.markVocabLearned(word.id);
                                }
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                isLearned ? Icons.check_circle : Icons.school,
                              ),
                              label: Text(
                                isLearned ? 'Đã học ✓' : 'Đánh dấu đã học',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLearned
                                    ? AppTheme.successGreen
                                    : AppTheme.primaryRed,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
