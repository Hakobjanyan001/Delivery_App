import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;

  void login(String email, String password) {
    // Mock login logic - in a real app, this would call an API
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userName = email.split('@')[0]; // Simple name from email
      notifyListeners();
    }
  }

  void register(String name, String email, String password) {
    // Mock registration logic
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userName = name;
      notifyListeners();
    }
  }

  void logout() {
    _isAuthenticated = false;
    _userName = null;
    notifyListeners();
  }
}
