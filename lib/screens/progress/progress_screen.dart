import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/study_history.dart';
import '../../models/user_progress.dart';
import '../../providers/progress_provider.dart';
import '../../providers/study_history_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _dateFilter = '30d';
  String _modeFilter = 'all';
  String _levelFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProgressProvider, StudyHistoryProvider>(
      builder: (context, progressProvider, historyProvider, _) {
        final progress = progressProvider.progress;
        final safeLevelIndex = progress.userLevel < 0
            ? 0
            : progress.userLevel >= AppConstants.userLevels.length
                ? AppConstants.userLevels.length - 1
                : progress.userLevel;
        final levelData = AppConstants.userLevels[safeLevelIndex];
        final clampedLevelProgress = progress.levelProgress.clamp(0.0, 1.0).toDouble();
        final allEntries = _buildEntries(progress, historyProvider.histories, progressProvider.sortedTestHistory);
        final filteredEntries = allEntries.where(_matchesFilters).toList();
        final weeklyBars = _buildWeeklyBars(allEntries);
        final averageScore = filteredEntries.isEmpty
            ? 0
            : filteredEntries.map((e) => e.score).reduce((a, b) => a + b) / filteredEntries.length;

        return Scaffold(
          appBar: AppBar(title: const Text('📊 Dashboard tiến độ')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF93D1), Color(0xFF8B5CF6), Color(0xFF57B6FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(levelData['icon'] as String, style: const TextStyle(fontSize: 30)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                levelData['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '🔥 Chuỗi ${progress.currentStreak} ngày • ${progress.totalXP} XP',
                                style: TextStyle(color: Colors.white.withOpacity(0.92), fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Tiến độ cấp độ',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                ),
                              ),
                              Text(
                                '${(clampedLevelProgress * 100).round()}%',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: clampedLevelProgress,
                              minHeight: 12,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFF0A8)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Còn ${progress.xpForNextLevel} XP để lên cấp tiếp theo',
                                  style: TextStyle(color: Colors.white.withOpacity(0.92)),
                                ),
                              ),
                              Text(
                                '🎯 ${progress.todayXP}/${progress.dailyGoal}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.18,
                children: [
                  _StatCard(title: 'Từ vựng đã nhớ', value: '${progress.learnedVocabIds.length}', subtitle: 'Tăng dần theo flashcard', emoji: '📚', color: AppTheme.primaryRed),
                  _StatCard(title: 'Kanji đã học', value: '${progress.learnedKanjiIds.length}', subtitle: 'Tiếp tục giữ nhịp nhé', emoji: '🈶', color: AppTheme.n4Color),
                  _StatCard(title: 'Hoạt động đã lưu', value: '${allEntries.length}', subtitle: 'JLPT + nghe + quiz', emoji: '🗂️', color: AppTheme.accentBlue),
                  _StatCard(title: 'Điểm trung bình', value: '${averageScore.round()}%', subtitle: filteredEntries.isEmpty ? 'Chưa có dữ liệu lọc' : 'Theo bộ lọc hiện tại', emoji: '⭐', color: AppTheme.accentGold),
                ],
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Nhịp học 7 ngày gần đây',
                icon: '📈',
                child: weeklyBars.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Chưa có dữ liệu hoạt động trong tuần này.'),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: weeklyBars.map((bar) {
                          final maxCount = max(1, weeklyBars.map((e) => e.count).reduce(max));
                          final height = 26 + (84 * (bar.count / maxCount));
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${bar.count}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: height,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [AppTheme.primaryRed, AppTheme.accentBlue.withOpacity(0.8)],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(bar.label, style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Thành tích',
                icon: '🏆',
                trailing: Text('${progress.unlockedAchievements.length}/${AppConstants.achievements.length}', style: const TextStyle(fontWeight: FontWeight.w800)),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConstants.achievements.map((achievement) {
                    final unlocked = progress.unlockedAchievements.contains(achievement['id']);
                    return _AchievementChip(
                      title: achievement['title'] as String,
                      desc: achievement['desc'] as String,
                      emoji: achievement['icon'] as String,
                      unlocked: unlocked,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Lịch sử chi tiết',
                icon: '🧾',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lọc theo thời gian'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoice('7 ngày', '7d', _dateFilter, (v) => setState(() => _dateFilter = v)),
                        _buildChoice('30 ngày', '30d', _dateFilter, (v) => setState(() => _dateFilter = v)),
                        _buildChoice('Tất cả', 'all', _dateFilter, (v) => setState(() => _dateFilter = v)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Lọc theo chế độ'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoice('Tất cả', 'all', _modeFilter, (v) => setState(() => _modeFilter = v)),
                        _buildChoice('JLPT', 'jlpt', _modeFilter, (v) => setState(() => _modeFilter = v)),
                        _buildChoice('Listening', 'listening', _modeFilter, (v) => setState(() => _modeFilter = v)),
                        _buildChoice('Quiz', 'quiz', _modeFilter, (v) => setState(() => _modeFilter = v)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Lọc theo cấp độ'),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChoice('Tất cả', 'all', _levelFilter, (v) => setState(() => _levelFilter = v)),
                          const SizedBox(width: 8),
                          ...AppConstants.jlptLevels.map((level) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildChoice(level, level, _levelFilter, (v) => setState(() => _levelFilter = v)),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (historyProvider.isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                    else if (filteredEntries.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text('Không có lịch sử phù hợp với bộ lọc hiện tại.'),
                      )
                    else
                      ...filteredEntries.map((entry) => _HistoryTile(entry: entry)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _matchesFilters(_HistoryEntry entry) {
    final now = DateTime.now();
    final dayDiff = now.difference(entry.completedAt).inDays;
    final bool dateMatch;
    if (_dateFilter == '7d') {
      dateMatch = dayDiff <= 7;
    } else if (_dateFilter == '30d') {
      dateMatch = dayDiff <= 30;
    } else {
      dateMatch = true;
    }
    final modeMatch = _modeFilter == 'all' || entry.mode == _modeFilter;
    final levelMatch = _levelFilter == 'all' || entry.level == _levelFilter;
    return dateMatch && modeMatch && levelMatch;
  }

  List<_HistoryEntry> _buildEntries(
    UserProgress progress,
    List<StudyHistory> studyHistories,
    List<Map<String, dynamic>> fallbackMaps,
  ) {
    final entries = <_HistoryEntry>[
      ...studyHistories.map(_HistoryEntry.fromStudyHistory),
      ...fallbackMaps.map(_HistoryEntry.fromMap),
    ]..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final seen = <String>{};
    return entries.where((entry) {
      final key = '${entry.title}|${entry.completedAt.toIso8601String()}|${entry.score.toStringAsFixed(1)}';
      return seen.add(key);
    }).toList();
  }

  List<_DayBar> _buildWeeklyBars(List<_HistoryEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - DateTime.monday));
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      final count = entries.where((entry) {
        final d = entry.completedAt;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).length;
      return _DayBar(label: labels[index], count: count);
    });
  }

  Widget _buildChoice(String label, String value, String selected, ValueChanged<String> onChanged) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == value,
      onSelected: (_) => onChanged(value),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String emoji;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
        ],
      ),
    );
  }
}

class _AchievementChip extends StatelessWidget {
  final String title;
  final String desc;
  final String emoji;
  final bool unlocked;

  const _AchievementChip({
    required this.title,
    required this.desc,
    required this.emoji,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? AppTheme.accentGold.withOpacity(0.12) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? AppTheme.accentGold.withOpacity(0.28) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: unlocked ? AppTheme.textDark : AppTheme.textMedium,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 8),
          Text(
            unlocked ? 'Đã mở khóa' : 'Chưa mở khóa',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: unlocked ? AppTheme.accentGold : AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final _HistoryEntry entry;

  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: entry.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: entry.color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: entry.color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(entry.badge, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '${entry.score.round()}%',
                      style: TextStyle(fontWeight: FontWeight.w900, color: entry.color),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniTag(label: entry.level, color: entry.color),
                    _MiniTag(label: entry.modeLabel, color: entry.color),
                    _MiniTag(label: '${entry.correct}/${entry.total} đúng', color: AppTheme.textMedium),
                  ],
                ),
                const SizedBox(height: 8),
                if (entry.subtitle.isNotEmpty) Text(entry.subtitle),
                const SizedBox(height: 6),
                Text(
                  DateFormat('dd/MM/yyyy • HH:mm').format(entry.completedAt),
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _HistoryEntry {
  final String title;
  final String subtitle;
  final String level;
  final String mode;
  final String badge;
  final Color color;
  final int correct;
  final int total;
  final double score;
  final DateTime completedAt;

  const _HistoryEntry({
    required this.title,
    required this.subtitle,
    required this.level,
    required this.mode,
    required this.badge,
    required this.color,
    required this.correct,
    required this.total,
    required this.score,
    required this.completedAt,
  });

  String get modeLabel {
    switch (mode) {
      case 'listening':
        return 'Listening';
      case 'quiz':
        return 'Quiz';
      case 'flashcard':
        return 'Flashcard';
      default:
        return 'JLPT';
    }
  }

  static _HistoryEntry fromStudyHistory(StudyHistory item) {
    final mode = _inferMode(item.title, item.testId);
    return _HistoryEntry(
      title: item.title,
      subtitle: mode == 'listening' ? 'Luyện nghe câu đã lưu vào lịch sử.' : 'Kết quả làm bài JLPT đã được lưu.',
      level: item.jlptLevel,
      mode: mode,
      badge: _badgeFor(mode),
      color: mode == 'listening' ? AppTheme.accentBlue : AppTheme.jlptColor(item.jlptLevel),
      correct: item.correctAnswers,
      total: item.totalQuestions,
      score: item.scorePercent,
      completedAt: item.completedAt,
    );
  }

  static _HistoryEntry fromMap(Map<String, dynamic> map) {
    final mode = _inferMode((map['title'] ?? '').toString(), (map['mode'] ?? '').toString());
    final level = (map['level'] ?? 'N5').toString();
    final correct = (map['correct'] as num? ?? 0).toInt();
    final total = (map['total'] as num? ?? 0).toInt();
    return _HistoryEntry(
      title: (map['title'] ?? 'Hoạt động học').toString(),
      subtitle: mode == 'listening' && map['playbackRate'] != null
          ? 'Tốc độ nghe ${(map['playbackRate'] as num).toStringAsFixed(2)}x'
          : 'Lưu từ tiến độ cục bộ',
      level: level,
      mode: mode,
      badge: _badgeFor(mode),
      color: mode == 'listening' ? AppTheme.accentBlue : AppTheme.jlptColor(level),
      correct: correct,
      total: total,
      score: (map['score'] as num? ?? 0).toDouble(),
      completedAt: DateTime.tryParse((map['date'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static String _inferMode(String title, String rawMode) {
    if (rawMode.isNotEmpty) return rawMode;
    final normalized = title.toLowerCase();
    if (normalized.contains('nghe') || normalized.contains('listening')) return 'listening';
    if (normalized.contains('quiz')) return 'quiz';
    if (normalized.contains('flash')) return 'flashcard';
    return 'jlpt';
  }

  static String _badgeFor(String mode) {
    switch (mode) {
      case 'listening':
        return '🎧';
      case 'quiz':
        return '❓';
      case 'flashcard':
        return '🪪';
      default:
        return '📝';
    }
  }
}

class _DayBar {
  final String label;
  final int count;

  const _DayBar({required this.label, required this.count});
}
