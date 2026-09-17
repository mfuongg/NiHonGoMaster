import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/flashcard_progress.dart';
import '../models/study_history.dart';
import '../models/vocabulary.dart';
import 'firebase_service.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String _toStringValue(dynamic value, {String fallback = ''}) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return fallback;
  }

  Map<String, dynamic> _normalizeLeaderboardEntry(String uid, Map<String, dynamic> data) {
    final email = _toStringValue(data['email']);
    final displayName = _toStringValue(
      data['displayName'],
      fallback: email.isEmpty ? 'Học viên NihonGo' : email.split('@').first,
    );

    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': data['photoUrl'],
      'totalXp': _toInt(data['totalXp']),
      'streak': _toInt(data['streak']),
      'longestStreak': _toInt(data['longestStreak']),
      'achievementCount': _toInt(data['achievementCount']),
      'learnedVocabCount': _toInt(data['learnedVocabCount']),
      'learnedKanjiCount': _toInt(data['learnedKanjiCount']),
      'todayXp': _toInt(data['todayXp']),
      'userLevel': _toInt(data['userLevel'], fallback: 1),
      'selectedJlptLevel': _toStringValue(data['selectedJlptLevel'], fallback: 'N5'),
    };
  }

  List<Map<String, dynamic>> _sortLeaderboardEntries(List<Map<String, dynamic>> entries) {
    entries.sort((a, b) {
      final xpCompare = _toInt(b['totalXp']).compareTo(_toInt(a['totalXp']));
      if (xpCompare != 0) return xpCompare;
      final streakCompare = _toInt(b['streak']).compareTo(_toInt(a['streak']));
      if (streakCompare != 0) return streakCompare;
      return _toStringValue(a['displayName'], fallback: 'Học viên NihonGo')
          .compareTo(_toStringValue(b['displayName'], fallback: 'Học viên NihonGo'));
    });
    return entries;
  }

  Future<void> syncUserProfile(AppUser user) async {
    if (!FirebaseService.isEnabled) return;
    await _db.collection('users').doc(user.uid).set({
      ...user.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> logLoginActivity(AppUser user) async {
    if (!FirebaseService.isEnabled) return;
    try {
      await _db.collection('users').doc(user.uid).collection('activity_log').add({
        'type': 'login',
        'email': user.email,
        'displayName': user.displayName,
        'provider': user.provider,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'flutter',
      });
      await _db.collection('users').doc(user.uid).set({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'loginCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> logLogoutActivity(AppUser user) async {
    if (!FirebaseService.isEnabled) return;
    try {
      await _db.collection('users').doc(user.uid).collection('activity_log').add({
        'type': 'logout',
        'email': user.email,
        'displayName': user.displayName,
        'provider': user.provider,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'flutter',
      });
      await _db.collection('users').doc(user.uid).set({
        'lastLogoutAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }


  Future<void> saveUserProgressData({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    if (!FirebaseService.isEnabled) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('app_state')
        .doc('progress')
        .set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> fetchUserProgressData(String uid) async {
    if (!FirebaseService.isEnabled) return null;
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('app_state')
        .doc('progress')
        .get();
    return snapshot.data();
  }

  Future<void> syncUserProgressStats({
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int learnedVocabCount,
    required int learnedKanjiCount,
    required int achievementCount,
    required int todayXp,
    required int userLevel,
    required String selectedJlptLevel,
  }) async {
    if (!FirebaseService.isEnabled) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final fallbackName = (currentUser.displayName?.trim().isNotEmpty ?? false)
        ? currentUser.displayName!.trim()
        : ((currentUser.email?.split('@').first ?? 'Học viên NihonGo').trim());

    await _db.collection('users').doc(currentUser.uid).set({
      'uid': currentUser.uid,
      'email': currentUser.email ?? '',
      'displayName': fallbackName,
      'photoUrl': currentUser.photoURL,
      'provider': currentUser.providerData.isNotEmpty
          ? currentUser.providerData.first.providerId
          : 'firebase',
      'totalXp': totalXp,
      'streak': currentStreak,
      'longestStreak': longestStreak,
      'learnedVocabCount': learnedVocabCount,
      'learnedKanjiCount': learnedKanjiCount,
      'achievementCount': achievementCount,
      'todayXp': todayXp,
      'userLevel': userLevel,
      'selectedJlptLevel': selectedJlptLevel,
      'lastActiveAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard({int limit = 100}) async {
    if (!FirebaseService.isEnabled) return [];

    try {
      final snapshot = await _db
          .collection('users')
          .orderBy('totalXp', descending: true)
          .limit(limit)
          .get();

      final entries = snapshot.docs
          .map((doc) => _normalizeLeaderboardEntry(doc.id, doc.data()))
          .toList();
      return _sortLeaderboardEntries(entries);
    } catch (_) {
      return [];
    }
  }

  Future<List<VocabularyWord>> fetchVocabulary() async {
    if (!FirebaseService.isEnabled) return [];
    final snapshot = await _db.collection('vocabularies').get();
    return snapshot.docs.map((doc) {
      final map = doc.data();
      return VocabularyWord(
        id: doc.id,
        japanese: map['japanese'] as String? ?? '',
        hiragana: map['hiragana'] as String? ?? '',
        romaji: map['romaji'] as String? ?? '',
        vietnamese: map['vietnamese'] as String? ?? '',
        english: map['english'] as String? ?? '',
        jlptLevel: map['jlptLevel'] as String? ?? 'N5',
        category: map['category'] as String? ?? 'general',
        exampleSentences: List<String>.from(map['exampleSentences'] as List? ?? const []),
        exampleTranslations: List<String>.from(map['exampleTranslations'] as List? ?? const []),
        isLearned: map['isLearned'] as bool? ?? false,
        isFavorite: map['isFavorite'] as bool? ?? false,
        correctCount: map['correctCount'] as int? ?? 0,
        wrongCount: map['wrongCount'] as int? ?? 0,
        lastStudied: map['lastStudied'] == null ? null : DateTime.tryParse(map['lastStudied'].toString()),
        srsInterval: map['srsInterval'] as int? ?? 1,
      );
    }).toList();
  }

  Future<void> saveFlashcardProgress(FlashcardProgress progress) async {
    if (!FirebaseService.isEnabled) return;
    await _db
        .collection('users')
        .doc(progress.userId)
        .collection('flashcard_progress')
        .doc(progress.vocabId)
        .set(progress.toMap(), SetOptions(merge: true));
  }

  Future<Map<String, FlashcardProgress>> fetchFlashcardProgress(String userId) async {
    if (!FirebaseService.isEnabled) return {};
    final snapshot = await _db.collection('users').doc(userId).collection('flashcard_progress').get();
    return {for (final doc in snapshot.docs) doc.id: FlashcardProgress.fromMap(doc.data())};
  }

  Future<void> saveStudyHistory(StudyHistory history) async {
    if (!FirebaseService.isEnabled) return;
    await _db
        .collection('users')
        .doc(history.userId)
        .collection('test_history')
        .doc(history.id)
        .set(history.toMap(), SetOptions(merge: true));
  }

  
  static String _weekKey() {
    final now = DateTime.now();
    final thursday = now.add(Duration(days: DateTime.thursday - now.weekday));
    final firstDay = DateTime(thursday.year, 1, 1);
    final week = ((thursday.difference(firstDay).inDays) / 7).ceil() + 1;
    return '\${thursday.year}_W\${week.toString().padLeft(2, "0")}';
  }

  static String _monthKey() {
    final now = DateTime.now();
    return '\${now.year}_\${now.month.toString().padLeft(2, "0")}';
  }

  static String get currentWeekKey => _weekKey();
  static String get currentMonthKey => _monthKey();

  Future<void> syncWeeklyMonthlyLeaderboard({
    required String uid,
    required String displayName,
    required int totalXp,
    required int currentStreak,
    required int userLevel,
    required int learnedVocabCount,
    required int learnedKanjiCount,
    required String selectedJlptLevel,
  }) async {
    if (!FirebaseService.isEnabled) return;
    try {
      final now = FieldValue.serverTimestamp();
      final wk = _weekKey();
      final mk = _monthKey();

      await _db.collection('leaderboard_weekly').doc(wk)
          .collection('entries').doc(uid).set({
        'uid': uid, 'displayName': displayName,
        'totalXp': totalXp, 'streak': currentStreak,
        'userLevel': userLevel, 'learnedVocabCount': learnedVocabCount,
        'learnedKanjiCount': learnedKanjiCount,
        'selectedJlptLevel': selectedJlptLevel,
        'weekKey': wk, 'lastUpdated': now,
      }, SetOptions(merge: true));

      await _db.collection('leaderboard_monthly').doc(mk)
          .collection('entries').doc(uid).set({
        'uid': uid, 'displayName': displayName,
        'totalXp': totalXp, 'streak': currentStreak,
        'userLevel': userLevel, 'learnedVocabCount': learnedVocabCount,
        'learnedKanjiCount': learnedKanjiCount,
        'selectedJlptLevel': selectedJlptLevel,
        'monthKey': mk, 'lastUpdated': now,
      }, SetOptions(merge: true));
    } catch (e) {
      
    }
  }

  Future<List<Map<String, dynamic>>> fetchWeeklyLeaderboard({int limit = 100}) async {
    if (!FirebaseService.isEnabled) return [];
    try {
      final snap = await _db.collection('leaderboard_weekly')
          .doc(_weekKey()).collection('entries')
          .orderBy('totalXp', descending: true).limit(limit).get();
      final entries = snap.docs
          .map((doc) => _normalizeLeaderboardEntry(doc.id, doc.data()))
          .toList();
      return _sortLeaderboardEntries(entries);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchMonthlyLeaderboard({int limit = 100}) async {
    if (!FirebaseService.isEnabled) return [];
    try {
      final snap = await _db.collection('leaderboard_monthly')
          .doc(_monthKey()).collection('entries')
          .orderBy('totalXp', descending: true).limit(limit).get();
      final entries = snap.docs
          .map((doc) => _normalizeLeaderboardEntry(doc.id, doc.data()))
          .toList();
      return _sortLeaderboardEntries(entries);
    } catch (_) {
      return [];
    }
  }

  Future<void> claimRankReward({
    required String uid,
    required String period,
    required String periodKey,
    required int rank,
    required int xpReward,
  }) async {
    if (!FirebaseService.isEnabled) return;
    try {
      await _db.collection('users').doc(uid)
          .collection('rank_rewards').doc('\${period}_\$periodKey').set({
        'period': period, 'periodKey': periodKey,
        'rank': rank, 'xpReward': xpReward,
        'claimedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<bool> hasClaimedRankReward({
    required String uid,
    required String period,
    required String periodKey,
  }) async {
    if (!FirebaseService.isEnabled) return false;
    try {
      final doc = await _db.collection('users').doc(uid)
          .collection('rank_rewards').doc('\${period}_\$periodKey').get();
      return doc.exists;
    } catch (_) { return false; }
  }

  Future<List<StudyHistory>> fetchStudyHistories(String userId) async {
    if (!FirebaseService.isEnabled) return [];
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('test_history')
        .orderBy('completedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => StudyHistory.fromMap(doc.data())).toList();
  }
}
