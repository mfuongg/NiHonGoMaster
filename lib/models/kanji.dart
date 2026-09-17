class KanjiItem {
  final String id;
  final String kanji;
  final String onyomi;
  final String kunyomi;
  final String vietnamese;
  final String english;
  final int strokeCount;
  final String jlptLevel;
  final List<String> exampleWords;
  final List<String> exampleReadings;
  final List<String> exampleMeanings;
  final String radicalMeaning;
  bool isLearned;
  bool isFavorite;
  int correctCount;
  int wrongCount;

  KanjiItem({
    required this.id,
    required this.kanji,
    required this.onyomi,
    required this.kunyomi,
    required this.vietnamese,
    required this.english,
    required this.strokeCount,
    required this.jlptLevel,
    this.exampleWords = const [],
    this.exampleReadings = const [],
    this.exampleMeanings = const [],
    this.radicalMeaning = '',
    this.isLearned = false,
    this.isFavorite = false,
    this.correctCount = 0,
    this.wrongCount = 0,
  });

  double get accuracy {
    final total = correctCount + wrongCount;
    if (total == 0) return 0;
    return correctCount / total * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isLearned': isLearned ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
    };
  }
}
