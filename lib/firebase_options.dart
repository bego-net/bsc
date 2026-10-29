import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Run `flutterfire configure` to replace these placeholders with your actual project keys.
class DefaultFirebaseOptions {
  /// Returns true only if real Firebase credentials are provided rather than placeholder values.
  static bool get isConfigured {
    try {
      final key = currentPlatform.apiKey;
      return key.isNotEmpty && !key.contains('Placeholder');
    } catch (_) {
      return false;
    }
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderApiKeyForWeb',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'bible-study-app',
    authDomain: 'bible-study-app.firebaseapp.com',
    storageBucket: 'bible-study-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderApiKeyForAndroid',
    appId: '1:1234567890:android:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'bible-study-app',
    storageBucket: 'bible-study-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderApiKeyForIOS',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'bible-study-app',
    storageBucket: 'bible-study-app.appspot.com',
    iosBundleId: 'com.example.bibleStudy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderApiKeyForWindows',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'bible-study-app',
    authDomain: 'bible-study-app.firebaseapp.com',
    storageBucket: 'bible-study-app.appspot.com',
  );
}
