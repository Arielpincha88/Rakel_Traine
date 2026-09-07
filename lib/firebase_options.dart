import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBU3lBxkvkC1_yFinMfeaiwSKh9QR_XGZX4',
    appId: '1:9177890341:web:9ddbb36a69425e7b6fc9cc',
    messagingSenderId: '9177890341',
    projectId: 'rake-trainer',
    authDomain: 'rake-trainer.firebaseapp.com',
    storageBucket: 'rake-trainer.firebasestorage.app',
    measurementId: 'G-YYQFM6W8NH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqe-vOstQu6ggYYsZ6s7YgtrlDMue5kuA',
    appId: '1:9177890341:android:dd60c711bac3e4d46fc9cc',
    messagingSenderId: '9177890341',
    projectId: 'rake-trainer',
    storageBucket: 'rake-trainer.firebasestorage.app',
  );
}
