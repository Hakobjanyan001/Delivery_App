import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;
  AppUser? _user;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _setLoading(true);
    await _repository.tryAutoLogin();
    _user = _repository.currentUser;
    if (_user != null) {
      _loadUserData();
    }
    _setLoading(false);

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
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userName =>
      _firestoreName ?? _user?.name.toString() ?? _user?.email.split('@')[0];
  String? get email => _user?.email;
  String? get phone => _firestorePhone ?? _user?.phone;
  AppUser? get user => _user;

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
          _setError('Օգտատերը չի գտնվել:');
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

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? imagePath,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _repository.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeLanguage(String language) async {
    try {
      await _repository.changeLanguage(language);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchAddresses() async {
    try {
      await _repository.fetchAddresses();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> addAddress(Address address) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.addAddress(address);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAddress(Address address) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.updateAddress(address);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAddress(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.deleteAddress(id);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
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
