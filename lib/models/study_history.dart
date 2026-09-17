class StudyHistory {
  final String id;
  final String userId;
  final String testId;
  final String title;
  final String jlptLevel;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double scorePercent;
  final int timeTakenSeconds;
  final DateTime completedAt;

  const StudyHistory({
    required this.id,
    required this.userId,
    required this.testId,
    required this.title,
    required this.jlptLevel,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.scorePercent,
    required this.timeTakenSeconds,
    required this.completedAt,
  });

  factory StudyHistory.fromMap(Map<String, dynamic> map) {
    return StudyHistory(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? 'guest',
      testId: map['testId'] as String? ?? '',
      title: map['title'] as String? ?? 'JLPT Test',
      jlptLevel: map['jlptLevel'] as String? ?? 'N5',
      totalQuestions: map['totalQuestions'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      wrongAnswers: map['wrongAnswers'] as int? ?? 0,
      scorePercent: (map['scorePercent'] as num? ?? 0).toDouble(),
      timeTakenSeconds: map['timeTakenSeconds'] as int? ?? 0,
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'testId': testId,
      'title': title,
      'jlptLevel': jlptLevel,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'scorePercent': scorePercent,
      'timeTakenSeconds': timeTakenSeconds,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
