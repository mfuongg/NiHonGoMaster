import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/community_contribution.dart';
import 'firebase_service.dart';

class CommunityContributionService {
  CommunityContributionService._();
  static final CommunityContributionService instance =
      CommunityContributionService._();

  final Uuid _uuid = const Uuid();

  bool get _shouldUseCloud => FirebaseService.isEnabled && !kIsWeb;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String _localKey(String itemType, String itemId) =>
      'community_feedback_${itemType}_$itemId';

  Future<List<CommunityContribution>> fetchContributions({
    required String itemType,
    required String itemId,
  }) async {
    if (_shouldUseCloud) {
      try {
        final snapshot = await _db
            .collection('community_feedback')
            .doc(itemType)
            .collection(itemId)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get();
        return snapshot.docs
            .map((doc) => CommunityContribution.fromMap(doc.data()))
            .toList();
      } catch (_) {
        
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_localKey(itemType, itemId)) ?? const [];
    return rawList
        .map((raw) => CommunityContribution.fromMap(jsonDecode(raw)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> submitContribution({
    required String itemType,
    required String itemId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    final contribution = CommunityContribution(
      id: _uuid.v4(),
      itemType: itemType,
      itemId: itemId,
      userId: userId,
      userName: userName.trim().isEmpty ? 'Học viên NihonGo' : userName.trim(),
      message: message.trim(),
      createdAt: DateTime.now(),
    );

    if (_shouldUseCloud) {
      try {
        await _db
            .collection('community_feedback')
            .doc(itemType)
            .collection(itemId)
            .doc(contribution.id)
            .set(contribution.toMap());
        return;
      } catch (_) {
        
      }
    }

    await _saveLocally(contribution);
  }

  Future<void> _saveLocally(CommunityContribution contribution) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _localKey(contribution.itemType, contribution.itemId);
    final existing = prefs.getStringList(key) ?? <String>[];
    existing.insert(0, jsonEncode(contribution.toMap()));
    await prefs.setStringList(key, existing.take(50).toList());
  }
}
