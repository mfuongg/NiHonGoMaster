import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDsKlA1cjeeaCapz4aVXngubM-JBLTVeu0',
        appId: '1:53558536677:web:ee39e0a5e4d5e2aa20e70c',
        messagingSenderId: '53558536677',
        projectId: 'apptiengnhat-d12b7',
        authDomain: 'apptiengnhat-d12b7.firebaseapp.com',
        storageBucket: 'apptiengnhat-d12b7.firebasestorage.app',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyC_FaCUo83SiHE5FdxWlVKMsejRIEuGnH4',
          appId: '1:53558536677:android:c0a753e9de8a488e20e70c',
          messagingSenderId: '53558536677',
          projectId: 'apptiengnhat-d12b7',
          storageBucket: 'apptiengnhat-d12b7.firebasestorage.app',
        );

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDYwStgeHH6dr9d3CYBWty4sSuUmVNabSk',
          appId: '1:53558536677:ios:ea2ce4453ee36d1b20e70c',
          messagingSenderId: '53558536677',
          projectId: 'apptiengnhat-d12b7',
          storageBucket: 'apptiengnhat-d12b7.firebasestorage.app',
          iosBundleId: 'com.example.nihongoMaster',
        );

      default:
        throw UnsupportedError(
          'This platform is not configured for Firebase.',
        );
    }
  }
}


class AppFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      DefaultFirebaseOptions.currentPlatform;
}
