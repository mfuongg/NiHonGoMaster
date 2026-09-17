import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import 'firebase_service.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: const ['email', 'profile']);

  static const _localUsersKey = 'local_users';
  static const _currentLocalUserKey = 'current_local_user';
  static const _pendingEmailLinkEmailKey = 'pending_email_link_email';
  static const _emailLinkUrl = 'https://apptiengnhat-d12b7.web.app/auth/email-link';
  static const _uuid = Uuid();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<AppUser?> getCurrentUser() async {
    if (FirebaseService.isEnabled) {
      final user = _auth.currentUser;
      if (user != null) {
        return _fromFirebaseUser(user);
      }
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentLocalUserKey);
    if (raw == null) return null;

    final user = AppUser.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    if (user.provider == 'google' || user.provider == 'facebook') {
      await prefs.remove(_currentLocalUserKey);
      return null;
    }
    return user;
  }

  Future<AppUser> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (FirebaseService.isEnabled) {
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        await credential.user?.updateDisplayName(displayName.trim());
        return _fromFirebaseUser(credential.user!).copyWith(
          displayName: displayName.trim().isEmpty ? 'Học viên NihonGo' : displayName.trim(),
        );
      } on FirebaseAuthException catch (e) {
        throw Exception(_mapFirebaseAuthError(e));
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final users = _readLocalUsers(prefs);
    if (users.any((u) => (u['email'] as String?)?.toLowerCase() == normalizedEmail)) {
      throw Exception('Email này đã được đăng ký rồi. Hãy đăng nhập nhé.');
    }

    final user = AppUser(
      uid: _uuid.v4(),
      email: normalizedEmail,
      displayName: displayName.trim().isEmpty ? 'Học viên NihonGo' : displayName.trim(),
      provider: 'email_local',
      createdAt: DateTime.now(),
    );

    users.add({...user.toMap(), 'password': password});
    await prefs.setString(_localUsersKey, jsonEncode(users));
    await prefs.setString(_currentLocalUserKey, jsonEncode(user.toMap()));
    return user;
  }

  Future<AppUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (FirebaseService.isEnabled) {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        return _fromFirebaseUser(credential.user!);
      } on FirebaseAuthException catch (e) {
        throw Exception(_mapFirebaseAuthError(e));
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final users = _readLocalUsers(prefs);
    final userByEmail = users.where(
      (u) => (u['email'] as String?)?.toLowerCase() == normalizedEmail,
    );

    if (userByEmail.isEmpty) {
      throw Exception('Chưa có tài khoản với email này. Hãy đăng ký trước nhé.');
    }

    final matched = userByEmail.where((u) => u['password'] == password).toList();
    if (matched.isEmpty) {
      throw Exception('Mật khẩu chưa đúng. Vui lòng thử lại.');
    }

    final user = AppUser.fromMap(matched.first);
    await prefs.setString(_currentLocalUserKey, jsonEncode(user.toMap()));
    return user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (FirebaseService.isEnabled) {
      try {
        await _auth.sendPasswordResetEmail(email: normalizedEmail);
        return;
      } on FirebaseAuthException catch (e) {
        throw Exception(_mapFirebaseAuthError(e));
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final users = _readLocalUsers(prefs);
    final exists = users.any((u) => (u['email'] as String?)?.toLowerCase() == normalizedEmail);
    if (!exists) {
      throw Exception('Không tìm thấy tài khoản với email này.');
    }
  }

  Future<AppUser> signInWithGoogle() async {
    if (!FirebaseService.isEnabled) {
      throw Exception(
        'Firebase Auth chưa sẵn sàng. Hãy bật Google provider, thêm SHA-1/SHA-256 rồi tải lại google-services.json.',
      );
    }

    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'});
        final userCredential = await _auth.signInWithPopup(provider);
        final user = userCredential.user;
        if (user == null) {
          throw Exception('Không lấy được thông tin tài khoản Google.');
        }
        return _fromFirebaseUser(user);
      }

      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Bạn đã hủy đăng nhập Google.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Không lấy được thông tin tài khoản Google.');
      }
      return _fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } catch (e) {
      final raw = e.toString().toLowerCase();
      if (raw.contains('sign_in_canceled') || raw.contains('canceled') || raw.contains('cancel')) {
        throw Exception('Bạn đã hủy đăng nhập Google.');
      }
      if (raw.contains('network')) {
        throw Exception('Mạng đang không ổn định. Vui lòng thử lại.');
      }
      if (raw.contains('10') || raw.contains('developer_error') || raw.contains('sign_in_failed')) {
        throw Exception(
          'Google Sign-In chưa cấu hình xong trên Firebase. Hãy bật Google provider, thêm SHA-1/SHA-256 và tải lại google-services.json mới.',
        );
      }
      throw Exception(
        'Google Sign-In chưa cấu hình đúng. Hãy kiểm tra Google provider, SHA-1/SHA-256 và file google-services.json.',
      );
    }
  }

  Future<void> sendSignInLinkToEmail(String email) async {
    if (!FirebaseService.isEnabled) {
      throw Exception('Firebase Auth chưa sẵn sàng để gửi link đăng nhập qua email.');
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (!normalizedEmail.contains('@')) {
      throw Exception('Vui lòng nhập email hợp lệ để nhận link đăng nhập.');
    }

    final actionCodeSettings = ActionCodeSettings(
      url: _emailLinkUrl,
      handleCodeInApp: true,
      iOSBundleId: 'com.example.nihongoMaster',
      androidPackageName: 'com.example.nihongo_master',
      androidInstallApp: true,
      androidMinimumVersion: '23',
    );

    try {
      await _auth.sendSignInLinkToEmail(
        email: normalizedEmail,
        actionCodeSettings: actionCodeSettings,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingEmailLinkEmailKey, normalizedEmail);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    }
  }

  bool isEmailSignInLink(String emailLink) {
    if (!FirebaseService.isEnabled) return false;
    return _auth.isSignInWithEmailLink(emailLink);
  }

  Future<AppUser> signInWithEmailLink(Uri uri, {String? emailOverride}) async {
    final emailLink = uri.toString();
    if (!isEmailSignInLink(emailLink)) {
      throw Exception('Đây không phải link đăng nhập hợp lệ.');
    }

    final prefs = await SharedPreferences.getInstance();
    final email = (emailOverride ?? prefs.getString(_pendingEmailLinkEmailKey) ?? '')
        .trim()
        .toLowerCase();

    if (email.isEmpty) {
      throw Exception(
        'Không tìm thấy email đang chờ xác thực. Hãy nhập email rồi gửi lại link đăng nhập trên cùng thiết bị.',
      );
    }

    try {
      final userCredential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
      await prefs.remove(_pendingEmailLinkEmailKey);
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Không thể hoàn tất đăng nhập bằng email link.');
      }
      return _fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    }
  }

  Future<void> signOut() async {
    if (FirebaseService.isEnabled) {
      await _auth.signOut();
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentLocalUserKey);
    await prefs.remove(_pendingEmailLinkEmailKey);
  }

  AppUser _fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'Học viên NihonGo',
      photoUrl: user.photoURL,
      provider: user.providerData.isNotEmpty ? user.providerData.first.providerId : 'firebase',
      createdAt: DateTime.now(),
    );
  }

  List<Map<String, dynamic>> _readLocalUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_localUsersKey);
    if (raw == null || raw.isEmpty) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Chưa có tài khoản với email này. Hãy đăng ký trước nhé.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mật khẩu chưa đúng. Vui lòng thử lại.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký rồi. Hãy đăng nhập nhé.';
      case 'weak-password':
        return 'Mật khẩu còn yếu. Hãy dùng ít nhất 6 ký tự.';
      case 'network-request-failed':
        return 'Mạng đang không ổn định. Vui lòng thử lại.';
      case 'account-exists-with-different-credential':
        return 'Email này đã liên kết với một phương thức đăng nhập khác.';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhanh. Vui lòng thử lại sau ít phút.';
      case 'invalid-action-code':
      case 'expired-action-code':
        return 'Link đăng nhập đã hết hạn hoặc không còn hợp lệ. Hãy gửi lại link mới.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được bật trong Firebase Console.';
      default:
        return e.message ?? 'Đăng nhập thất bại. Vui lòng thử lại.';
    }
  }
}
