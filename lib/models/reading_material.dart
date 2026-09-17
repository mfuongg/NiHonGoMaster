class ReadingMaterial {
  final String id;
  final String level;
  final String category;
  final String title;
  final String japaneseTitle;
  final String summary;
  final String preview;
  final String content;
  final int estimatedMinutes;
  final List<String> tags;
  final bool isFeatured;

  const ReadingMaterial({
    required this.id,
    required this.level,
    required this.category,
    required this.title,
    required this.japaneseTitle,
    required this.summary,
    required this.preview,
    required this.content,
    required this.estimatedMinutes,
    required this.tags,
    this.isFeatured = false,
  });
}

class CultureTopic {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String content;
  final List<String> keywords;

  const CultureTopic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.content,
    required this.keywords,
  });
}
