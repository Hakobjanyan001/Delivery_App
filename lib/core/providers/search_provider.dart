import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/restaurant_model.dart';

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

  void updateQuery(String newQuery, List<RestaurantModel> restaurants, List<ProductModel> products) {
    _searchQuery = newQuery;
    if (newQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
    } else {
      _performSearch(newQuery, restaurants, products);
    }
  }

  void _performSearch(String query, List<RestaurantModel> restaurants, List<ProductModel> products) {
    _isLoading = true;
    notifyListeners();

    try {
      final filteredRestaurants = restaurants.where((r) => 
        r.name.hy.toLowerCase().contains(query.toLowerCase()) ||
        r.name.en.toLowerCase().contains(query.toLowerCase()) ||
        r.name.ru.toLowerCase().contains(query.toLowerCase())
      ).toList();

      final filteredProducts = products.where((p) => 
        p.name.hy.toLowerCase().contains(query.toLowerCase()) ||
        p.name.en.toLowerCase().contains(query.toLowerCase()) ||
        p.name.ru.toLowerCase().contains(query.toLowerCase())
      ).toList();

      _searchResults = [...filteredRestaurants, ...filteredProducts];
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
