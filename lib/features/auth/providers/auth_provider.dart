import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userName;
  String? _email;
  String? _phone;
  String? _profileImagePath;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  String? get email => _email;
  String? get phone => _phone;
  String? get profileImagePath => _profileImagePath;

  void login(String email, String password) {
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _email = email;
      _userName = email.split('@')[0];
      _phone = '+374 00 000000'; // Default mock phone
      notifyListeners();
    }
  }

  void register(String name, String email, String password) {
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userName = name;
      _email = email;
      _phone = '+374 00 000000';
      notifyListeners();
    }
  }

  void updateProfile({String? name, String? email, String? phone, String? imagePath}) {
    if (name != null) _userName = name;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    if (imagePath != null) _profileImagePath = imagePath;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userName = null;
    _email = null;
    _phone = null;
    _profileImagePath = null;
    notifyListeners();
  }
}
