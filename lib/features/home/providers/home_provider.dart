import 'package:flutter/material.dart';
import '../data/banner_repository.dart';
import '../data/category_repository.dart';
import '../data/restaurant_repository.dart';
import '../data/product_repository.dart';
import '../../../core/models/banner_model.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/restaurant_model.dart';
import '../../../core/models/product_model.dart';

class HomeProvider with ChangeNotifier {
  final BannerRepository _bannerRepo = BannerRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final RestaurantRepository _restaurantRepo = RestaurantRepository();
  final ProductRepository _productRepo = ProductRepository();

  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  List<RestaurantModel> _restaurants = [];
  List<ProductModel> _products = [];
  
  bool _isLoading = false;
  String? _error;

  List<BannerModel> get banners => _banners;
  List<CategoryModel> get categories => _categories;
  List<RestaurantModel> get restaurants => _restaurants;
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all data concurrently
      final results = await Future.wait([
        _bannerRepo.getBanners(),
        _categoryRepo.getCategories(),
        _restaurantRepo.getRestaurants(),
        _productRepo.getProducts(),
      ]);

      _banners = results[0] as List<BannerModel>;
      _categories = results[1] as List<CategoryModel>;
      _restaurants = results[2] as List<RestaurantModel>;
      _products = results[3] as List<ProductModel>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  List<ProductModel> getProductsByCategory(String? categoryId) {
    if (categoryId == null || categoryId == 'all') {
      return _products;
    }
    return _products.where((p) => p.categoryId == categoryId).toList();
  }
}
