class UserProgress {
  int totalXP;
  int currentStreak;
  int longestStreak;
  DateTime? lastStudyDate;
  Set<String> learnedVocabIds;
  Set<String> learnedKanjiIds;
  Set<String> favoriteVocabIds;
  Set<String> favoriteKanjiIds;
  Set<String> unlockedAchievements;
  List<Map<String, dynamic>> testHistory;
  String selectedLevel;
  int dailyGoal;
  int todayXP;
  Map<String, int> categoryProgress;

  UserProgress({
    this.totalXP = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    Set<String>? learnedVocabIds,
    Set<String>? learnedKanjiIds,
    Set<String>? favoriteVocabIds,
    Set<String>? favoriteKanjiIds,
    Set<String>? unlockedAchievements,
    List<Map<String, dynamic>>? testHistory,
    this.selectedLevel = 'N5',
    this.dailyGoal = 50,
    this.todayXP = 0,
    Map<String, int>? categoryProgress,
  })  : learnedVocabIds = learnedVocabIds ?? {},
        learnedKanjiIds = learnedKanjiIds ?? {},
        favoriteVocabIds = favoriteVocabIds ?? {},
        favoriteKanjiIds = favoriteKanjiIds ?? {},
        unlockedAchievements = unlockedAchievements ?? {},
        testHistory = testHistory ?? [],
        categoryProgress = categoryProgress ?? {};

  int get userLevel {
    if (totalXP >= 5000) return 7;
    if (totalXP >= 3500) return 6;
    if (totalXP >= 2000) return 5;
    if (totalXP >= 1000) return 4;
    if (totalXP >= 600) return 3;
    if (totalXP >= 300) return 2;
    if (totalXP >= 100) return 1;
    return 0;
  }

  int get xpForNextLevel {
    const thresholds = [100, 300, 600, 1000, 2000, 3500, 5000, 10000];
    if (userLevel >= thresholds.length) return thresholds.last;
    return thresholds[userLevel];
  }

  double get levelProgress {
    const thresholds = [0, 100, 300, 600, 1000, 2000, 3500, 5000];
    if (userLevel >= 7) return 1.0;
    final currentMin = thresholds[userLevel];
    final nextMin = xpForNextLevel;
    return (totalXP - currentMin) / (nextMin - currentMin);
  }

  double get dailyProgress {
    return (todayXP / dailyGoal).clamp(0.0, 1.0);
  }

  bool get isStreakAlive {
    if (lastStudyDate == null) return false;
    final now = DateTime.now();
    final diff = now.difference(lastStudyDate!).inDays;
    return diff <= 1;
  }
}
