import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_task.dart';
import '../models/user_progress.dart';
import '../services/firestore_service.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class ProgressProvider extends ChangeNotifier {
  static const _dailyTasksKey = 'daily_tasks_json';
  static const _dailyTaskDateKey = 'daily_task_date';
  static const _todayXpDateKey = 'today_xp_date';
  static const _progressOwnerKey = 'progress_owner_uid';

  final FirestoreService _firestoreService = FirestoreService();

  UserProgress _progress = UserProgress();
  SharedPreferences? _prefs;
  List<DailyTask> _dailyTasks = [];

  UserProgress get progress => _progress;
  List<DailyTask> get dailyTasks => List.unmodifiable(_dailyTasks);
  int get claimableDailyTaskCount =>
      _dailyTasks.where((task) => task.isCompleted && !task.isClaimed).length;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadProgress();
    final previousOwner = _prefs?.getString(_progressOwnerKey);
    _checkStreak();
    _ensureFreshDailyState();
    final restored = await _restoreRemoteProgressIfAvailable();
    if (!restored && _shouldResetForCurrentUser(previousOwner)) {
      _progress = UserProgress();
      _dailyTasks = _generateDailyTasks(_todayKey());
      await _saveProgress();
    }
    await _syncRemoteProgress();
    notifyListeners();
  }

  void _loadProgress() {
    List<Map<String, dynamic>> decodedHistory = <Map<String, dynamic>>[];
    final rawHistory = _prefs?.getString('test_history_json');
    if (rawHistory != null && rawHistory.isNotEmpty) {
      try {
        decodedHistory = List<Map<String, dynamic>>.from(jsonDecode(rawHistory) as List);
      } catch (_) {
        decodedHistory = <Map<String, dynamic>>[];
      }
    }

    _progress = UserProgress(
      totalXP: _prefs?.getInt(AppConstants.keyXP) ?? 0,
      currentStreak: _prefs?.getInt(AppConstants.keyStreak) ?? 0,
      longestStreak: _prefs?.getInt('longest_streak') ?? 0,
      selectedLevel: _prefs?.getString(AppConstants.keyUserLevel) ?? 'N5',
      dailyGoal: _prefs?.getInt(AppConstants.keyDailyGoal) ?? 50,
      todayXP: _prefs?.getInt('today_xp') ?? 0,
      learnedVocabIds: Set<String>.from(_prefs?.getStringList('learned_vocab') ?? []),
      learnedKanjiIds: Set<String>.from(_prefs?.getStringList('learned_kanji') ?? []),
      favoriteVocabIds: Set<String>.from(_prefs?.getStringList('fav_vocab') ?? []),
      favoriteKanjiIds: Set<String>.from(_prefs?.getStringList('fav_kanji') ?? []),
      unlockedAchievements: Set<String>.from(_prefs?.getStringList('achievements') ?? []),
      testHistory: decodedHistory,
    );

    final lastStudyStr = _prefs?.getString(AppConstants.keyLastStudy);
    if (lastStudyStr != null) {
      _progress.lastStudyDate = DateTime.tryParse(lastStudyStr);
    }

    final rawDailyTasks = _prefs?.getString(_dailyTasksKey);
    if (rawDailyTasks != null && rawDailyTasks.isNotEmpty) {
      try {
        _dailyTasks = List<Map<String, dynamic>>.from(jsonDecode(rawDailyTasks) as List)
            .map(DailyTask.fromMap)
            .toList();
      } catch (_) {
        _dailyTasks = [];
      }
    }
  }

  void _checkStreak() {
    if (_progress.lastStudyDate == null) return;
    final now = DateTime.now();
    final last = _progress.lastStudyDate!;
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    if (diff > 1) {
      _progress.currentStreak = 0;
    }
  }

  void _ensureFreshDailyState() {
    final todayKey = _todayKey();
    final storedXpDay = _prefs?.getString(_todayXpDateKey);
    if (storedXpDay != todayKey) {
      _progress.todayXP = 0;
      _prefs?.setString(_todayXpDateKey, todayKey);
    }

    final storedTaskDay = _prefs?.getString(_dailyTaskDateKey);
    if (storedTaskDay != todayKey || _dailyTasks.isEmpty) {
      _dailyTasks = _generateDailyTasks(todayKey);
      _prefs?.setString(_dailyTaskDateKey, todayKey);
    }

    unawaited(_saveProgress());
  }

  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  List<DailyTask> _generateDailyTasks(String dayKey) {
    final templates = <Map<String, dynamic>>[
      {
        'type': 'earn_xp',
        'icon': '⚡',
        'title': 'Tăng tốc EXP',
        'description': 'Tích lũy 60 EXP trong hôm nay.',
        'target': 60,
        'rewardXp': 30,
      },
      {
        'type': 'earn_xp',
        'icon': '🚀',
        'title': 'Bùng nổ năng lượng',
        'description': 'Kiếm 100 EXP để mở đà học tập.',
        'target': 100,
        'rewardXp': 45,
      },
      {
        'type': 'learn_vocab',
        'icon': '📖',
        'title': 'Thu thập từ mới',
        'description': 'Học 5 từ vựng mới.',
        'target': 5,
        'rewardXp': 25,
      },
      {
        'type': 'learn_vocab',
        'icon': '📝',
        'title': 'Ghi nhớ đều tay',
        'description': 'Đánh dấu 8 từ vựng đã học.',
        'target': 8,
        'rewardXp': 35,
      },
      {
        'type': 'learn_kanji',
        'icon': '🈶',
        'title': 'Kanji mỗi ngày',
        'description': 'Học 3 chữ kanji mới.',
        'target': 3,
        'rewardXp': 35,
      },
      {
        'type': 'complete_test',
        'icon': '🧪',
        'title': 'Làm 1 bài luyện',
        'description': 'Hoàn thành ít nhất 1 bài kiểm tra hoặc bài AI practice.',
        'target': 1,
        'rewardXp': 35,
      },
      {
        'type': 'complete_test',
        'icon': '🎯',
        'title': 'Hai lượt bứt phá',
        'description': 'Hoàn thành 2 lượt luyện bất kỳ.',
        'target': 2,
        'rewardXp': 50,
      },
      {
        'type': 'finish_pronunciation',
        'icon': '🎙️',
        'title': 'Mic check',
        'description': 'Hoàn thành 1 lượt luyện phát âm AI.',
        'target': 1,
        'rewardXp': 30,
      },
      {
        'type': 'finish_writing',
        'icon': '✍️',
        'title': 'Luyện nét đẹp',
        'description': 'Hoàn thành 1 lượt luyện viết AI.',
        'target': 1,
        'rewardXp': 30,
      },
      {
        'type': 'perfect_test',
        'icon': '🏅',
        'title': 'Điểm tuyệt đối',
        'description': 'Đạt 100% trong một lượt luyện hôm nay.',
        'target': 1,
        'rewardXp': 50,
      },
    ];

    final rng = Random(dayKey.hashCode ^ (_progress.totalXP + _progress.currentStreak + 17));
    final pool = [...templates]..shuffle(rng);
    final selected = <DailyTask>[];
    final usedTypes = <String>{};

    for (final template in pool) {
      final type = template['type'] as String;
      if (usedTypes.contains(type) && selected.length < 3) continue;
      usedTypes.add(type);
      selected.add(
        DailyTask(
          id: '${dayKey}_${type}_${selected.length}',
          type: type,
          icon: template['icon'] as String,
          title: template['title'] as String,
          description: template['description'] as String,
          target: template['target'] as int,
          rewardXp: template['rewardXp'] as int,
        ),
      );
      if (selected.length == 3) break;
    }

    return selected;
  }

  Future<void> _saveProgress() async {
    await _prefs?.setInt(AppConstants.keyXP, _progress.totalXP);
    await _prefs?.setInt(AppConstants.keyStreak, _progress.currentStreak);
    await _prefs?.setInt('longest_streak', _progress.longestStreak);
    await _prefs?.setString(AppConstants.keyUserLevel, _progress.selectedLevel);
    await _prefs?.setInt(AppConstants.keyDailyGoal, _progress.dailyGoal);
    await _prefs?.setInt('today_xp', _progress.todayXP);
    await _prefs?.setString(_todayXpDateKey, _todayKey());
    await _prefs?.setStringList('learned_vocab', _progress.learnedVocabIds.toList());
    await _prefs?.setStringList('learned_kanji', _progress.learnedKanjiIds.toList());
    await _prefs?.setStringList('fav_vocab', _progress.favoriteVocabIds.toList());
    await _prefs?.setStringList('fav_kanji', _progress.favoriteKanjiIds.toList());
    await _prefs?.setStringList('achievements', _progress.unlockedAchievements.toList());
    await _prefs?.setString('test_history_json', jsonEncode(_progress.testHistory));
    await _prefs?.setString(_dailyTasksKey, jsonEncode(_dailyTasks.map((task) => task.toMap()).toList()));
    await _prefs?.setString(_dailyTaskDateKey, _todayKey());
    await _prefs?.setString(_progressOwnerKey, FirebaseAuth.instance.currentUser?.uid ?? 'guest');
    if (_progress.lastStudyDate != null) {
      await _prefs?.setString(
        AppConstants.keyLastStudy,
        _progress.lastStudyDate!.toIso8601String(),
      );
    } else {
      await _prefs?.remove(AppConstants.keyLastStudy);
    }
  }

  Future<void> _persist({bool notify = true}) async {
    await _saveProgress();
    unawaited(_syncRemoteProgress());
    if (notify) notifyListeners();
  }

  List<Map<String, dynamic>> get sortedTestHistory {
    final items = [..._progress.testHistory];
    items.sort((a, b) {
      final aDate = DateTime.tryParse((a['date'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse((b['date'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return items;
  }

  Future<void> syncRemoteProgress() => _syncRemoteProgress();


  Future<void> reloadForCurrentUser({bool preferRemote = true}) async {
    _loadProgress();
    final previousOwner = _prefs?.getString(_progressOwnerKey);
    _checkStreak();
    _ensureFreshDailyState();
    var restored = false;
    if (preferRemote) {
      restored = await _restoreRemoteProgressIfAvailable();
    }
    if (!restored && _shouldResetForCurrentUser(previousOwner)) {
      _progress = UserProgress();
      _dailyTasks = _generateDailyTasks(_todayKey());
      await _saveProgress();
    }
    await _syncRemoteProgress();
    notifyListeners();
  }

  Future<void> useGuestState() async {
    _progress = UserProgress();
    _dailyTasks = _generateDailyTasks(_todayKey());
    await _saveProgress();
    notifyListeners();
  }

  Future<bool> _restoreRemoteProgressIfAvailable() async {
    if (!FirebaseService.isEnabled) return false;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    try {
      final remote = await _firestoreService.fetchUserProgressData(currentUser.uid);
      if (remote == null || remote.isEmpty) return false;
      _applyRemoteProgress(remote);
      await _saveProgress();
      return true;
    } catch (_) {
      
      return false;
    }
  }

  void _applyRemoteProgress(Map<String, dynamic> data) {
    List<Map<String, dynamic>> parsedHistory = <Map<String, dynamic>>[];
    final rawHistory = data['testHistory'];
    if (rawHistory is List) {
      parsedHistory = rawHistory
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    _progress = UserProgress(
      totalXP: _readInt(data['totalXP']),
      currentStreak: _readInt(data['currentStreak']),
      longestStreak: _readInt(data['longestStreak']),
      selectedLevel: _readString(data['selectedLevel'], fallback: 'N5'),
      dailyGoal: _readInt(data['dailyGoal'], fallback: 50),
      todayXP: _readInt(data['todayXP']),
      learnedVocabIds: _readStringSet(data['learnedVocabIds']),
      learnedKanjiIds: _readStringSet(data['learnedKanjiIds']),
      favoriteVocabIds: _readStringSet(data['favoriteVocabIds']),
      favoriteKanjiIds: _readStringSet(data['favoriteKanjiIds']),
      unlockedAchievements: _readStringSet(data['unlockedAchievements']),
      testHistory: parsedHistory,
    );

    final lastStudyRaw = data['lastStudyDate'];
    if (lastStudyRaw is String && lastStudyRaw.isNotEmpty) {
      _progress.lastStudyDate = DateTime.tryParse(lastStudyRaw);
    }

    _dailyTasks = [];
    final rawTasks = data['dailyTasks'];
    if (rawTasks is List) {
      _dailyTasks = rawTasks
          .whereType<Map>()
          .map((item) => DailyTask.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    _ensureFreshDailyState();
  }

  int _readInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String _readString(dynamic value, {String fallback = ''}) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return fallback;
  }

  Set<String> _readStringSet(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toSet();
    }
    return <String>{};
  }

  bool _shouldResetForCurrentUser(String? storedOwner) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;
    return storedOwner != null && storedOwner.isNotEmpty && storedOwner != currentUser.uid;
  }

  Map<String, dynamic> _buildRemoteProgressPayload() {
    final history = _progress.testHistory.length <= 250
        ? _progress.testHistory
        : _progress.testHistory.sublist(_progress.testHistory.length - 250);
    return {
      'totalXP': _progress.totalXP,
      'currentStreak': _progress.currentStreak,
      'longestStreak': _progress.longestStreak,
      'selectedLevel': _progress.selectedLevel,
      'dailyGoal': _progress.dailyGoal,
      'todayXP': _progress.todayXP,
      'lastStudyDate': _progress.lastStudyDate?.toIso8601String(),
      'learnedVocabIds': _progress.learnedVocabIds.toList(),
      'learnedKanjiIds': _progress.learnedKanjiIds.toList(),
      'favoriteVocabIds': _progress.favoriteVocabIds.toList(),
      'favoriteKanjiIds': _progress.favoriteKanjiIds.toList(),
      'unlockedAchievements': _progress.unlockedAchievements.toList(),
      'testHistory': history,
      'dailyTasks': _dailyTasks.map((task) => task.toMap()).toList(),
    };
  }

  Future<void> _syncRemoteProgress() async {
    if (!FirebaseService.isEnabled) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await _firestoreService.syncUserProgressStats(
        totalXp: _progress.totalXP,
        currentStreak: _progress.currentStreak,
        longestStreak: _progress.longestStreak,
        learnedVocabCount: _progress.learnedVocabIds.length,
        learnedKanjiCount: _progress.learnedKanjiIds.length,
        achievementCount: _progress.unlockedAchievements.length,
        todayXp: _progress.todayXP,
        userLevel: _progress.userLevel,
        selectedJlptLevel: _progress.selectedLevel,
      );
      await _firestoreService.saveUserProgressData(
        uid: currentUser.uid,
        data: _buildRemoteProgressPayload(),
      );
      final displayName = (currentUser.displayName?.trim().isNotEmpty ?? false)
          ? currentUser.displayName!.trim()
          : (currentUser.email?.split('@').first ?? 'Học viên NihonGo');
      await _firestoreService.syncWeeklyMonthlyLeaderboard(
        uid: currentUser.uid,
        displayName: displayName,
        totalXp: _progress.totalXP,
        currentStreak: _progress.currentStreak,
        userLevel: _progress.userLevel,
        learnedVocabCount: _progress.learnedVocabIds.length,
        learnedKanjiCount: _progress.learnedKanjiIds.length,
        selectedJlptLevel: _progress.selectedLevel,
      );
    } catch (_) {}
  }

  void addXP(int amount, {bool trackDailyTask = true, bool notify = true}) {
    if (amount <= 0) return;
    _ensureFreshDailyState();
    final previousLevel = _progress.userLevel;
    _progress.totalXP += amount;
    _progress.todayXP += amount;
    _updateStudyStreak();
    if (trackDailyTask) {
      _updateDailyTaskProgress('earn_xp', by: amount);
    }
    if (_progress.userLevel > previousLevel) {
      
    }
    unawaited(_persist(notify: notify));
  }

  void _updateStudyStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_progress.lastStudyDate == null) {
      _progress.currentStreak = 1;
      _progress.longestStreak = max(_progress.longestStreak, 1);
      _progress.lastStudyDate = today;
      return;
    }

    final last = DateTime(
      _progress.lastStudyDate!.year,
      _progress.lastStudyDate!.month,
      _progress.lastStudyDate!.day,
    );
    final diff = today.difference(last).inDays;
    if (diff == 0) return;
    if (diff == 1) {
      _progress.currentStreak++;
      _progress.lastStudyDate = today;
      if (_progress.currentStreak > _progress.longestStreak) {
        _progress.longestStreak = _progress.currentStreak;
      }
      if (_progress.currentStreak % 7 == 0) {
        _progress.totalXP += AppConstants.xpDailyStreak;
        _unlockAchievement('streak_7');
      }
      if (_progress.currentStreak >= 30) {
        _unlockAchievement('streak_30');
      }
      return;
    }

    _progress.currentStreak = 1;
    _progress.lastStudyDate = today;
    _progress.longestStreak = max(_progress.longestStreak, 1);
  }

  void _updateDailyTaskProgress(String type, {int by = 1}) {
    if (by <= 0) return;
    _ensureFreshDailyState();
    _dailyTasks = _dailyTasks.map((task) {
      if (task.type != type || task.isClaimed || task.isCompleted) {
        return task;
      }
      final nextProgress = min(task.target, task.progress + by);
      return task.copyWith(progress: nextProgress);
    }).toList();
  }

  Future<bool> claimDailyTask(String taskId) async {
    _ensureFreshDailyState();
    final index = _dailyTasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return false;

    final task = _dailyTasks[index];
    if (!task.isCompleted || task.isClaimed) return false;

    _dailyTasks[index] = task.copyWith(isClaimed: true);
    addXP(task.rewardXp, trackDailyTask: false, notify: false);
    await _persist();
    return true;
  }

  void markVocabLearned(String id) {
    if (_progress.learnedVocabIds.contains(id)) return;
    _progress.learnedVocabIds.add(id);
    _updateDailyTaskProgress('learn_vocab');
    addXP(AppConstants.xpVocabLearn, notify: false);
    _checkVocabAchievements();
    unawaited(_persist());
  }

  void markKanjiLearned(String id) {
    if (_progress.learnedKanjiIds.contains(id)) return;
    _progress.learnedKanjiIds.add(id);
    _updateDailyTaskProgress('learn_kanji');
    addXP(AppConstants.xpKanjiLearn, notify: false);
    if (_progress.learnedKanjiIds.length >= 50) {
      _unlockAchievement('kanji_50');
    }
    unawaited(_persist());
  }

  void toggleFavoriteVocab(String id) {
    if (_progress.favoriteVocabIds.contains(id)) {
      _progress.favoriteVocabIds.remove(id);
    } else {
      _progress.favoriteVocabIds.add(id);
    }
    unawaited(_persist());
  }

  void toggleFavoriteKanji(String id) {
    if (_progress.favoriteKanjiIds.contains(id)) {
      _progress.favoriteKanjiIds.remove(id);
    } else {
      _progress.favoriteKanjiIds.add(id);
    }
    unawaited(_persist());
  }

  void recordTestResult(
    String level,
    int correct,
    int total, {
    String title = 'JLPT Test',
    String mode = 'jlpt',
    double? playbackRate,
  }) {
    if (total <= 0) return;
    _ensureFreshDailyState();

    final score = correct / total * 100;
    addXP(AppConstants.xpTestComplete, notify: false);
    _updateDailyTaskProgress('complete_test');

    if (mode == 'pronunciation_ai') {
      _updateDailyTaskProgress('finish_pronunciation');
    }
    if (mode == 'writing_ai') {
      _updateDailyTaskProgress('finish_writing');
    }

    if (score == 100) {
      addXP(AppConstants.xpPerfectScore, notify: false);
      _updateDailyTaskProgress('perfect_test');
      _unlockAchievement('perfect_test');
    }

    _progress.testHistory.add({
      'level': level,
      'title': title,
      'mode': mode,
      'correct': correct,
      'wrong': total - correct,
      'total': total,
      'score': score,
      'playbackRate': playbackRate,
      'date': DateTime.now().toIso8601String(),
    });
    if (_progress.testHistory.length > 250) {
      _progress.testHistory.removeRange(0, _progress.testHistory.length - 250);
    }

    unawaited(_persist());
  }

  void _checkVocabAchievements() {
    final count = _progress.learnedVocabIds.length;
    if (count >= 1) _unlockAchievement('first_vocab');
    if (count >= 50) _unlockAchievement('vocab_50');
    if (count >= 100) _unlockAchievement('vocab_100');
  }

  void _unlockAchievement(String id) {
    if (_progress.unlockedAchievements.contains(id)) return;
    _progress.unlockedAchievements.add(id);
    final achievement = AppConstants.achievements.firstWhere(
      (a) => a['id'] == id,
      orElse: () => {},
    );
    if (achievement.isNotEmpty) {
      _progress.totalXP += (achievement['xp'] as int? ?? 0);
    }
  }

  void setSelectedLevel(String level) {
    _progress.selectedLevel = level;
    unawaited(_persist());
  }

  void setDailyGoal(int goal) {
    _progress.dailyGoal = goal;
    unawaited(_persist());
  }

  void resetProgress() {
    _progress = UserProgress();
    _dailyTasks = _generateDailyTasks(_todayKey());
    unawaited(_persist());
  }

  bool isVocabLearned(String id) => _progress.learnedVocabIds.contains(id);
  bool isKanjiLearned(String id) => _progress.learnedKanjiIds.contains(id);
  bool isVocabFavorite(String id) => _progress.favoriteVocabIds.contains(id);
  bool isKanjiFavorite(String id) => _progress.favoriteKanjiIds.contains(id);
}
