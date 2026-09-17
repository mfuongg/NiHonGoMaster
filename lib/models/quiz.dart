class QuizQuestion {
  final String id;
  final String question;
  final String questionJp;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String jlptLevel;
  final QuestionType type;
  final String? audioPath;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.questionJp,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.jlptLevel,
    required this.type,
    this.audioPath,
  });
}

enum QuestionType {
  vocabularyMeaning,
  vocabularyReading,
  kanjiMeaning,
  kanjiReading,
  grammar,
  listening,
}

class QuizResult {
  final String testId;
  final String jlptLevel;
  final int totalQuestions;
  final int correctAnswers;
  final Duration timeTaken;
  final DateTime completedAt;
  final Map<QuestionType, int> correctByType;

  QuizResult({
    required this.testId,
    required this.jlptLevel,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTaken,
    required this.completedAt,
    required this.correctByType,
  });

  double get scorePercent => correctAnswers / totalQuestions * 100;
  bool get isPassed => scorePercent >= 60;

  String get grade {
    if (scorePercent >= 90) return 'S';
    if (scorePercent >= 80) return 'A';
    if (scorePercent >= 70) return 'B';
    if (scorePercent >= 60) return 'C';
    return 'F';
  }
}

class JLPTTest {
  final String id;
  final String level;
  final String title;
  final List<QuizQuestion> questions;
  final int timeMinutes;

  const JLPTTest({
    required this.id,
    required this.level,
    required this.title,
    required this.questions,
    required this.timeMinutes,
  });
}
