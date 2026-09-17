import 'package:flutter/material.dart';

import '../data/vocabulary_data.dart';
import '../models/vocabulary.dart';
import '../services/firestore_service.dart';
import '../services/local_database_service.dart';

class VocabularyProvider extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService.instance;
  final FirestoreService _firestore = FirestoreService();

  List<VocabularyWord> _allWords = [];
  List<VocabularyWord> _filteredWords = [];
  String _selectedLevel = 'N5';
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _showOnlyFavorites = false;
  bool _showOnlyLearned = false;
  bool _isSyncing = false;
  bool _isInitialized = false;
  bool _isInitializing = false;

  List<VocabularyWord> get words => _filteredWords;
  List<VocabularyWord> get allWords => _allWords;
  String get selectedLevel => _selectedLevel;
  String get selectedCategory => _selectedCategory;
  bool get isSyncing => _isSyncing;
  bool get isInitialized => _isInitialized;

  List<String> get categories {
    final cats = _allWords
        .where((w) => w.jlptLevel == _selectedLevel)
        .map((w) => w.category)
        .toSet()
        .toList()
      ..sort();
    return ['all', ...cats];
  }

  Future<void> init() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    try {
      final cached = await _localDb.getCachedVocabulary();
      final fallback = VocabularyData.getAllWords();

      if (cached.isNotEmpty) {
        _allWords = _mergeWords(primary: cached, fallback: fallback);
      } else {
        _allWords = fallback;
        await _localDb.cacheVocabulary(_allWords);
      }

      if (_allWords.isEmpty) {
        _allWords = fallback;
      }

      _applyFilters();
      _isInitialized = true;
      notifyListeners();
      await syncFromCloud();
    } catch (_) {
      _allWords = VocabularyData.getAllWords();
      _applyFilters();
      _isInitialized = true;
      notifyListeners();
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> ensureLoaded() async {
    if (_allWords.isNotEmpty || _isInitialized) return;
    await init();
  }

  Future<void> syncFromCloud() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final remote = await _firestore.fetchVocabulary();
      if (remote.isNotEmpty) {
        final fallback = VocabularyData.getAllWords();
        final merged = _mergeWords(
          primary: remote,
          fallback: _mergeWords(primary: _allWords.isEmpty ? fallback : _allWords, fallback: fallback),
        );
        if (merged.isNotEmpty) {
          _allWords = merged;
          await _localDb.cacheVocabulary(_allWords);
          _applyFilters();
        }
      }
    } catch (_) {
      if (_allWords.isEmpty) {
        _allWords = VocabularyData.getAllWords();
        _applyFilters();
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void setLevel(String level) {
    _selectedLevel = level;
    _selectedCategory = 'all';
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void toggleFavoriteFilter() {
    _showOnlyFavorites = !_showOnlyFavorites;
    _applyFilters();
    notifyListeners();
  }

  void toggleLearnedFilter() {
    _showOnlyLearned = !_showOnlyLearned;
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateWordProgress({
    required String wordId,
    required bool known,
    required int interval,
    required DateTime reviewedAt,
  }) async {
    final index = _allWords.indexWhere((w) => w.id == wordId);
    if (index < 0) return;
    final word = _allWords[index];
    _allWords[index] = word.copyWith(
      isLearned: known ? true : word.isLearned,
      correctCount: known ? word.correctCount + 1 : word.correctCount,
      wrongCount: known ? word.wrongCount : word.wrongCount + 1,
      lastStudied: reviewedAt,
      srsInterval: interval,
    );
    try {
      await _localDb.cacheVocabulary(_allWords);
    } catch (_) {
      
    }
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final source = _allWords.isEmpty ? VocabularyData.getAllWords() : _allWords;

    Iterable<VocabularyWord> result = source.where((w) {
      final levelMatch = w.jlptLevel == _selectedLevel;
      final categoryMatch = _selectedCategory == 'all' || w.category == _selectedCategory;
      return levelMatch && categoryMatch;
    });

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((w) {
        return w.japanese.contains(_searchQuery) ||
            w.hiragana.contains(_searchQuery) ||
            w.romaji.toLowerCase().contains(query) ||
            w.vietnamese.toLowerCase().contains(query) ||
            w.english.toLowerCase().contains(query);
      });
    }

    if (_showOnlyFavorites) {
      result = result.where((w) => w.isFavorite);
    }

    if (_showOnlyLearned) {
      result = result.where((w) => w.isLearned);
    }

    _filteredWords = result.toList();
  }

  List<VocabularyWord> getWordsForFlashcard(String level) {
    final source = _allWords.isEmpty ? VocabularyData.getAllWords() : _allWords;
    final words = source.where((w) => w.jlptLevel == level).toList();
    if (words.isNotEmpty) return words;
    return VocabularyData.getWordsByLevel(level);
  }

  List<VocabularyWord> getQuizWords(String level, int count) {
    final source = [...getWordsForFlashcard(level)]..shuffle();
    return source.take(count).toList();
  }

  int getLearnedCount(String level) {
    final source = _allWords.isEmpty ? VocabularyData.getAllWords() : _allWords;
    return source.where((w) => w.jlptLevel == level && w.isLearned).length;
  }

  int getTotalCount(String level) {
    final source = _allWords.isEmpty ? VocabularyData.getAllWords() : _allWords;
    return source.where((w) => w.jlptLevel == level).length;
  }

  List<VocabularyWord> _mergeWords({
    required List<VocabularyWord> primary,
    required List<VocabularyWord> fallback,
  }) {
    final map = <String, VocabularyWord>{};
    for (final word in fallback) {
      map[word.id] = word;
    }
    for (final word in primary) {
      map[word.id] = _mergeWord(map[word.id], word);
    }
    return map.values.toList()
      ..sort((a, b) {
        final levelCompare = a.jlptLevel.compareTo(b.jlptLevel);
        if (levelCompare != 0) return levelCompare;
        return a.id.compareTo(b.id);
      });
  }

  VocabularyWord _mergeWord(VocabularyWord? base, VocabularyWord incoming) {
    if (base == null) return incoming;
    return base.copyWith(
      japanese: incoming.japanese.isNotEmpty ? incoming.japanese : base.japanese,
      hiragana: incoming.hiragana.isNotEmpty ? incoming.hiragana : base.hiragana,
      romaji: incoming.romaji.isNotEmpty ? incoming.romaji : base.romaji,
      vietnamese: incoming.vietnamese.isNotEmpty ? incoming.vietnamese : base.vietnamese,
      english: incoming.english.isNotEmpty ? incoming.english : base.english,
      jlptLevel: incoming.jlptLevel.isNotEmpty ? incoming.jlptLevel : base.jlptLevel,
      category: incoming.category.isNotEmpty ? incoming.category : base.category,
      exampleSentences: incoming.exampleSentences.isNotEmpty
          ? incoming.exampleSentences
          : base.exampleSentences,
      exampleTranslations: incoming.exampleTranslations.isNotEmpty
          ? incoming.exampleTranslations
          : base.exampleTranslations,
      isLearned: incoming.isLearned || base.isLearned,
      isFavorite: incoming.isFavorite || base.isFavorite,
      correctCount: incoming.correctCount > base.correctCount
          ? incoming.correctCount
          : base.correctCount,
      wrongCount: incoming.wrongCount > base.wrongCount
          ? incoming.wrongCount
          : base.wrongCount,
      lastStudied: incoming.lastStudied ?? base.lastStudied,
      srsInterval: incoming.srsInterval > 0 ? incoming.srsInterval : base.srsInterval,
    );
  }
}
