import 'package:flutter/material.dart';
import '../../data/vocabulary_data.dart';
import '../../data/kanji_data.dart';
import '../../models/vocabulary.dart';
import '../../models/kanji.dart';
import '../../utils/theme.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<VocabularyWord> _vocabResults = [];
  List<KanjiItem> _kanjiResults = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _search(String query) {
    setState(() {
      _query = query;
      if (query.isEmpty) {
        _vocabResults = [];
        _kanjiResults = [];
      } else {
        _vocabResults = VocabularyData.search(query);
        _kanjiResults = KanjiData.search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Từ điển'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Từ vựng ${_vocabResults.isNotEmpty ? "(${_vocabResults.length})" : ""}'),
            Tab(text: 'Kanji ${_kanjiResults.isNotEmpty ? "(${_kanjiResults.length})" : ""}'),
          ],
        ),
      ),
      body: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: '日本語、romaji, tiếng Việt...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                
                _query.isEmpty
                    ? _EmptyDictState()
                    : _vocabResults.isEmpty
                        ? const Center(child: Text('Không tìm thấy từ vựng'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _vocabResults.length,
                            itemBuilder: (context, index) {
                              return _DictVocabCard(word: _vocabResults[index]);
                            },
                          ),

                
                _query.isEmpty
                    ? _EmptyDictState()
                    : _kanjiResults.isEmpty
                        ? const Center(child: Text('Không tìm thấy kanji'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _kanjiResults.length,
                            itemBuilder: (context, index) {
                              return _DictKanjiCard(kanji: _kanjiResults[index]);
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDictState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            'Nhập từ khóa để tìm kiếm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Hỗ trợ tìm kiếm bằng:\n日本語 • Hiragana • Romaji • Tiếng Việt',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DictVocabCard extends StatelessWidget {
  final VocabularyWord word;
  const _DictVocabCard({required this.word});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.jlptColor(word.jlptLevel);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                word.japanese,
                style: TextStyle(
                  fontSize: word.japanese.length > 2 ? 14 : 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      word.hiragana,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${word.romaji})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  word.vietnamese,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  word.english,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              word.jlptLevel,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _DictKanjiCard extends StatelessWidget {
  final KanjiItem kanji;
  const _DictKanjiCard({required this.kanji});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.jlptColor(kanji.jlptLevel);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                kanji.kanji,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kanji.vietnamese,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'On: ${kanji.onyomi.isEmpty ? "-" : kanji.onyomi}  |  Kun: ${kanji.kunyomi.isEmpty ? "-" : kanji.kunyomi}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  kanji.english,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  kanji.jlptLevel,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${kanji.strokeCount} nét',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
