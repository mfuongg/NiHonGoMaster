import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _allTimeEntries = [];
  List<Map<String, dynamic>> _weeklyEntries = [];
  List<Map<String, dynamic>> _monthlyEntries = [];

  int? _myAllRank;
  int? _myWeeklyRank;
  int? _myMonthlyRank;

  bool _weeklyRewardAvailable = false;
  bool _monthlyRewardAvailable = false;
  bool _claimingWeekly = false;
  bool _claimingMonthly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? get _myUid => context.read<AuthProvider>().currentUser?.uid;

  int? _rankOf(List<Map<String, dynamic>> list, String? uid) {
    if (uid == null) return null;
    final idx = list.indexWhere((e) => e['uid'] == uid);
    return idx < 0 ? null : idx + 1;
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      try {
        await context
            .read<ProgressProvider>()
            .syncRemoteProgress()
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        
      }

      final results = await Future.wait([
        _firestoreService.fetchLeaderboard(limit: 100),
        _firestoreService.fetchWeeklyLeaderboard(limit: 100),
        _firestoreService.fetchMonthlyLeaderboard(limit: 100),
      ]);

      if (!mounted) return;
      _allTimeEntries = results[0];
      _weeklyEntries = results[1];
      _monthlyEntries = results[2];

      final uid = _myUid;
      _myAllRank = _rankOf(_allTimeEntries, uid);
      _myWeeklyRank = _rankOf(_weeklyEntries, uid);
      _myMonthlyRank = _rankOf(_monthlyEntries, uid);

      await _checkRewards(uid);
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _checkRewards(String? uid) async {
    if (uid == null) return;
    final wk = FirestoreService.currentWeekKey;
    final mk = FirestoreService.currentMonthKey;
    final hasW = await _firestoreService.hasClaimedRankReward(uid: uid, period: 'weekly', periodKey: wk);
    final hasM = await _firestoreService.hasClaimedRankReward(uid: uid, period: 'monthly', periodKey: mk);
    if (!mounted) return;
    setState(() {
      _weeklyRewardAvailable = !hasW && (_myWeeklyRank ?? 999) <= 50;
      _monthlyRewardAvailable = !hasM && (_myMonthlyRank ?? 999) <= 50;
    });
  }

  static int _rankXp(int rank, {required bool weekly}) {
    final m = weekly ? 1 : 3;
    if (rank == 1) return 500 * m;
    if (rank == 2) return 300 * m;
    if (rank == 3) return 200 * m;
    if (rank <= 10) return 100 * m;
    if (rank <= 50) return 50 * m;
    return 0;
  }

  Future<void> _claimWeekly() async {
    final uid = _myUid;
    final rank = _myWeeklyRank;
    if (uid == null || rank == null || _claimingWeekly) return;
    setState(() => _claimingWeekly = true);
    try {
      final xp = _rankXp(rank, weekly: true);
      await _firestoreService.claimRankReward(
        uid: uid, period: 'weekly',
        periodKey: FirestoreService.currentWeekKey, rank: rank, xpReward: xp,
      );
      context.read<ProgressProvider>().addXP(xp);
      if (!mounted) return;
      setState(() { _weeklyRewardAvailable = false; _claimingWeekly = false; });
      _showRewardDialog('🏆 Thưởng tuần!', 'Hạng #$rank tuần này', xp);
    } catch (_) {
      if (mounted) setState(() => _claimingWeekly = false);
    }
  }

  Future<void> _claimMonthly() async {
    final uid = _myUid;
    final rank = _myMonthlyRank;
    if (uid == null || rank == null || _claimingMonthly) return;
    setState(() => _claimingMonthly = true);
    try {
      final xp = _rankXp(rank, weekly: false);
      await _firestoreService.claimRankReward(
        uid: uid, period: 'monthly',
        periodKey: FirestoreService.currentMonthKey, rank: rank, xpReward: xp,
      );
      context.read<ProgressProvider>().addXP(xp);
      if (!mounted) return;
      setState(() { _monthlyRewardAvailable = false; _claimingMonthly = false; });
      _showRewardDialog('🎊 Thưởng tháng!', 'Hạng #$rank tháng này', xp);
    } catch (_) {
      if (mounted) setState(() => _claimingMonthly = false);
    }
  }

  void _showRewardDialog(String title, String subtitle, int xp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFC857), Color(0xFFFF9F1C)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('+$xp EXP',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          Text(subtitle, style: const TextStyle(fontSize: 16)),
        ]),
        actions: [TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Tuyệt vời! 🎉', style: TextStyle(fontWeight: FontWeight.w800)),
        )],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final progress = context.watch<ProgressProvider>().progress;
    final levelIdx = progress.userLevel < 0
        ? 0
        : progress.userLevel >= AppConstants.userLevels.length
            ? AppConstants.userLevels.length - 1
            : progress.userLevel;
    final levelData = AppConstants.userLevels[levelIdx];

    if (!FirebaseService.isEnabled) {
      return Scaffold(
        appBar: AppBar(title: const Text('🏆 Bảng xếp hạng EXP'),
            backgroundColor: AppTheme.primaryRed, foregroundColor: Colors.white),
        body: const Center(child: Padding(padding: EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('☁️', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text('Bật Firebase để xem bảng xếp hạng', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        title: const Text('🏆 Bảng xếp hạng EXP',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAll,
            tooltip: 'Làm mới',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppTheme.accentGold,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '🌐 Tổng'),
            Tab(text: '📅 Tuần'),
            Tab(text: '📆 Tháng'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorState(message: _errorMessage!, onRetry: _loadAll)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTab(
                      entries: _allTimeEntries,
                      myRank: _myAllRank,
                      progress: progress,
                      levelData: levelData,
                      auth: auth,
                      period: 'all',
                    ),
                    _buildTab(
                      entries: _weeklyEntries,
                      myRank: _myWeeklyRank,
                      progress: progress,
                      levelData: levelData,
                      auth: auth,
                      period: 'weekly',
                      rewardAvailable: _weeklyRewardAvailable,
                      onClaimReward: _claimWeekly,
                      isClaiming: _claimingWeekly,
                    ),
                    _buildTab(
                      entries: _monthlyEntries,
                      myRank: _myMonthlyRank,
                      progress: progress,
                      levelData: levelData,
                      auth: auth,
                      period: 'monthly',
                      rewardAvailable: _monthlyRewardAvailable,
                      onClaimReward: _claimMonthly,
                      isClaiming: _claimingMonthly,
                    ),
                  ],
                ),
    );
  }

  Widget _buildTab({
    required List<Map<String, dynamic>> entries,
    required int? myRank,
    required dynamic progress,
    required Map<String, dynamic> levelData,
    required dynamic auth,
    required String period,
    bool rewardAvailable = false,
    VoidCallback? onClaimReward,
    bool isClaiming = false,
  }) {
    final xpReward = period != 'all' && myRank != null
        ? _rankXp(myRank, weekly: period == 'weekly')
        : 0;

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _MyRankCard(
            displayName: auth.currentUser?.displayName ?? 'Học viên NihonGo',
            rank: myRank,
            totalXp: progress.totalXP,
            streak: progress.currentStreak,
            levelName: levelData['name'] as String,
            levelIcon: levelData['icon'] as String,
            learnedVocab: progress.learnedVocabIds.length,
            learnedKanji: progress.learnedKanjiIds.length,
            period: period,
            xpReward: xpReward,
            rewardAvailable: rewardAvailable,
            onClaimReward: onClaimReward,
            isClaiming: isClaiming,
          ),
          const SizedBox(height: 12),
          if (period != 'all') _RewardInfoBanner(isWeekly: period == 'weekly'),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const _EmptyState(
              icon: '🌱',
              title: 'Chưa có dữ liệu',
              message: 'Hãy học vài bài để xuất hiện trên bảng xếp hạng!',
            )
          else ...List.generate(entries.length, (i) {
            final entry = entries[i];
            final isMe = entry['uid'] == _myUid;
            return _LeaderboardTile(rank: i + 1, entry: entry, isCurrentUser: isMe);
          }),
        ],
      ),
    );
  }
}


class _MyRankCard extends StatelessWidget {
  final String displayName;
  final int? rank;
  final int totalXp;
  final int streak;
  final String levelName;
  final String levelIcon;
  final int learnedVocab;
  final int learnedKanji;
  final String period;
  final int xpReward;
  final bool rewardAvailable;
  final VoidCallback? onClaimReward;
  final bool isClaiming;

  const _MyRankCard({
    required this.displayName,
    required this.rank,
    required this.totalXp,
    required this.streak,
    required this.levelName,
    required this.levelIcon,
    required this.learnedVocab,
    required this.learnedKanji,
    required this.period,
    required this.xpReward,
    this.rewardAvailable = false,
    this.onClaimReward,
    this.isClaiming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7AA2), Color(0xFF7B5CF6), Color(0xFF3FA7D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(child: Text(levelIcon, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Thành tích của bạn',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(displayName, style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(levelName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                const Text('Hạng', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(rank == null ? '—' : '#$rank',
                    style: const TextStyle(color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w900)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _StatBadge(label: 'EXP', value: '$totalXp')),
            const SizedBox(width: 10),
            Expanded(child: _StatBadge(label: 'Streak', value: '$streak ngày')),
            const SizedBox(width: 10),
            Expanded(child: _StatBadge(label: 'Từ / Kanji', value: '$learnedVocab / $learnedKanji')),
          ]),
          
          if (rewardAvailable && period != 'all') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC857),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isClaiming ? null : onClaimReward,
                icon: isClaiming
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.card_giftcard_rounded),
                label: Text(
                  isClaiming
                      ? 'Đang nhận...'
                      : '🎁 Nhận thưởng hạng ${rank == null ? "" : "#$rank"} (+$xpReward EXP)',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _RewardInfoBanner extends StatelessWidget {
  final bool isWeekly;
  const _RewardInfoBanner({required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEB),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          isWeekly ? '🏆 Thưởng xếp hạng tuần' : '🎊 Thưởng xếp hạng tháng',
          style: TextStyle(fontWeight: FontWeight.w800,
              color: AppTheme.accentGold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        _row('🥇 Hạng 1', isWeekly ? '+500 EXP' : '+1500 EXP'),
        _row('🥈 Hạng 2', isWeekly ? '+300 EXP' : '+900 EXP'),
        _row('🥉 Hạng 3', isWeekly ? '+200 EXP' : '+600 EXP'),
        _row('🏅 Top 10', isWeekly ? '+100 EXP' : '+300 EXP'),
        _row('⭐ Top 50', isWeekly ? '+50 EXP' : '+150 EXP'),
      ]),
    );
  }

  Widget _row(String left, String right) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(left, style: const TextStyle(fontSize: 13)),
      Text(right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          color: AppTheme.accentGold)),
    ]),
  );
}


class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> entry;
  final bool isCurrentUser;

  const _LeaderboardTile({required this.rank, required this.entry, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final medal = switch (rank) { 1 => '🥇', 2 => '🥈', 3 => '🥉', _ => '#$rank' };
    final rawLevel = entry['userLevel'] as int? ?? 0;
    final levelIdx = rawLevel < 0
        ? 0
        : rawLevel >= AppConstants.userLevels.length
            ? AppConstants.userLevels.length - 1
            : rawLevel;
    final levelData = AppConstants.userLevels[levelIdx];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppTheme.primaryRed.withOpacity(0.08) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrentUser ? AppTheme.primaryRed.withOpacity(0.28) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(children: [
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            color: _rankColor(rank).withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Text(medal, style: TextStyle(
            fontWeight: FontWeight.w900, color: _rankColor(rank),
            fontSize: rank <= 3 ? 22 : 16,
          ))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(
                entry['displayName'] as String? ?? 'Học viên NihonGo',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              )),
              if (isCurrentUser)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Bạn', style: TextStyle(
                      color: AppTheme.primaryRed, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
            ]),
            const SizedBox(height: 3),
            Text('${levelData['icon']} ${levelData['name']} • JLPT ${entry['selectedJlptLevel'] ?? 'N5'}',
                style: const TextStyle(color: AppTheme.textMedium, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _InfoPill(label: '${entry['totalXp'] ?? 0} EXP', color: AppTheme.accentGold),
              _InfoPill(label: '🔥 ${entry['streak'] ?? 0} ngày', color: AppTheme.warningOrange),
              _InfoPill(label: '📚 ${entry['learnedVocabCount'] ?? 0}', color: AppTheme.primaryRed),
              _InfoPill(label: '🈶 ${entry['learnedKanjiCount'] ?? 0}', color: AppTheme.accentBlue),
            ]),
          ]),
        ),
      ]),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFF4B400);
    if (rank == 2) return const Color(0xFF9AA5B1);
    if (rank == 3) return const Color(0xFFC97B47);
    return AppTheme.primaryDark;
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.w900, fontSize: 14)),
      ]),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String message;
  const _EmptyState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 44)),
        const SizedBox(height: 10),
        Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMedium, height: 1.5)),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('⚠️', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          const Text('Không tải được bảng xếp hạng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMedium)),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ]),
      ),
    );
  }
}
