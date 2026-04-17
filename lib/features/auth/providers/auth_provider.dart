import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  AuthProvider() {
    _user = _repository.currentUser;
    _repository.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userName => _user?.displayName ?? _user?.email?.split('@')[0];
  String? get email => _user?.email;
  String? get phone => _user?.phoneNumber;
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
          _setError('Ogtatery chi gtnvel:'); // Ogtatery chi gtnvel
          return false;
        }
        email = resolvedEmail;
      }

      final credential = await _repository.signInWithEmail(email, password);
      if (credential.user != null) {
        await _repository.saveUserData(credential.user!);
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String username, String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _repository.registerWithEmail(name, email, password);
      if (credential.user != null) {
        await _repository.saveUserData(credential.user!, name: name, username: username);
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

  Future<void> verifyPhone(String phoneNumber, Function(String) onCodeSent) async {
    _setLoading(true);
    _setError(null);
    try {
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
          // Avto-lucum kam akntartayin stugum mi qani sarqeri vra
          await FirebaseAuth.instance.signInWithCredential(credential);
          _setLoading(false);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _phoneVerificationId = verificationId;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> signInWithPhone(String smsCode, {String? phoneNumber}) async {
    if (_phoneVerificationId == null) return false;
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _repository.signInWithPhone(_phoneVerificationId!, smsCode);
      if (credential.user != null) {
        await _repository.saveUserData(credential.user!, phone: phoneNumber);
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
      // Nshum: Email-i ev heraxosi tarmacumnery sovorabar pahanjum en noric mutq kam hastatum. 
      // Ar-ayjm sranq lriv grac chen, vor ogtaterin chxangarenq.
      
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


