// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDy96pdjfN5Dn31Zwds2CLi84mpXZZaz30',
    appId: '1:975550638067:web:ef93a0e801a7f11d34d486',
    messagingSenderId: '975550638067',
    projectId: 'portfolio1-f2558',
    authDomain: 'portfolio1-f2558.firebaseapp.com',
    storageBucket: 'portfolio1-f2558.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAza2r3sgDnhjU0oUCJUSMW_izfGHv5tjo',
    appId: '1:975550638067:android:929e972d2f34dd9634d486',
    messagingSenderId: '975550638067',
    projectId: 'portfolio1-f2558',
    storageBucket: 'portfolio1-f2558.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCB4gtvM6X7aFQ6l_TCm_lsBppXHuGob3M',
    appId: '1:975550638067:ios:1958b3c5e7ff9f4734d486',
    messagingSenderId: '975550638067',
    projectId: 'portfolio1-f2558',
    storageBucket: 'portfolio1-f2558.appspot.com',
    iosClientId: '975550638067-t33vvu169dt6oq77466mhkgkse1tkqop.apps.googleusercontent.com',
    iosBundleId: 'com.example.portfolioVer1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCB4gtvM6X7aFQ6l_TCm_lsBppXHuGob3M',
    appId: '1:975550638067:ios:1958b3c5e7ff9f4734d486',
    messagingSenderId: '975550638067',
    projectId: 'portfolio1-f2558',
    storageBucket: 'portfolio1-f2558.appspot.com',
    iosClientId: '975550638067-t33vvu169dt6oq77466mhkgkse1tkqop.apps.googleusercontent.com',
    iosBundleId: 'com.example.portfolioVer1',
  );
}
