import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/reading_material_data.dart';
import '../../models/reading_material.dart';
import '../../utils/theme.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final List<ReadingMaterial> _materials;
  late final List<CultureTopic> _cultureTopics;

  String _selectedLevel = 'Tất cả';
  String _selectedCategory = 'Tất cả';
  String _query = '';
  bool _isLoadingCulture = true;
  bool _isSpinning = false;
  bool _hasSpunToday = false;
  double _turns = 0;
  CultureTopic? _todayCulture;

  @override
  void initState() {
    super.initState();
    _materials = buildReadingMaterials();
    _cultureTopics = buildCultureTopics();
    _loadCultureState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _levels => ['Tất cả', 'N5', 'N4', 'N3', 'N2', 'N1'];
  List<String> get _categories => [
        'Tất cả',
        'Cổ tích',
        'Đời sống',
        'Tips học tập',
        'Kinh tế & xã hội',
        'Tiểu thuyết',
      ];

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadCultureState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('culture_spin_date');
    final savedIndex = prefs.getInt('culture_spin_index');

    if (savedDate == _todayKey && savedIndex != null && savedIndex >= 0 && savedIndex < _cultureTopics.length) {
      _todayCulture = _cultureTopics[savedIndex];
      _hasSpunToday = true;
    }

    if (mounted) {
      setState(() => _isLoadingCulture = false);
    }
  }

  Future<void> _spinCulture() async {
    if (_hasSpunToday || _isSpinning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hôm nay bạn đã quay rồi. Hãy quay lại vào ngày mai nhé 🌸')),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
      _turns += 6.5;
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    final index = Random().nextInt(_cultureTopics.length);
    final topic = _cultureTopics[index];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('culture_spin_date', _todayKey);
    await prefs.setInt('culture_spin_index', index);

    if (!mounted) return;
    setState(() {
      _todayCulture = topic;
      _hasSpunToday = true;
      _isSpinning = false;
    });
  }

  List<ReadingMaterial> get _filteredMaterials {
    return _materials.where((item) {
      final matchesLevel = _selectedLevel == 'Tất cả' || item.level == _selectedLevel;
      final matchesCategory = _selectedCategory == 'Tất cả' || item.category == _selectedCategory;
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.japaneseTitle.toLowerCase().contains(q) ||
          item.summary.toLowerCase().contains(q) ||
          item.tags.join(' ').toLowerCase().contains(q);
      return matchesLevel && matchesCategory && matchesQuery;
    }).toList();
  }

  List<ReadingMaterial> get _featuredMaterials =>
      _filteredMaterials.where((item) => item.isFeatured).take(8).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMaterials;
    final featured = _featuredMaterials;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF7A5D2), Color(0xFF9A82F4), Color(0xFF86BDF3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryDark.withOpacity(0.16),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Read Library',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Kho bài đọc từ N5 đến N1 với truyện, báo mạng, tips học tập và tiểu thuyết.',
                                      style: TextStyle(color: Colors.white, height: 1.45),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _HeroStat(value: '${_materials.length}', label: 'Tài liệu')), 
                              const SizedBox(width: 10),
                              const Expanded(child: _HeroStat(value: '5', label: 'Cấp độ')), 
                              const SizedBox(width: 10),
                              const Expanded(child: _HeroStat(value: '5', label: 'Chủ đề')), 
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tiêu đề, chủ đề, cấp độ, từ khóa...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionTitle(title: 'Lọc theo cấp độ'),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _levels
                            .map((level) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(level),
                                    selected: _selectedLevel == level,
                                    onSelected: (_) => setState(() => _selectedLevel = level),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionTitle(title: 'Lọc theo thể loại'),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories
                            .map((category) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(category),
                                    selected: _selectedCategory == category,
                                    onSelected: (_) => setState(() => _selectedCategory = category),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildCultureCard(),
                    const SizedBox(height: 20),
                    if (featured.isNotEmpty) ...[
                      const _SectionTitle(title: 'Gợi ý nổi bật hôm nay'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 190,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: featured.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final item = featured[index];
                            return _FeaturedReadCard(
                              material: item,
                              onTap: () => _openDetail(item),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _SectionTitle(
                      title: 'Danh sách bài đọc',
                      trailing: Text(
                        '${filtered.length} tài liệu',
                        style: const TextStyle(
                          color: AppTheme.textMedium,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: _EmptyReadState(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filtered[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == filtered.length - 1 ? 0 : 12,
                        ),
                        child: _ReadingCard(
                          material: item,
                          onTap: () => _openDetail(item),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCultureCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.primaryDark.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.casino_rounded, color: AppTheme.warningOrange),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khám phá văn hóa Nhật mỗi ngày',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mỗi ngày bạn có 1 lượt quay để mở ra một nét văn hóa mới của Nhật Bản.',
                      style: TextStyle(color: AppTheme.textMedium, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AnimatedRotation(
                turns: _turns,
                duration: const Duration(milliseconds: 1300),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD08B), Color(0xFFF28DBB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      _todayCulture?.icon ?? '🎌',
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _isLoadingCulture
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(minHeight: 6),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _todayCulture?.title ?? 'Chưa quay hôm nay',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _todayCulture?.subtitle ?? 'Bấm nút quay để nhận một chủ đề văn hóa Nhật Bản trong ngày.',
                            style: const TextStyle(color: AppTheme.textMedium, height: 1.45),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_todayCulture != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bgLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _todayCulture!.content,
                    style: const TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _todayCulture!.keywords
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppTheme.primaryDark.withOpacity(0.08)),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: AppTheme.primaryDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _isLoadingCulture || _isSpinning ? null : _spinCulture,
            icon: Icon(_hasSpunToday ? Icons.check_circle_rounded : Icons.casino_rounded),
            label: Text(_hasSpunToday ? 'Đã quay hôm nay' : 'Quay 1 lần hôm nay'),
          ),
        ],
      ),
    );
  }

  void _openDetail(ReadingMaterial material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadDetailScreen(material: material),
      ),
    );
  }
}

class ReadDetailScreen extends StatelessWidget {
  final ReadingMaterial material;

  const ReadDetailScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    final sections = material.content
        .split('\n\n')
        .where((element) => element.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(material.level + ' · ' + material.category)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.jlptColor(material.level).withOpacity(0.92),
                  AppTheme.primaryDark.withOpacity(0.88),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        material.level,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        material.category,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  material.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  material.japaneseTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  material.summary,
                  style: const TextStyle(color: Colors.white, height: 1.55),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(icon: Icons.schedule_rounded, text: '${material.estimatedMinutes} phút'),
                    ...material.tags.take(3).map((tag) => _InfoPill(icon: Icons.sell_rounded, text: tag)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tóm tắt nhanh',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(material.preview, style: const TextStyle(height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryDark.withOpacity(0.06)),
                ),
                child: Text(
                  section,
                  style: const TextStyle(height: 1.72, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _FeaturedReadCard extends StatelessWidget {
  final ReadingMaterial material;
  final VoidCallback onTap;

  const _FeaturedReadCard({required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.jlptColor(material.level).withOpacity(0.96),
              AppTheme.primaryDark.withOpacity(0.88),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    material.level,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Text(
                  '${material.estimatedMinutes} phút',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Spacer(),
            Text(
              material.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              material.preview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  final ReadingMaterial material;
  final VoidCallback onTap;

  const _ReadingCard({required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.jlptColor(material.level);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withOpacity(0.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    material.level,
                    style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    material.category,
                    style: const TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Text(
                  '${material.estimatedMinutes} phút',
                  style: const TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              material.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.35),
            ),
            const SizedBox(height: 6),
            Text(
              material.japaneseTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              material.preview,
              style: const TextStyle(height: 1.55, color: AppTheme.textMedium),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: material.tags.take(4).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.primaryDark.withOpacity(0.08)),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyReadState extends StatelessWidget {
  const _EmptyReadState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 46, color: AppTheme.textMedium),
          SizedBox(height: 12),
          Text(
            'Không tìm thấy bài đọc phù hợp',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'Hãy đổi từ khóa tìm kiếm hoặc bỏ bớt bộ lọc để xem nhiều tài liệu hơn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMedium, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
