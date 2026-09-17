import 'package:flutter/material.dart';

import '../models/flashcard_progress.dart';
import '../models/vocabulary.dart';
import '../services/firestore_service.dart';
import '../services/local_database_service.dart';

class FlashcardProvider extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService.instance;
  final FirestoreService _firestore = FirestoreService();

  List<VocabularyWord> _sessionWords = [];
  Map<String, FlashcardProgress> _progressMap = {};
  int _currentIndex = 0;
  int _knownCount = 0;
  int _unknownCount = 0;
  String _userId = 'guest';

  List<VocabularyWord> get sessionWords => List.unmodifiable(_sessionWords);
  int get currentIndex => _currentIndex;
  int get knownCount => _knownCount;
  int get unknownCount => _unknownCount;
  bool get hasSession => _sessionWords.isNotEmpty;
  bool get isFinished =>
      _sessionWords.isNotEmpty && _currentIndex >= _sessionWords.length;

  VocabularyWord? get currentWord {
    if (_sessionWords.isEmpty) return null;
    if (_currentIndex < 0 || _currentIndex >= _sessionWords.length) return null;
    return _sessionWords[_currentIndex];
  }

  Future<void> startSession(
    List<VocabularyWord> words, {
    required String userId,
  }) async {
    _userId = userId;
    _knownCount = 0;
    _unknownCount = 0;
    _currentIndex = 0;
    _sessionWords = [];
    notifyListeners();

    try {
      _progressMap = await _localDb.getAllFlashcardProgress(userId: userId);
    } catch (_) {
      _progressMap = {};
    }

    try {
      final remote = await _firestore.fetchFlashcardProgress(userId);
      if (remote.isNotEmpty) {
        _progressMap.addAll(remote);
        for (final item in remote.values) {
          await _localDb.upsertFlashcardProgress(item);
        }
      }
    } catch (_) {
      
    }

    final ranked = List<VocabularyWord>.from(words);
    ranked.sort((a, b) => _priorityForWord(b).compareTo(_priorityForWord(a)));
    _sessionWords = ranked;
    _currentIndex = 0;
    notifyListeners();
  }

  Future<FlashcardProgress> markAnswer(
    VocabularyWord word,
    bool correct,
  ) async {
    final current = _progressMap[word.id] ??
        FlashcardProgress.initial(userId: _userId, vocabId: word.id);
    final updated = _applySpacedRepetition(current, correct: correct);
    _progressMap[word.id] = updated;

    if (correct) {
      _knownCount++;
    } else {
      _unknownCount++;
    }

    
    _localDb.upsertFlashcardProgress(updated).catchError((_) {});
    _firestore.saveFlashcardProgress(updated).catchError((_) {});

    notifyListeners();
    return updated;
  }

  
  void nextCard() {
    if (_currentIndex < _sessionWords.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
    
  }

  
  void previousCard() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  FlashcardProgress progressFor(String vocabId) {
    return _progressMap[vocabId] ??
        FlashcardProgress.initial(userId: _userId, vocabId: vocabId);
  }

  double _priorityForWord(VocabularyWord word) {
    final progress = _progressMap[word.id];
    if (progress == null) return 10;
    final dueBonus = progress.isDue ? 8.0 : 0.0;
    final wrongPenalty = progress.wrongCount * 1.5;
    final easePenalty = 3.0 - progress.easeFactor;
    return dueBonus + wrongPenalty + easePenalty;
  }

  FlashcardProgress _applySpacedRepetition(
    FlashcardProgress progress, {
    required bool correct,
  }) {
    var repetition = progress.repetition;
    var interval = progress.interval;
    var ease = progress.easeFactor;

    if (!correct) {
      repetition = 0;
      interval = 1;
      ease = (ease - 0.2).clamp(1.3, 2.5);
    } else {
      repetition += 1;
      if (repetition == 1) {
        interval = 1;
      } else if (repetition == 2) {
        interval = 3;
      } else {
        interval = (interval * ease).round();
      }
      ease = (ease + 0.1).clamp(1.3, 2.8);
    }

    return progress.copyWith(
      repetition: repetition,
      interval: interval,
      easeFactor: ease,
      nextReview: DateTime.now().add(Duration(days: interval)),
      correctCount: correct ? progress.correctCount + 1 : progress.correctCount,
      wrongCount: correct ? progress.wrongCount : progress.wrongCount + 1,
      lastReviewed: DateTime.now(),
    );
  }
}
