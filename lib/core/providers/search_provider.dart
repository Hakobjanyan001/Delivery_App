import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../models/food_model.dart';

class SearchProvider extends ChangeNotifier {
  String _searchQuery = '';
  bool _isSearchActive = false;
  int _isActiveCount = 0;
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  String get searchQuery => _searchQuery;
  bool get isSearchActive => _isSearchActive;
  int get isActiveCount => _isActiveCount;
  List<dynamic> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  final ApiManager _apiManager = ApiManager();

  void updateQuery(String newQuery) {
    _searchQuery = newQuery;
    if (newQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
    } else {
      _performSearch(newQuery);
    }
  }

  Future<void> _performSearch(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Պարզության համար որոնում ենք և՛ ռեստորանների, և՛ ուտեստների մեջ
      final restaurants = await _apiManager.getRestaurants();
      final foods = await _apiManager.getFoods();

      final filteredRestaurants = restaurants.where((r) => 
        r.name.toLowerCase().contains(query.toLowerCase()) ||
        r.nameEn.toLowerCase().contains(query.toLowerCase()) ||
        r.nameRu.toLowerCase().contains(query.toLowerCase())
      ).toList();

      final filteredFoods = foods.where((f) => 
        f.name.toLowerCase().contains(query.toLowerCase()) ||
        f.nameEn.toLowerCase().contains(query.toLowerCase()) ||
        f.nameRu.toLowerCase().contains(query.toLowerCase())
      ).toList();

      _searchResults = [...filteredRestaurants, ...filteredFoods];
    } catch (e) {
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchActive(bool active) {
    if (_isSearchActive != active) {
      _isSearchActive = active;
      if (active) _isActiveCount++;
      if (!active) {
        _searchQuery = '';
        _searchResults = [];
      }
      notifyListeners();
    }
  }

  void toggleSearchActive() {
    setSearchActive(!_isSearchActive);
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearchActive = false;
    notifyListeners();
  }
}
