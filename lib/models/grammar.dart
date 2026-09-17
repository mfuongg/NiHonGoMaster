class GrammarLesson {
  final String id;
  final String pattern;
  final String title;
  final String explanation;
  final String jlptLevel;
  final List<ExampleSentence> examples;
  final List<String> notes;
  bool isLearned;

  GrammarLesson({
    required this.id,
    required this.pattern,
    required this.title,
    required this.explanation,
    required this.jlptLevel,
    required this.examples,
    this.notes = const [],
    this.isLearned = false,
  });
}

class ExampleSentence {
  final String japanese;
  final String hiragana;
  final String vietnamese;
  final String english;

  const ExampleSentence({
    required this.japanese,
    required this.hiragana,
    required this.vietnamese,
    required this.english,
  });
}
