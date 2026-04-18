import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../data/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  AuthProvider() {
    _user = _repository.currentUser;
    if (_user != null) {
      _loadUserData();
    }
    _repository.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      } else {
        _firestoreName = null;
        _firestorePhone = null;
      }
      notifyListeners();
    });
  }

  String? _firestoreName;
  String? _firestorePhone;

  Future<void> _loadUserData() async {
    if (_user == null) return;
    try {
      final data = await _repository.fetchUserData(_user!.uid);
      if (data != null) {
        _firestoreName = data['displayName'];
        _firestorePhone = data['phoneNumber'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data from Firestore: $e');
    }
  }

  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userName => _firestoreName ?? _user?.displayName ?? _user?.email?.split('@')[0];
  String? get email => _user?.email;
  String? get phone => _firestorePhone ?? _user?.phoneNumber;
  String? get profileImagePath => _user?.photoURL;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      String email = identifier.trim();
      
      // Ete nman che email-i, pordzir stanal email-y username-ic
      if (!email.contains('@')) {
        final resolvedEmail = await _repository.getEmailFromUsername(email);
        if (resolvedEmail == null) {
          _setError('Օգտատերը չի գտնվել:'); // User not found
          return false;
        }
        email = resolvedEmail;
      }

      final credential = await _repository.signInWithEmail(email, password);
      if (credential.user != null) {
        await _repository.saveUserData(credential.user!);
        await _loadUserData();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String username, String email, String password, String phoneNumber) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _repository.registerWithEmail(name, email, password);
      if (credential.user != null) {
        await _repository.saveUserData(credential.user!, name: name, username: username, phone: phoneNumber);
        await _loadUserData();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _repository.signInWithGoogle();
      if (credential.user != null) {
        await _repository.saveUserData(credential.user!);
        await _loadUserData();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _repository.signInWithFacebook();
      if (credential.user != null) {
        await _repository.saveUserData(credential.user!);
        await _loadUserData();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInAnonymously() async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.signInAnonymously();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String? _phoneVerificationId;
  ConfirmationResult? _webConfirmationResult; // Web-i Phone Auth-i hamard

  Future<void> verifyPhone(String phoneNumber, Function(String) onCodeSent) async {
    _setLoading(true);
    _setError(null);
    try {
      if (kIsWeb) {
        // Web-um ogtagorcum enq signInWithPhoneNumber -> ConfirmationResult
        _webConfirmationResult = await _repository.signInWithPhoneNumberWeb(phoneNumber);
        _setLoading(false);
        onCodeSent('web'); // placeholder verificationId
      } else {
        await _repository.verifyPhone(
          phoneNumber: phoneNumber,
          codeSent: (verificationId, resendToken) {
            _phoneVerificationId = verificationId;
            _setLoading(false);
            onCodeSent(verificationId);
          },
          verificationFailed: (e) {
            _setError(AuthRepository.handleAuthError(e));
            _setLoading(false);
          },
          verificationCompleted: (credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            _setLoading(false);
          },
          codeAutoRetrievalTimeout: (verificationId) {
            _phoneVerificationId = verificationId;
          },
        );
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> signInWithPhone(String smsCode, {String? phoneNumber}) async {
    _setLoading(true);
    _setError(null);
    try {
      UserCredential credential;
      if (kIsWeb && _webConfirmationResult != null) {
        // Web flow: confirm the code via ConfirmationResult
        credential = await _repository.confirmPhoneCodeWeb(_webConfirmationResult!, smsCode);
      } else {
        // Mobile flow: use verificationId
        if (_phoneVerificationId == null) return false;
        credential = await _repository.signInWithPhone(_phoneVerificationId!, smsCode);
      }
      if (credential.user != null) {
        await _repository.saveUserData(credential.user!, phone: phoneNumber);
        await _loadUserData();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({String? name, String? email, String? phone, String? imagePath}) async {
    _setLoading(true);
    _setError(null);
    try {
      if (name != null) {
        await _user?.updateDisplayName(name);
      }
      if (imagePath != null) {
        await _user?.updatePhotoURL(imagePath);
      }
      
      // Sync with Firestore
      if (_user != null) {
        await _repository.saveUserData(_user!, name: name, phone: phone);
        await _loadUserData();
      }
      
      await _user?.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
  }

  Future<bool> checkIfIdentifierExists({String? email, String? phone, String? username}) async {
    try {
      return await _repository.checkIfIdentifierExists(
        email: email, 
        phone: phone, 
        username: username
      );
    } catch (e) {
      // Ete Firestore-y xapanvi (orinak miacvac che), menq tuyl enq talis sharunakel, bayc grum enq log-um
      debugPrint('Firestore check failed: $e');
      return false;
    }
  }
}


