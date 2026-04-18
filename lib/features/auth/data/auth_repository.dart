import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthRepository.handleAuthError(e);
    }
  }

  Future<UserCredential> registerWithEmail(String name, String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthRepository.handleAuthError(e);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web-um ogtagorcum enq Firebase Auth-i signInWithPopup-y
        // google_sign_in plugin-y web-um "popup_closed" error e talis
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile-um ogtagorcum enq google_sign_in plugin-y
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) throw Exception('Google Sign-In cancelled');

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthRepository.handleAuthError(e);
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        return await _auth.signInWithCredential(credential);
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception('Facebook Sign-In cancelled');
      } else {
        throw Exception(result.message ?? 'Facebook Sign-In failed');
      }
    } on FirebaseAuthException catch (e) {
      throw AuthRepository.handleAuthError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw AuthRepository.handleAuthError(e);
    }
  }

  // Mobile: verifyPhoneNumber (OTP flow)
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: (e) {
          verificationFailed(e);
        },
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw AuthRepository.handleAuthError(e);
      }
      throw 'Կապի սխալ: Ստուգեք ինտերնետը:';
    }
  }

  // Web: signInWithPhoneNumber — Firebase auto-creates invisible reCAPTCHA internally
  Future<ConfirmationResult> signInWithPhoneNumberWeb(String phoneNumber) async {
    try {
      // Firebase-y inqnabern invisible reCAPTCHA e steghtsum ete verifier chi petranvum
      return await _auth.signInWithPhoneNumber(phoneNumber);
    } on FirebaseAuthException catch (e) {
      throw AuthRepository.handleAuthError(e);
    } catch (e) {
      throw 'Սխալ (${e.runtimeType}): $e';
    }
  }

  // Web: confirm the SMS code using ConfirmationResult
  Future<UserCredential> confirmPhoneCodeWeb(
      ConfirmationResult confirmationResult, String smsCode) async {
    try {
      return await confirmationResult.confirm(smsCode);
    } on FirebaseAuthException catch (e) {
      throw AuthRepository.handleAuthError(e);
    }
  }

  // Mobile: confirm using verificationId + smsCode
  Future<UserCredential> signInWithPhone(String verificationId, String smsCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthRepository.handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<bool> checkIfIdentifierExists({String? email, String? phone, String? username}) async {
    if (email != null) {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();
      if (snapshot.docs.isNotEmpty) return true;
    }
    
    if (username != null) {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .get();
      if (snapshot.docs.isNotEmpty) return true;
    }
    
    if (phone != null) {
      final snapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phone)
          .get();
      if (snapshot.docs.isNotEmpty) return true;
    }
    
    return false;
  }

  Future<String?> getEmailFromUsername(String username) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.get('email') as String?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> saveUserData(User user, {String? name, String? phone, String? username}) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    
    // Ogtagorcum enq set-y merge-ov, vor chjnjvi eghac tvyalnery ete ughaki mutq enq anum
    await userDoc.set({
      'uid': user.uid,
      'email': user.email?.toLowerCase(),
      'username': username?.toLowerCase(),
      'phoneNumber': phone ?? user.phoneNumber,
      'displayName': name ?? user.displayName,
      'lastLogin': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static String handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Օգտատերը չի գտնվել:';
      case 'wrong-password':
        return 'Սխալ գաղտնաբառ:';
      case 'email-already-in-use':
        return 'Այս էլ. հասցեն արդեն օգտագործվում է:';
      case 'weak-password':
        return 'Գաղտնաբառը շատ թույլ է:';
      case 'invalid-email':
        return 'Անվավեր էլ. հասցե:';
      case 'operation-not-allowed':
        return 'Այս մեթոդը միացված չէ Firebase-ում: Ստուգեք Console-ը (Authentication -> Sign-in methods):';
      case 'invalid-phone-number':
        return 'Անվավեր հեռախոսահամար:';
      case 'too-many-requests':
        return 'Շատ հարցումներ: Փորձեք քիչ ուշ:';
      case 'network-request-failed':
        return 'Ինտերնետ կապի սխալ:';
      case 'invalid-verification-code':
        return 'Սխալ SMS կոդ:';
      default:
        return e.message ?? 'Տեղի է ունեցել սխալ (${e.code}):';
    }
  }
}
