import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../data/grammar_data.dart';
import '../../models/grammar.dart';
import '../../utils/theme.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  String _selectedLevel = 'N5';

  @override
  Widget build(BuildContext context) {
    final lessons = GrammarData.getLessonsByLevel(_selectedLevel);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: AppTheme.jlptColor(_selectedLevel),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              title: Row(
                children: [
                  Text(_levelEmoji(_selectedLevel)),
                  const SizedBox(width: 8),
                  Text('Ngữ pháp $_selectedLevel'),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.jlptColor(_selectedLevel),
                      AppTheme.jlptColor(_selectedLevel).withOpacity(0.75),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 74),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${lessons.length} mẫu ngữ pháp cho $_selectedLevel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Mở rộng từ N5 đến N1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mỗi cấp độ đều có tối thiểu 10 mẫu, kèm giải thích dễ nhớ, ví dụ Nhật - Việt - Anh và phần lưu ý thi JLPT.',
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: GrammarData.levels.map((level) {
                  final selected = level == _selectedLevel;
                  final color = AppTheme.jlptColor(level);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLevel = level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? color : color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected ? color : color.withOpacity(0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_levelEmoji(level)),
                          const SizedBox(width: 8),
                          Text(
                            level,
                            style: TextStyle(
                              color: selected ? Colors.white : color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${GrammarData.getLessonsByLevel(level).length}',
                            style: TextStyle(
                              color: selected ? Colors.white70 : color.withOpacity(0.85),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      color: AppTheme.jlptColor(_selectedLevel),
                      icon: '🧠',
                      title: 'Mẫu đang xem',
                      value: '${lessons.length}',
                      subtitle: 'Tập trung theo từng cấp độ',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OverviewCard(
                      color: AppTheme.primaryDark,
                      icon: '📚',
                      title: 'Tổng số mẫu',
                      value: '${GrammarData.getAllLessons().length}',
                      subtitle: 'Phủ rộng N5 → N1',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  Text(
                    'Danh sách mẫu $_selectedLevel',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  Text(
                    '${lessons.length} bài',
                    style: const TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return FadeInUp(
                  delay: Duration(milliseconds: 35 * (index % 8)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GrammarCard(
                      lesson: lesson,
                      index: index + 1,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GrammarDetailScreen(lesson: lesson),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _levelEmoji(String level) {
    switch (level) {
      case 'N5':
        return '🌱';
      case 'N4':
        return '📗';
      case 'N3':
        return '📘';
      case 'N2':
        return '📙';
      case 'N1':
        return '🏯';
      default:
        return '🧩';
    }
  }
}

class _OverviewCard extends StatelessWidget {
  final Color color;
  final String icon;
  final String title;
  final String value;
  final String subtitle;

  const _OverviewCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMedium, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _GrammarCard extends StatelessWidget {
  final GrammarLesson lesson;
  final int index;
  final VoidCallback onTap;

  const _GrammarCard({
    required this.lesson,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.jlptColor(lesson.jlptLevel);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 86,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.18), color.withOpacity(0.08)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        lesson.jlptLevel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.pattern,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lesson.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lesson.explanation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textMedium,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniTag(label: '${lesson.examples.length} ví dụ', color: color),
                        if (lesson.notes.isNotEmpty)
                          _MiniTag(label: '${lesson.notes.length} lưu ý', color: AppTheme.primaryDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMedium),
            ],
          ),
        ),
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
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class GrammarDetailScreen extends StatelessWidget {
  final GrammarLesson lesson;

  const GrammarDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.jlptColor(lesson.jlptLevel);

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.pattern),
        backgroundColor: color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      lesson.pattern,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lesson.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'JLPT ${lesson.jlptLevel}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            _SectionTitle(title: '📖 Giải thích'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.16)),
              ),
              child: Text(
                lesson.explanation,
                style: const TextStyle(fontSize: 15, height: 1.7),
              ),
            ),
            const SizedBox(height: 22),
            _SectionTitle(title: '📝 Ví dụ thực chiến'),
            ...lesson.examples.map((example) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border(left: BorderSide(color: color, width: 4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      example.japanese,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      example.hiragana,
                      style: const TextStyle(color: AppTheme.textMedium),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '🇻🇳 ${example.vietnamese}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🇬🇧 ${example.english}',
                      style: const TextStyle(color: AppTheme.textMedium, height: 1.4),
                    ),
                  ],
                ),
              );
            }),
            if (lesson.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              _SectionTitle(title: '💡 Mẹo nhớ nhanh'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC857).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFC857).withOpacity(0.24)),
                ),
                child: Column(
                  children: lesson.notes.map((note) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text('• ', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                          Expanded(
                            child: Text(note, style: const TextStyle(height: 1.5)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
    );
  }
}
