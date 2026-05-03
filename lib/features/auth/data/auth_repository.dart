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
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
        headers: ApiConstants.getHeaders(),
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

  Future<AppUser> signInAnonymously() async {
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
    codeSent('mock-verification-id', 1);
  }

  Future<AppUser> signInWithPhone(String verificationId, String smsCode) async {
    if (smsCode == '123456') {
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
      throw 'Սխալ SMS կոդ։';
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
    if (email == 'test@example.com') return true;
    return false;
  }

  Future<String?> getEmailFromUsername(String username) async {
    if (username.toLowerCase() == 'testuser') return 'test@example.com';
    return null;
  }

  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    if (_currentUser != null) {
      return _currentUser!.toJson();
    }
    return null;
  }

  Future<AppUser> updateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.updateProfile),
        headers: ApiConstants.getHeaders(_token),
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
        headers: ApiConstants.getHeaders(_token),
        body: jsonEncode({'language': language}),
      );

      if (response.statusCode == 200) {
        if (_currentUser != null) {
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
        headers: ApiConstants.getHeaders(_token),
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
        headers: ApiConstants.getHeaders(_token),
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

  Future<List<Address>> updateAddress(Address address) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.updateAddress),
        headers: ApiConstants.getHeaders(_token),
        body: jsonEncode(address.toJson()),
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
        throw error['message'] ?? 'Հասցեի թարմացումը ձախողվեց:';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Address>> deleteAddress(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.deleteAddress}/$id'),
        headers: ApiConstants.getHeaders(_token),
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

  void dispose() {
    _authStateController.close();
  }
}
