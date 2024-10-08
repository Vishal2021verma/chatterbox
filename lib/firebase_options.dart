// File generated by FlutterFire CLI.
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
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyD7Bay91hLylqVuozw5ujmPvDyvjwrXSDE',
    appId: '1:741270119105:web:cb517eca4be9b4af41aa40',
    messagingSenderId: '741270119105',
    projectId: 'chatterbox-83ce2',
    authDomain: 'chatterbox-83ce2.firebaseapp.com',
    storageBucket: 'chatterbox-83ce2.appspot.com',
    measurementId: 'G-LMJQ0SPZ2R',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2vRJRhZJEBdCQyvsnsP7RWSVJiqc_AWQ',
    appId: '1:741270119105:android:7e2225e37a9eb4f541aa40',
    messagingSenderId: '741270119105',
    projectId: 'chatterbox-83ce2',
    storageBucket: 'chatterbox-83ce2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3YUp7t3UJghp_Eiu09tISrvGMLA0F8_k',
    appId: '1:741270119105:ios:0972acf5f60353cf41aa40',
    messagingSenderId: '741270119105',
    projectId: 'chatterbox-83ce2',
    storageBucket: 'chatterbox-83ce2.appspot.com',
    iosBundleId: 'com.example.chatterbox',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA3YUp7t3UJghp_Eiu09tISrvGMLA0F8_k',
    appId: '1:741270119105:ios:0972acf5f60353cf41aa40',
    messagingSenderId: '741270119105',
    projectId: 'chatterbox-83ce2',
    storageBucket: 'chatterbox-83ce2.appspot.com',
    iosBundleId: 'com.example.chatterbox',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD7Bay91hLylqVuozw5ujmPvDyvjwrXSDE',
    appId: '1:741270119105:web:1862a403b39e9bde41aa40',
    messagingSenderId: '741270119105',
    projectId: 'chatterbox-83ce2',
    authDomain: 'chatterbox-83ce2.firebaseapp.com',
    storageBucket: 'chatterbox-83ce2.appspot.com',
    measurementId: 'G-3HL0ELSJB1',
  );
}
