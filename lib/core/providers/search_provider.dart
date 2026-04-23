import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _searchQuery = '';
  bool _isSearchActive = false;
  int _isActiveCount = 0;

  String get searchQuery => _searchQuery;
  bool get isSearchActive => _isSearchActive;
  int get isActiveCount => _isActiveCount;

  void updateQuery(String newQuery) {
    _searchQuery = newQuery;
    notifyListeners();
  }

  void setSearchActive(bool active) {
    if (_isSearchActive != active) {
      _isSearchActive = active;
      if (active) _isActiveCount++;
      if (!active) _searchQuery = '';
      notifyListeners();
    }
  }

  void toggleSearchActive() {
    setSearchActive(!_isSearchActive);
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearchActive = false;
    notifyListeners();
  }
}
