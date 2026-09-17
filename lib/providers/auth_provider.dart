import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<void> init() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.getCurrentUser();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _runAuthAction(() async {
      _currentUser = await _authService.signInWithEmailPassword(email: email, password: password);
      await _firestoreService.syncUserProfile(_currentUser!);
      await _firestoreService.logLoginActivity(_currentUser!);
      return true;
    });
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _runAuthAction(() async {
      _currentUser = await _authService.registerWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      await _firestoreService.syncUserProfile(_currentUser!);
      await _firestoreService.logLoginActivity(_currentUser!);
      return true;
    });
  }

  Future<bool> signInWithGoogle() async {
    return _runAuthAction(() async {
      _currentUser = await _authService.signInWithGoogle();
      await _firestoreService.syncUserProfile(_currentUser!);
      await _firestoreService.logLoginActivity(_currentUser!);
      return true;
    });
  }

  Future<bool> sendLoginLink(String email) async {
    return _runAuthAction(() async {
      await _authService.sendSignInLinkToEmail(email);
      return true;
    });
  }

  bool isEmailSignInLinkUri(Uri uri) {
    return _authService.isEmailSignInLink(uri.toString());
  }

  Future<bool> tryCompleteEmailLinkSignIn(Uri uri, {String? email}) async {
    if (!isEmailSignInLinkUri(uri)) {
      return false;
    }

    return _runAuthAction(() async {
      _currentUser = await _authService.signInWithEmailLink(uri, emailOverride: email);
      await _firestoreService.syncUserProfile(_currentUser!);
      await _firestoreService.logLoginActivity(_currentUser!);
      return true;
    });
  }

  Future<bool> sendResetPassword(String email) async {
    return _runAuthAction(() async {
      await _authService.sendPasswordResetEmail(email);
      return true;
    });
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      if (_currentUser != null) {
        await _firestoreService.logLogoutActivity(_currentUser!);
      }
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _runAuthAction(Future<bool> Function() action) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await action();
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
