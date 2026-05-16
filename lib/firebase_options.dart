// ╔══════════════════════════════════════════════════════════════════╗
// ║           FIREBASE OPTIONS - PLACEHOLDER                        ║
// ║                                                                  ║
// ║  Replace this file using ONE of these methods:                  ║
// ║                                                                  ║
// ║  METHOD 1 (Recommended - FlutterFire CLI):                      ║
// ║    dart pub global activate flutterfire_cli                     ║
// ║    cd flutter_app                                                ║
// ║    flutterfire configure                                         ║
// ║                                                                  ║
// ║  METHOD 2 (Manual):                                              ║
// ║    1. Go to https://console.firebase.google.com/                 ║
// ║    2. Select/create your project                                 ║
// ║    3. Project Settings → Your Apps → Add Android App            ║
// ║       Package: com.fairserve.app                                 ║
// ║    4. Download google-services.json → place in android/app/     ║
// ║    5. Replace the placeholder values below with your real values ║
// ║                                                                  ║
// ║  ENABLE PHONE AUTH:                                              ║
// ║    Firebase Console → Authentication → Sign-in method           ║
// ║    → Phone → Enable                                              ║
// ╚══════════════════════════════════════════════════════════════════╝

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'Run: flutterfire configure',
        );
    }
  }

  // ⚠️ Replace ALL placeholder values with your Firebase project values
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:000000000000:web:000000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-fairserve-project',
    authDomain: 'your-fairserve-project.firebaseapp.com',
    storageBucket: 'your-fairserve-project.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:000000000000:android:000000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-fairserve-project',
    storageBucket: 'your-fairserve-project.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:000000000000:ios:000000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-fairserve-project',
    storageBucket: 'your-fairserve-project.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
    iosBundleId: 'com.fairserve.app',
  );
}
