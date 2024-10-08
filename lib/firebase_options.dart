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
    apiKey: 'AIzaSyCt7JIlvYTw1oBmQPJyGxExH0zCaRU5jYY',
    appId: '1:233482499247:web:2d1529598e793043b7105a',
    messagingSenderId: '233482499247',
    projectId: 'double-joo',
    authDomain: 'double-joo.firebaseapp.com',
    storageBucket: 'double-joo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjTzdAvaOhcSfqI2gafbAOZbQ6XFKaRRs',
    appId: '1:233482499247:android:41c24fe2553cad9db7105a',
    messagingSenderId: '233482499247',
    projectId: 'double-joo',
    storageBucket: 'double-joo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJMsk9nccvX1qYcKC7HJ3nNt0X2GmQVvo',
    appId: '1:233482499247:ios:969c62e3241b0d7cb7105a',
    messagingSenderId: '233482499247',
    projectId: 'double-joo',
    storageBucket: 'double-joo.appspot.com',
    iosBundleId: 'com.example.doubleJoo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBJMsk9nccvX1qYcKC7HJ3nNt0X2GmQVvo',
    appId: '1:233482499247:ios:969c62e3241b0d7cb7105a',
    messagingSenderId: '233482499247',
    projectId: 'double-joo',
    storageBucket: 'double-joo.appspot.com',
    iosBundleId: 'com.example.doubleJoo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCt7JIlvYTw1oBmQPJyGxExH0zCaRU5jYY',
    appId: '1:233482499247:web:fd107ed671ffd13ab7105a',
    messagingSenderId: '233482499247',
    projectId: 'double-joo',
    authDomain: 'double-joo.firebaseapp.com',
    storageBucket: 'double-joo.appspot.com',
  );
}
