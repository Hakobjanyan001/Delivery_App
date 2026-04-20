import 'dart:async';
import '../models/user_model.dart';

class AuthRepository {
  AppUser? _currentUser;
  
  final StreamController<AppUser?> _authStateController = StreamController<AppUser?>.broadcast();

  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  AppUser? get currentUser => _currentUser;

  Future<AppUser> signInWithEmail(String email, String password) async {
    if (email == 'test@example.com' && password == '123456') {
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = AppUser.mock();
      _authStateController.add(_currentUser);
      return _currentUser!;
    } else {
      throw 'Սխալ էլ․ հասցե կամ գաղտնաբառ։';
    }
  }

  Future<AppUser> registerWithEmail(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = AppUser(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      displayName: name,
    );
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

/*
  Future<AppUser> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = AppUser.mock();
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  Future<AppUser> signInWithFacebook() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = AppUser.mock();
    _authStateController.add(_currentUser);
    return _currentUser!;
  }
*/

  Future<AppUser> signInAnonymously() async {
    await Future.delayed(const Duration(seconds: 500));
    _currentUser = AppUser(
      uid: 'anon-${DateTime.now().millisecondsSinceEpoch}',
      email: 'anonymous@example.com',
      isAnonymous: true,
    );
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String errorMessage) verificationFailed,
    required Function(AppUser user) verificationCompleted,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    codeSent('mock-verification-id', 1);
  }

/*

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
*/
  Future<AppUser> signInWithPhone(String verificationId, String smsCode) async {
    if (smsCode == '123456') {
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = AppUser.mock();
      _authStateController.add(_currentUser);
      return _currentUser!;
    } else {
      throw 'Սխալ SMS կոդ։'; // Invalid SMS code
    }
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _authStateController.add(null);
  }

  Future<bool> checkIfIdentifierExists({String? email, String? phone, String? username}) async {
    /* 
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
    */

    await Future.delayed(const Duration(milliseconds: 500));
    if (email == 'test@example.com') return true;
    return false;
  }

  Future<String?> getEmailFromUsername(String username) async {
    /*
        final snapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.get('email') as String?;
    }
    */
    if (username.toLowerCase() == 'testuser') return 'test@example.com';
    return null;
  }

  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    /*
        final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
    */
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentUser != null) {
      return _currentUser!.toJson();
    }
    return null;
  }

  /*
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
    */
  Future<void> saveUserData(AppUser user, {String? name, String? phone, String? username}) async {
    // Mock save
    await Future.delayed(const Duration(milliseconds: 500));
  }

/*
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
    */
  void dispose() {
    _authStateController.close();
  }
}
