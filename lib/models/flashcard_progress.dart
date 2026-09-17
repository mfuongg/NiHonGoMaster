class FlashcardProgress {
  final String userId;
  final String vocabId;
  final int interval;
  final double easeFactor;
  final int repetition;
  final DateTime nextReview;
  final int correctCount;
  final int wrongCount;
  final DateTime? lastReviewed;

  const FlashcardProgress({
    required this.userId,
    required this.vocabId,
    required this.interval,
    required this.easeFactor,
    required this.repetition,
    required this.nextReview,
    required this.correctCount,
    required this.wrongCount,
    this.lastReviewed,
  });

  factory FlashcardProgress.initial({required String userId, required String vocabId}) {
    return FlashcardProgress(
      userId: userId,
      vocabId: vocabId,
      interval: 1,
      easeFactor: 2.5,
      repetition: 0,
      nextReview: DateTime.now(),
      correctCount: 0,
      wrongCount: 0,
      lastReviewed: null,
    );
  }

  factory FlashcardProgress.fromMap(Map<String, dynamic> map) {
    return FlashcardProgress(
      userId: map['userId'] as String? ?? 'guest',
      vocabId: map['vocabId'] as String? ?? '',
      interval: map['interval'] as int? ?? 1,
      easeFactor: (map['easeFactor'] as num? ?? 2.5).toDouble(),
      repetition: map['repetition'] as int? ?? 0,
      nextReview: DateTime.tryParse(map['nextReview'] as String? ?? '') ?? DateTime.now(),
      correctCount: map['correctCount'] as int? ?? 0,
      wrongCount: map['wrongCount'] as int? ?? 0,
      lastReviewed: map['lastReviewed'] == null
          ? null
          : DateTime.tryParse(map['lastReviewed'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vocabId': vocabId,
      'interval': interval,
      'easeFactor': easeFactor,
      'repetition': repetition,
      'nextReview': nextReview.toIso8601String(),
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'lastReviewed': lastReviewed?.toIso8601String(),
    };
  }

  bool get isDue => DateTime.now().isAfter(nextReview) || DateTime.now().isAtSameMomentAs(nextReview);

  FlashcardProgress copyWith({
    String? userId,
    String? vocabId,
    int? interval,
    double? easeFactor,
    int? repetition,
    DateTime? nextReview,
    int? correctCount,
    int? wrongCount,
    DateTime? lastReviewed,
  }) {
    return FlashcardProgress(
      userId: userId ?? this.userId,
      vocabId: vocabId ?? this.vocabId,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      repetition: repetition ?? this.repetition,
      nextReview: nextReview ?? this.nextReview,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }
}
