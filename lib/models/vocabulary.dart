class VocabularyWord {
  final String id;
  final String japanese;
  final String hiragana;
  final String romaji;
  final String vietnamese;
  final String english;
  final String jlptLevel;
  final String category;
  final List<String> exampleSentences;
  final List<String> exampleTranslations;
  bool isLearned;
  bool isFavorite;
  int correctCount;
  int wrongCount;
  DateTime? lastStudied;
  int srsInterval; 

  VocabularyWord({
    required this.id,
    required this.japanese,
    required this.hiragana,
    required this.romaji,
    required this.vietnamese,
    required this.english,
    required this.jlptLevel,
    required this.category,
    this.exampleSentences = const [],
    this.exampleTranslations = const [],
    this.isLearned = false,
    this.isFavorite = false,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.lastStudied,
    this.srsInterval = 1,
  });

  double get accuracy {
    final total = correctCount + wrongCount;
    if (total == 0) return 0;
    return correctCount / total * 100;
  }

  bool get needsReview {
    if (!isLearned) return false;
    if (lastStudied == null) return true;
    final nextReview = lastStudied!.add(Duration(days: srsInterval));
    return DateTime.now().isAfter(nextReview);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'japanese': japanese,
      'hiragana': hiragana,
      'romaji': romaji,
      'vietnamese': vietnamese,
      'english': english,
      'jlptLevel': jlptLevel,
      'category': category,
      'exampleSentences': exampleSentences,
      'exampleTranslations': exampleTranslations,
      'isLearned': isLearned ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'lastStudied': lastStudied?.toIso8601String(),
      'srsInterval': srsInterval,
    };
  }

  VocabularyWord copyWith({
    String? id,
    String? japanese,
    String? hiragana,
    String? romaji,
    String? vietnamese,
    String? english,
    String? jlptLevel,
    String? category,
    List<String>? exampleSentences,
    List<String>? exampleTranslations,
    bool? isLearned,
    bool? isFavorite,
    int? correctCount,
    int? wrongCount,
    DateTime? lastStudied,
    int? srsInterval,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      japanese: japanese ?? this.japanese,
      hiragana: hiragana ?? this.hiragana,
      romaji: romaji ?? this.romaji,
      vietnamese: vietnamese ?? this.vietnamese,
      english: english ?? this.english,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      category: category ?? this.category,
      exampleSentences: exampleSentences ?? this.exampleSentences,
      exampleTranslations: exampleTranslations ?? this.exampleTranslations,
      isLearned: isLearned ?? this.isLearned,
      isFavorite: isFavorite ?? this.isFavorite,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      lastStudied: lastStudied ?? this.lastStudied,
      srsInterval: srsInterval ?? this.srsInterval,
    );
  }
}


class VocabularyCategory {
  final String id;
  final String name;
  final String nameVi;
  final String icon;
  final int wordCount;

  const VocabularyCategory({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.icon,
    required this.wordCount,
  });
}
