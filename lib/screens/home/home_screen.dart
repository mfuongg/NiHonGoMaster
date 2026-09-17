import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/bgm_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../dictionary/dictionary_screen.dart';
import '../grammar/grammar_screen.dart';
import '../jlpt/jlpt_screen.dart';
import '../kana/kana_screen.dart';
import '../kanji/kanji_screen.dart';
import '../progress/progress_screen.dart';
import '../read/read_screen.dart';
import '../settings/settings_screen.dart';
import 'leaderboard_screen.dart';
import '../vocabulary/vocabulary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool? _lastSoundEnabled;

  List<Widget> get _screens => [
    HomeTab(
      onOpenRead: () => setState(() => _currentIndex = 1),
      onOpenVocabulary: () => setState(() => _currentIndex = 2),
      onOpenKanji: () => setState(() => _currentIndex = 3),
      onOpenJlpt: () => setState(() => _currentIndex = 4),
    ),
    const ReadScreen(),
    const VocabularyScreen(),
    const KanjiScreen(),
    const JLPTScreen(),
    const ProgressScreen(),
  ];

  void _syncMusic(bool enabled) {
    if (_lastSoundEnabled == enabled) return;
    _lastSoundEnabled = enabled;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (enabled) {
        await BgmService.instance.playStudyMusic();
      } else {
        await BgmService.instance.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final soundEnabled = context.watch<SettingsProvider>().soundEnabled;
    _syncMusic(soundEnabled);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  current: _currentIndex,
                  onTap: () => setState(() => _currentIndex = 0)),
              _NavItem(
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories_rounded,
                  label: 'Read',
                  index: 1,
                  current: _currentIndex,
                  onTap: () => setState(() => _currentIndex = 1)),
              _NavItem(
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  label: 'Từ vựng',
                  index: 2,
                  current: _currentIndex,
                  onTap: () => setState(() => _currentIndex = 2)),
              _NavItem(
                  icon: Icons.translate_outlined,
                  activeIcon: Icons.translate_rounded,
                  label: 'Kanji',
                  index: 3,
                  current: _currentIndex,
                  onTap: () => setState(() => _currentIndex = 3)),
              _NavItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school_rounded,
                  label: 'JLPT',
                  index: 4,
                  current: _currentIndex,
                  onTap: () => setState(() => _currentIndex = 4)),
              _NavItem(
                  icon: Icons.insights_outlined,
                  activeIcon: Icons.insights_rounded,
                  label: 'Tiến độ',
                  index: 5,
                  current: _currentIndex,
                  onTap: () => setState(() => _currentIndex = 5)),
            ],
          ),
        ),
      ),
    );
  }
}




class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    final color = isActive ? AppTheme.primaryRed : AppTheme.textMedium;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryRed.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class HomeTab extends StatelessWidget {
  final VoidCallback? onOpenRead;
  final VoidCallback? onOpenVocabulary;
  final VoidCallback? onOpenKanji;
  final VoidCallback? onOpenJlpt;

  const HomeTab({
    super.key,
    this.onOpenRead,
    this.onOpenVocabulary,
    this.onOpenKanji,
    this.onOpenJlpt,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProgressProvider, AuthProvider>(
      builder: (context, progressProvider, auth, _) {
        final p = progressProvider.progress;
        final safeLevelIndex = p.userLevel < 0
            ? 0
            : p.userLevel >= AppConstants.userLevels.length
                ? AppConstants.userLevels.length - 1
                : p.userLevel;
        final levelData = AppConstants.userLevels[safeLevelIndex];
        final displayName =
            (auth.currentUser?.displayName ?? 'Học viên').trim();
        final firstName = displayName.isEmpty
            ? 'Học viên'
            : displayName.split(' ').last;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              
              SliverToBoxAdapter(
                child: _HeroHeader(
                  firstName: firstName,
                  p: p,
                  levelData: levelData,
                ),
              ),

              
              const SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.fromLTRB(18, 22, 18, 10),
                  child: Text(
                    '🎀 Chọn nhanh chế độ học',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  delegate: SliverChildListDelegate([
                    _QuickCard(
                      title: 'Read',
                      subtitle: '100 bài đọc N5 → N1',
                      emoji: '📚',
                      color: AppTheme.primaryDark,
                      onTap: onOpenRead ??
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ReadScreen(),
                                ),
                              ),
                    ),
                    _QuickCard(
                      title: 'Từ vựng',
                      subtitle: 'Flashcard · Quiz · Nghe',
                      emoji: '📖',
                      color: AppTheme.primaryRed,
                      onTap: onOpenVocabulary ??
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const VocabularyScreen(),
                                ),
                              ),
                    ),
                    _QuickCard(
                      title: 'Kanji',
                      subtitle: 'Âm On · Âm Kun · Ví dụ',
                      emoji: '🈶',
                      color: AppTheme.accentBlue,
                      onTap: onOpenKanji ??
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const KanjiScreen(),
                                ),
                              ),
                    ),
                    _QuickCard(
                      title: 'JLPT',
                      subtitle: 'Đề N5 · N4 · N3',
                      emoji: '📝',
                      color: AppTheme.n4Color,
                      onTap: onOpenJlpt ??
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const JLPTScreen(),
                                ),
                              ),
                    ),
                    _QuickCard(
                      title: 'Kana',
                      subtitle: 'Hiragana · Katakana',
                      emoji: '🔤',
                      color: AppTheme.accentBlue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const KanaScreen()),
                      ),
                    ),
                    _QuickCard(
                      title: 'Ngữ pháp',
                      subtitle: 'Mẫu câu dễ nhớ',
                      emoji: '🧩',
                      color: AppTheme.accentOrange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const GrammarScreen()),
                      ),
                    ),
                  ]),
                ),
              ),

              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          emoji: '🎯',
                          title: 'Mục tiêu hôm nay',
                          value: '${p.todayXP}/${p.dailyGoal} XP',
                          subtitle:
                              '${(p.dailyProgress * 100).round()}% hoàn thành',
                          color: AppTheme.warningOrange,
                          progress: p.dailyProgress,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          emoji: '🏆',
                          title: 'Thành tích',
                          value:
                              '${p.unlockedAchievements.length} huy hiệu',
                          subtitle: p.unlockedAchievements.isEmpty
                              ? 'Bắt đầu mở khóa nào!'
                              : 'Đang làm rất tốt! 🌟',
                          color: AppTheme.accentGold,
                          progress: null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          emoji: '📚',
                          label: 'Từ vựng',
                          value: '${p.learnedVocabIds.length}',
                          color: AppTheme.primaryRed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatChip(
                          emoji: '🈳',
                          label: 'Kanji',
                          value: '${p.learnedKanjiIds.length}',
                          color: AppTheme.n3Color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatChip(
                          emoji: '🔥',
                          label: 'Streak',
                          value: '${p.currentStreak} ngày',
                          color: AppTheme.warningOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SectionTitleRow(
                    title: '🏆 Thi đua EXP',
                    actionLabel: 'Xem bảng xếp hạng',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: _LeaderboardPreviewCard(
                    p: p,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    ),
                  ),
                ),
              ),

              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _SectionTitleRow(
                    title: '🎯 Nhiệm vụ hôm nay',
                    actionLabel: progressProvider.claimableDailyTaskCount > 0
                        ? '${progressProvider.claimableDailyTaskCount} phần thưởng chờ nhận'
                        : 'Reset khi sang ngày mới',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: _DailyTasksPanel(progressProvider: progressProvider),
                ),
              ),

              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _StudyTipCard(p: p),
                ),
              ),

              
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        );
      },
    );
  }
}




class _HeroHeader extends StatelessWidget {
  final String firstName;
  final dynamic p;
  final Map<String, dynamic> levelData;

  const _HeroHeader({
    required this.firstName,
    required this.p,
    required this.levelData,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        
        Container(
          height: 300,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6B9D),
                Color(0xFF7B5CF6),
                Color(0xFF4DA8DA),
              ],
            ),
          ),
        ),
        
        Positioned(
          top: -40,
          right: -30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 60,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: -20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        
        Positioned(
          top: 60,
          right: 20,
          child: Text('🌸', style: TextStyle(fontSize: 22, color: Colors.white.withOpacity(0.6))),
        ),
        Positioned(
          top: 100,
          right: 80,
          child: Text('✨', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5))),
        ),
        Positioned(
          bottom: 60,
          right: 30,
          child: Text('⭐', style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.4))),
        ),
        
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'こんにちは, $firstName 👋',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Học gọn · Đẹp · Vui ✨',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconBtn(
                      icon: Icons.search_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DictionaryScreen()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HeaderIconBtn(
                      icon: Icons.settings_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${levelData['icon']} ${levelData['name']}',
                              style: const TextStyle(
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '⚡ ${p.totalXP} XP',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Stack(
                          children: [
                            FractionallySizedBox(
                              widthFactor:
                                  p.levelProgress.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFF0A8),
                                      Color(0xFFFFC857)
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Còn ${p.xpForNextLevel} XP lên cấp',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '🔥 ${p.currentStreak} ngày streak',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VocabularyScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF6B9D),
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.play_circle_fill_rounded,
                            size: 20),
                        label: const Text(
                          'Bắt đầu học',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProgressScreen()),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                              color: Colors.white54, width: 1.5),
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.insights_rounded, size: 20),
                        label: const Text(
                          'Dashboard',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}




class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}




class _QuickCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.18), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}




class _MiniStatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final double? progress;

  const _MiniStatCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w600,
                fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textMedium)),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}




class _StatChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.w900, color: color, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textMedium),
          ),
        ],
      ),
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _SectionTitleRow({
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = actionLabel != null && onTap != null;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: canTap ? AppTheme.primaryRed : AppTheme.textMedium,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _LeaderboardPreviewCard extends StatelessWidget {
  final dynamic p;
  final VoidCallback onTap;

  const _LeaderboardPreviewCard({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final safeLevelIndex = p.userLevel < 0
        ? 0
        : p.userLevel >= AppConstants.userLevels.length
            ? AppConstants.userLevels.length - 1
            : p.userLevel;
    final levelData = AppConstants.userLevels[safeLevelIndex];
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7AA2), Color(0xFF7B5CF6), Color(0xFF4DA8DA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRed.withOpacity(0.14),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(levelData['icon'] as String, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chạm để xem bảng xếp hạng',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${p.totalXP} EXP · ${levelData['name']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'So tài với người học khác và theo dõi vị trí của bạn trong app.',
                        style: TextStyle(color: Colors.white.withOpacity(0.84), height: 1.4),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _LeaderboardMiniStat(label: 'Streak', value: '${p.currentStreak} ngày'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LeaderboardMiniStat(label: 'Từ vựng', value: '${p.learnedVocabIds.length}'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LeaderboardMiniStat(label: 'Kanji', value: '${p.learnedKanjiIds.length}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardMiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _LeaderboardMiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _DailyTasksPanel extends StatelessWidget {
  final ProgressProvider progressProvider;

  const _DailyTasksPanel({required this.progressProvider});

  @override
  Widget build(BuildContext context) {
    final tasks = progressProvider.dailyTasks;
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Text('Chưa có nhiệm vụ hôm nay.'),
      );
    }

    return Column(
      children: tasks.map((task) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _DailyTaskCard(
            task: task,
            onClaim: task.isCompleted && !task.isClaimed
                ? () async {
                    final ok = await progressProvider.claimDailyTask(task.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Đã nhận ${task.rewardXp} EXP từ nhiệm vụ "${task.title}".'
                              : 'Nhiệm vụ này chưa thể nhận thưởng.',
                        ),
                      ),
                    );
                  }
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _DailyTaskCard extends StatelessWidget {
  final dynamic task;
  final Future<void> Function()? onClaim;

  const _DailyTaskCard({required this.task, this.onClaim});

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted as bool;
    final claimed = task.isClaimed as bool;
    final accent = claimed
        ? AppTheme.textMedium
        : completed
            ? AppTheme.successGreen
            : AppTheme.primaryDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(task.icon as String, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description as String,
                      style: const TextStyle(color: AppTheme.textMedium, height: 1.4),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '+${task.rewardXp} EXP',
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: task.completionRate as double,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${task.progress}/${task.target}',
                style: TextStyle(color: accent, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (claimed)
                const Text(
                  'Đã nhận thưởng',
                  style: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.w800),
                )
              else if (completed)
                ElevatedButton.icon(
                  onPressed: onClaim == null ? null : () => onClaim!(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.redeem_rounded, size: 18),
                  label: const Text('Nhận EXP'),
                )
              else
                Text(
                  'Tiếp tục học để hoàn thành',
                  style: TextStyle(color: accent.withOpacity(0.85), fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ],
      ),
    );
  }
}




class _StudyTipCard extends StatelessWidget {
  final dynamic p;
  const _StudyTipCard({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentMint.withOpacity(0.3),
            AppTheme.accentBlue.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppTheme.accentMint.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.accentMint.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('🌸', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gợi ý học nhanh',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  p.currentStreak >= 3
                      ? '🔥 Streak ${p.currentStreak} ngày! Thử làm thêm 1 đề JLPT ${p.selectedLevel} nhé!'
                      : '💡 Bắt đầu bằng 10 từ vựng + 1 bài nghe để vào guồng nhé.',
                  style: const TextStyle(
                      height: 1.4, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
