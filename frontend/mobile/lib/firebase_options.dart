// File generated for FlutterFire integration with sevakconnect-2026
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD5Ip4stZaSx9puAXiHbcGC863q6SUB8sU',
    appId: '1:1067821657094:web:b0a9f7ef1295954cc9a787',
    messagingSenderId: '1067821657094',
    projectId: 'sevakconnect-2026',
    authDomain: 'sevakconnect-2026.firebaseapp.com',
    storageBucket: 'sevakconnect-2026.firebasestorage.app',
    measurementId: 'G-YYGHGV50EE',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD5Ip4stZaSx9puAXiHbcGC863q6SUB8sU',
    appId: '1:1067821657094:web:524df728a4b0f47cc9a787',
    messagingSenderId: '1067821657094',
    projectId: 'sevakconnect-2026',
    authDomain: 'sevakconnect-2026.firebaseapp.com',
    storageBucket: 'sevakconnect-2026.firebasestorage.app',
    measurementId: 'G-Z77RV9RYR6',
  );
}
