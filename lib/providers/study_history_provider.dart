import 'package:flutter/material.dart';

import '../models/study_history.dart';
import '../services/firestore_service.dart';
import '../services/local_database_service.dart';

class StudyHistoryProvider extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService.instance;
  final FirestoreService _firestore = FirestoreService();

  List<StudyHistory> _histories = [];
  bool _isLoading = false;
  String _currentUserId = 'guest';

  List<StudyHistory> get histories => _histories;
  bool get isLoading => _isLoading;
  String get currentUserId => _currentUserId;

  Future<void> init({String? userId}) async {
    _currentUserId = (userId == null || userId.isEmpty) ? 'guest' : userId;
    _isLoading = true;
    notifyListeners();

    try {
      _histories = await _localDb.getStudyHistories(userId: _currentUserId);
    } catch (_) {
      _histories = [];
    }

    if (_currentUserId != 'guest') {
      try {
        final remote = await _firestore.fetchStudyHistories(_currentUserId);
        if (remote.isNotEmpty) {
          _histories = remote;
          for (final item in remote) {
            await _localDb.upsertStudyHistory(item);
          }
        }
      } catch (_) {
        
      }
    }

    _histories.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHistory(StudyHistory history) async {
    await _localDb.upsertStudyHistory(history);

    try {
      await _firestore.saveStudyHistory(history);
    } catch (_) {
      
    }

    final index = _histories.indexWhere((e) => e.id == history.id);
    if (index >= 0) {
      _histories[index] = history;
    } else {
      _histories.insert(0, history);
    }
    _histories.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    notifyListeners();
  }
}
