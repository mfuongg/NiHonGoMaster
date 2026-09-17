import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool _enabled = false;

  static bool get isInitialized => _initialized;
  static bool get isEnabled => _enabled;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _enabled = true;
      _initialized = true;
    } catch (e) {
      _enabled = false;
      _initialized = true;
    }
  }
}
