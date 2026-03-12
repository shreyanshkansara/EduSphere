// File generated to provide Firebase Web Initialization Options.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'Android options must be generated via flutterfire configure.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS options must be generated via flutterfire configure.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'macOS options must be generated via flutterfire configure.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Windows options must be generated via flutterfire configure.',
        );
      case TargetPlatform.linux:
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCT7M2wybf7ZLlUHivfvq5yfrTU1lhRwkQ',
    appId: '1:640245497763:web:e64a7565cd8192acd3a416',
    messagingSenderId: '640245497763',
    projectId: 'edusphere-2891f',
    authDomain: 'edusphere-2891f.firebaseapp.com',
    storageBucket: 'edusphere-2891f.firebasestorage.app',
    measurementId: 'G-4F5DDKWVC3',
  );
}
