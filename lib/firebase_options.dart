// ⚠️  PLACEHOLDER — Run `flutterfire configure` to replace with real values.
// Steps:
//   1. Go to https://console.firebase.google.com and create a project
//   2. Enable: Email/Password, Google, Phone, Anonymous (Authentication → Sign-in method)
//   3. In your terminal run:  flutterfire configure
//   4. Select your project → this file gets replaced automatically

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
      default:
        throw UnsupportedError('Platform not configured. Run: flutterfire configure');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBL9QWXjY5N8JhjD188z_fWG3C8VJz7AaA',
    appId: '1:797518535071:android:023cc8f9ae39354fd5c5aa',
    messagingSenderId: '797518535071',
    projectId: 'delivery-app-karen',
    storageBucket: 'delivery-app-karen.firebasestorage.app',
  );

  // TODO: Replace with real values — run: flutterfire configure

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALD3-hbcdo3ynyd660-OLEeGu8IidCY6E',
    appId: '1:797518535071:ios:23bdfd863c3642bfd5c5aa',
    messagingSenderId: '797518535071',
    projectId: 'delivery-app-karen',
    storageBucket: 'delivery-app-karen.firebasestorage.app',
    iosBundleId: 'com.example.deliveryApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDnm7J4sl6asov5_Hs0IYMHI3yPwHO7DBo',
    appId: '1:797518535071:web:78b1f1a85bb87138d5c5aa',
    messagingSenderId: '797518535071',
    projectId: 'delivery-app-karen',
    authDomain: 'delivery-app-karen.firebaseapp.com',
    storageBucket: 'delivery-app-karen.firebasestorage.app',
  );

}