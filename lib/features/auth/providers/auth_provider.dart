import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;
  AppUser? _user;

  AuthProvider() {
    _user = _repository.currentUser;
    if (_user != null) {
      _loadUserData();
    }
    _repository.authStateChanges.listen((AppUser? user) {
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
      final data = await _repository.fetchUserData(_user!.id);
      if (data != null) {
        _firestoreName = data['displayName'];
        _firestorePhone = data['phoneNumber'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  bool get isAuthenticated => _user != null;
  // bool get isAnonymous => _user?.isAnonymous ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userName =>
      _firestoreName ?? _user?.name.toString() ?? _user?.email.split('@')[0];
  String? get email => _user?.email;
  String? get phone => _firestorePhone ?? _user?.phone;

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

      if (!email.contains('@')) {
        final resolvedEmail = await _repository.getEmailFromUsername(email);
        if (resolvedEmail == null) {
          _setError('Օգտատերը չի գտնվել:'); // User not found
          return false;
        }
        email = resolvedEmail;
      }

      await _repository.signInWithEmail(email, password);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
    String name,
    String username,
    String email,
    String password,
    String phoneNumber,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.registerWithEmail(
        name,
        email,
        password,
        phone: phoneNumber,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /*
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.signInWithGoogle();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
*/

  /*
  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.signInWithFacebook();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
*/

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

  Future<void> verifyPhone(
    String phoneNumber,
    Function(String) onCodeSent,
  ) async {
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
        verificationFailed: (errorMessage) {
          _setError(errorMessage);
          _setLoading(false);
        },
        verificationCompleted: (user) {
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
    _setLoading(true);
    _setError(null);
    try {
      if (_phoneVerificationId == null && smsCode != '123456') return false;
      await _repository.signInWithPhone(
        _phoneVerificationId ?? 'mock',
        smsCode,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? imagePath,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      // Mock update
      await Future.delayed(const Duration(seconds: 1));
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

  Future<bool> checkIfIdentifierExists({
    String? email,
    String? phone,
    String? username,
  }) async {
    try {
      return await _repository.checkIfIdentifierExists(
        email: email,
        phone: phone,
        username: username,
      );
    } catch (e) {
      debugPrint('Check failed: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
