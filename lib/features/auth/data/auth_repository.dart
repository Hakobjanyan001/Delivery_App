import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:masoor/features/auth/models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  AppUser? _currentUser;
  String? _token;
  bool _isInitialized = false;

  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();

  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;

  Future<void> _saveAuthData(AppUser user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_user', jsonEncode(user.toJson()));
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
  }

  Future<bool> tryAutoLogin() async {
    if (_isInitialized) return _currentUser != null;
    
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) {
      _isInitialized = true;
      return false;
    }

    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('auth_user');
    
    if (userJson != null) {
      _currentUser = AppUser.fromJson(jsonDecode(userJson));
      _authStateController.add(_currentUser);
    }
    
    _isInitialized = true;
    return _currentUser != null;
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    // --- Real API Login ---
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("34");

        _currentUser = AppUser.fromJson(data['user']);
        _token = data['token'];
        
        await _saveAuthData(_currentUser!, _token!);
        
        _authStateController.add(_currentUser);
        return _currentUser!;
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Մուտքը ձախողվեց:';
      }
    } catch (e) {
      print(e);
      throw e.toString();
    }
  }

  Future<AppUser> registerWithEmail(
    String name,
    String email,
    String password, {
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone ?? '',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return await signInWithEmail(email, password);
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Գրանցումը ձախողվեց:';
      }
    } catch (e) {
      throw 'Կապի սխալ: Ստուգեք ինտերնետը: $e';
    }
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
      id: 'anon-${DateTime.now().millisecondsSinceEpoch}',
      email: 'anonymous@example.com',
      name: 'Anonymous',
      username: "demo_user",
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
      _currentUser = AppUser.fromJson({
        "username": "testuser",
        "email": "test@example.com",
        "role": "user",
        "_id": "680a6b63191859525a3c4f54",
        "phoneNumber": "",
        "isPhoneVerified": false,
        "createdAt": "2026-04-22T16:35:47.311Z",
        "updatedAt": "2026-04-22T16:35:47.311Z",
      });
      _authStateController.add(_currentUser);
      return _currentUser!;
    } else {
      throw 'Սխալ SMS կոդ։'; // Invalid SMS code
    }
  }

  Future<void> signOut() async {
    await _clearAuthData();
    _currentUser = null;
    _token = null;
    _authStateController.add(null);
  }

  Future<bool> checkIfIdentifierExists({
    String? email,
    String? phone,
    String? username,
  }) async {
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
  Future<AppUser> updateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.updateProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = AppUser.fromJson(data['user']);
        await _saveAuthData(_currentUser!, _token!);
        _authStateController.add(_currentUser);
        return _currentUser!;
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Թարմացումը ձախողվեց:';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> changeLanguage(String language) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.changeLanguage),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'language': language}),
      );

      if (response.statusCode == 200) {
        if (_currentUser != null) {
          // Update local user model
          _currentUser = AppUser.fromJson({
            ..._currentUser!.toJson(),
            'language': language,
          });
          await _saveAuthData(_currentUser!, _token!);
          _authStateController.add(_currentUser);
        }
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Լեզվի փոփոխությունը ձախողվեց:';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Address>> fetchAddresses() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getAddresses),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Address.fromJson(e)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Հասցեների բեռնումը ձախողվեց:';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Address>> addAddress(Address address) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.addAddress),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(address.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final List<dynamic> addressesJson = data['addresses'];
        final addresses = addressesJson.map((e) => Address.fromJson(e)).toList();
        
        if (_currentUser != null) {
          _currentUser = AppUser(
            id: _currentUser!.id,
            name: _currentUser!.name,
            username: _currentUser!.username,
            email: _currentUser!.email,
            phone: _currentUser!.phone,
            emailVerified: _currentUser!.emailVerified,
            firebaseUid: _currentUser!.firebaseUid,
            role: _currentUser!.role,
            is18Plus: _currentUser!.is18Plus,
            language: _currentUser!.language,
            addresses: addresses,
          );
          await _saveAuthData(_currentUser!, _token!);
          _authStateController.add(_currentUser);
        }
        return addresses;
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Հասցեի ավելացումը ձախողվեց:';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Address>> deleteAddress(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.deleteAddress}/$id'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> addressesJson = data['addresses'];
        final addresses = addressesJson.map((e) => Address.fromJson(e)).toList();

        if (_currentUser != null) {
          _currentUser = AppUser(
            id: _currentUser!.id,
            name: _currentUser!.name,
            username: _currentUser!.username,
            email: _currentUser!.email,
            phone: _currentUser!.phone,
            emailVerified: _currentUser!.emailVerified,
            firebaseUid: _currentUser!.firebaseUid,
            role: _currentUser!.role,
            is18Plus: _currentUser!.is18Plus,
            language: _currentUser!.language,
            addresses: addresses,
          );
          await _saveAuthData(_currentUser!, _token!);
          _authStateController.add(_currentUser);
        }
        return addresses;
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Հասցեի ջնջումը ձախողվեց:';
      }
    } catch (e) {
      throw e.toString();
    }
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
