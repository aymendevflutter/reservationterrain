import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyATXOzqROEuM151opESZ_abNrOYBz0e8q0',
    appId: '1:89289515793:web:da982375e4adcb77c262b0',
    messagingSenderId: '89289515793',
    projectId: 'reservationterrain-f56d4',
    authDomain: 'reservationterrain-f56d4.firebaseapp.com',
    storageBucket: 'reservationterrain-f56d4.firebasestorage.app',
    measurementId: 'G-GFMEZ1140X',
  );

  // TODO: Replace with your Firebase Web configuration

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_U5pOvi2o55f_r-LIwe9lgo1oFIXS95A',
    appId: '1:89289515793:android:ffbf8e6547a1af08c262b0',
    messagingSenderId: '89289515793',
    projectId: 'reservationterrain-f56d4',
    storageBucket: 'reservationterrain-f56d4.firebasestorage.app',
  );

  // TODO: Replace with your Firebase Android configuration

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCoyM0Xwmm9vGqCnm5QI_fNfZpTmLVqPIw',
    appId: '1:89289515793:ios:2347a7972dd53ac1c262b0',
    messagingSenderId: '89289515793',
    projectId: 'reservationterrain-f56d4',
    storageBucket: 'reservationterrain-f56d4.firebasestorage.app',
    iosBundleId: 'com.example.reservationterrain',
  );

  // TODO: Replace with your Firebase iOS configuration

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCoyM0Xwmm9vGqCnm5QI_fNfZpTmLVqPIw',
    appId: '1:89289515793:ios:2347a7972dd53ac1c262b0',
    messagingSenderId: '89289515793',
    projectId: 'reservationterrain-f56d4',
    storageBucket: 'reservationterrain-f56d4.firebasestorage.app',
    iosBundleId: 'com.example.reservationterrain',
  );

  // TODO: Replace with your Firebase macOS configuration

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyATXOzqROEuM151opESZ_abNrOYBz0e8q0',
    appId: '1:89289515793:web:3461fca65ec93d09c262b0',
    messagingSenderId: '89289515793',
    projectId: 'reservationterrain-f56d4',
    authDomain: 'reservationterrain-f56d4.firebaseapp.com',
    storageBucket: 'reservationterrain-f56d4.firebasestorage.app',
    measurementId: 'G-8HQM2CX9M0',
  );

}