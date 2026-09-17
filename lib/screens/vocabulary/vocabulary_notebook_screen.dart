import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/community_contribution_section.dart';
import 'notebook_quiz_screen.dart';

class VocabularyNotebookScreen extends StatefulWidget {
  const VocabularyNotebookScreen({super.key});

  @override
  State<VocabularyNotebookScreen> createState() => _VocabularyNotebookScreenState();
}

class _VocabularyNotebookScreenState extends State<VocabularyNotebookScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLevel = 'Tất cả';
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VocabularyProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<VocabularyProvider, ProgressProvider, SettingsProvider>(
      builder: (context, vocab, progress, settings, _) {
        final favoriteIds = progress.progress.favoriteVocabIds;
        final favorites = vocab.allWords.where((word) {
          if (!favoriteIds.contains(word.id)) return false;
          if (_selectedLevel != 'Tất cả' && word.jlptLevel != _selectedLevel) {
            return false;
          }
          if (_query.isEmpty) return true;
          final q = _query.toLowerCase();
          return word.japanese.contains(_query) ||
              word.hiragana.contains(_query) ||
              word.romaji.toLowerCase().contains(q) ||
              word.vietnamese.toLowerCase().contains(q) ||
              word.english.toLowerCase().contains(q);
        }).toList()
          ..sort((a, b) {
            final levelCompare = a.jlptLevel.compareTo(b.jlptLevel);
            if (levelCompare != 0) return levelCompare;
            return a.japanese.compareTo(b.japanese);
          });

        return Scaffold(
          appBar: AppBar(
            title: const Text('📒 Sổ tay từ vựng'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7EB6), Color(0xFF9B6BFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${favoriteIds.length} từ đã lưu',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Những từ bạn đánh dấu yêu thích sẽ luôn hiện lại ở đây để ôn tập nhanh.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.textLight.withOpacity(0.4)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value.trim()),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Tìm trong sổ tay yêu thích...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ['Tất cả', 'N5', 'N4', 'N3', 'N2', 'N1'].map((level) {
                          final selected = _selectedLevel == level;
                          final color = level == 'Tất cả'
                              ? AppTheme.primaryDark
                              : AppTheme.jlptColor(level);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () => setState(() => _selectedLevel = level),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected ? color : color.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: color.withOpacity(0.24)),
                                ),
                                child: Text(
                                  level,
                                  style: TextStyle(
                                    color: selected ? Colors.white : color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Hiển thị ${favorites.length} / ${favoriteIds.length} từ',
                            style: const TextStyle(
                              color: AppTheme.textMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (favorites.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _selectedLevel = 'Tất cả';
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Đặt lại'),
                          ),
                      ],
                    ),
                    if (favorites.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: favorites.length < 4
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NotebookQuizScreen(
                                        words: favorites,
                                        title: _selectedLevel == 'Tất cả'
                                            ? 'Quiz sổ tay từ vựng'
                                            : 'Quiz sổ tay ${_selectedLevel}',
                                        levelLabel: _selectedLevel == 'Tất cả'
                                            ? 'Sổ tay tổng hợp'
                                            : 'Sổ tay ${_selectedLevel}',
                                      ),
                                    ),
                                  ),
                          icon: const Icon(Icons.quiz_rounded),
                          label: Text(
                            favorites.length < 4
                                ? 'Cần ít nhất 4 từ để tạo quiz'
                                : 'Làm quiz riêng cho sổ tay',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: !vocab.isInitialized && vocab.allWords.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : favorites.isEmpty
                        ? _EmptyNotebook(
                            hasAnyFavorite: favoriteIds.isNotEmpty,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              final word = favorites[index];
                              final levelColor = AppTheme.jlptColor(word.jlptLevel);
                              final isLearned = progress.isVocabLearned(word.id);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  onTap: () => _showWordDetail(context, word),
                                  leading: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: levelColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        word.japanese,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: levelColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: word.japanese.length > 3 ? 13 : 17,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      Text(
                                        word.hiragana,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: levelColor,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          word.jlptLevel,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      Text(
                                        settings.showVietnamese ? word.vietnamese : word.english,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        word.romaji,
                                        style: const TextStyle(
                                          color: AppTheme.textMedium,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () => progress.toggleFavoriteVocab(word.id),
                                        icon: const Icon(
                                          Icons.favorite_rounded,
                                          color: AppTheme.primaryRed,
                                        ),
                                        tooltip: 'Bỏ khỏi sổ tay',
                                      ),
                                      if (isLearned)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppTheme.successGreen,
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWordDetail(BuildContext context, VocabularyWord word) {
    final levelColor = AppTheme.jlptColor(word.jlptLevel);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: levelColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: levelColor.withOpacity(0.24)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            word.japanese,
                            style: TextStyle(
                              fontSize: 46,
                              color: levelColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            word.hiragana,
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppTheme.textMedium,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            word.romaji,
                            style: const TextStyle(
                              color: AppTheme.textMedium,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DetailTile(label: '🇻🇳 Nghĩa', value: word.vietnamese),
                  _DetailTile(label: '🇬🇧 English', value: word.english),
                  _DetailTile(label: '🏷 Danh mục', value: word.category),
                  if (word.exampleSentences.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Ví dụ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(word.exampleSentences.length, (index) {
                      final translation = index < word.exampleTranslations.length
                          ? word.exampleTranslations[index]
                          : '';
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: levelColor.withOpacity(0.18)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.exampleSentences[index],
                              style: TextStyle(
                                color: levelColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (translation.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                translation,
                                style: const TextStyle(
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 20),
                  CommunityContributionSection(
                    itemType: 'vocabulary',
                    itemId: word.id,
                    accentColor: levelColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyNotebook extends StatelessWidget {
  final bool hasAnyFavorite;

  const _EmptyNotebook({required this.hasAnyFavorite});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppTheme.primaryRed,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasAnyFavorite ? 'Không có từ phù hợp' : 'Sổ tay đang trống',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasAnyFavorite
                  ? 'Hãy đổi bộ lọc hoặc từ khóa tìm kiếm để xem lại từ đã lưu.'
                  : 'Khi bạn nhấn tim ở danh sách từ vựng, các từ yêu thích sẽ tự động xuất hiện trong sổ tay này.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMedium,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;

  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
