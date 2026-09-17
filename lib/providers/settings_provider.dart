import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/bgm_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _showRomaji = true;
  bool _showVietnamese = true;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  String _studyLanguage = 'vi';
  bool _isOnboarded = false;

  bool get isDarkMode => _isDarkMode;
  bool get showRomaji => _showRomaji;
  bool get showVietnamese => _showVietnamese;
  bool get soundEnabled => _soundEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  String get studyLanguage => _studyLanguage;
  bool get isOnboarded => _isOnboarded;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? false;
    _showRomaji = prefs.getBool('show_romaji') ?? true;
    _showVietnamese = prefs.getBool('show_vietnamese') ?? true;
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _notificationsEnabled = prefs.getBool('notifications') ?? true;
    _studyLanguage = prefs.getString('study_language') ?? 'vi';
    _isOnboarded = prefs.getBool(AppConstants.keyOnboarded) ?? false;

    if (_notificationsEnabled) {
      await NotificationService.instance.scheduleDailyStudyReminder();
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleRomaji() async {
    _showRomaji = !_showRomaji;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_romaji', _showRomaji);
    notifyListeners();
  }

  Future<void> toggleVietnamese() async {
    _showVietnamese = !_showVietnamese;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_vietnamese', _showVietnamese);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    if (!_soundEnabled) {
      await BgmService.instance.stop();
    }
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    if (_notificationsEnabled) {
      await NotificationService.instance.scheduleDailyStudyReminder();
    } else {
      await NotificationService.instance.cancelDailyStudyReminder();
    }
    notifyListeners();
  }

  Future<void> setOnboarded() async {
    _isOnboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboarded, true);
    notifyListeners();
  }
}
