import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyBU3lBxkvkC1_yFinMfeaiwSKh9QR_XGZX4',
      appId: '1:9177890341:web:9ddbb36a69425e7b6fc9cc',
      messagingSenderId: '9177890341',
      projectId: 'rake-trainer',
      authDomain: 'rake-trainer.firebaseapp.com',
      storageBucket: 'rake-trainer.firebasestorage.app',
      measurementId: 'G-YYQFM6W8NH',
    );
  }
}
