// PUBLIC SHOWCASE STUB — Replace by running `flutterfire configure` with your own Firebase project.
// Do not use production credentials in a public repository.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'CONFIGURE_ME_ANDROID_API_KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'filmtrace-showcase-placeholder',
    storageBucket: 'filmtrace-showcase-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'CONFIGURE_ME_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'filmtrace-showcase-placeholder',
    storageBucket: 'filmtrace-showcase-placeholder.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'CONFIGURE_ME_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'filmtrace-showcase-placeholder',
    storageBucket: 'filmtrace-showcase-placeholder.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'CONFIGURE_ME_WEB_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'filmtrace-showcase-placeholder',
    storageBucket: 'filmtrace-showcase-placeholder.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'CONFIGURE_ME_WEB_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'filmtrace-showcase-placeholder',
    storageBucket: 'filmtrace-showcase-placeholder.appspot.com',
  );
}
