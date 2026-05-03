import 'package:flutter/material.dart';
import '../../../core/models/product_model.dart';
import '../models/cart_item.dart';
import '../data/cart_repository.dart';
import '../data/local_cart_storage.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/services/routing_service.dart';
import 'package:latlong2/latlong.dart';
import '../../home/data/restaurant_repository.dart';
import '../../../core/models/restaurant_model.dart';

class CartProvider with ChangeNotifier {
  final CartRepository _cartRepository = CartRepository();
  final LocalCartStorage _localCartStorage = LocalCartStorage();
  final AuthRepository _authRepository = AuthRepository();
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  Map<String, CartItem> _items = {};
  bool _isLoading = false;
  
  // Delivery logic
  double _deliveryPrice = 0.0; // Base or per-km price
  double _freeDeliveryFrom = 0.0;
  String? _restaurantId;
  double? _restaurantLat;
  double? _restaurantLng;
  double _distanceInKm = 0.0;
  bool _isCalculatingDelivery = false;

  CartProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadCart();
    // Listen for auth changes to sync cart
    _authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        await _syncLocalCartToRemote();
      }
      await loadCart();
    });
  }

  Map<String, CartItem> get itemMap => _items;
  List<CartItem> get items => _items.values.toList();
  bool get isLoading => _isLoading;

  int get totalItemCount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity.toInt();
    });
    return total;
  }

  int getItemQuantity(String productId) {
    int count = 0;
    _items.forEach((key, cartItem) {
      if (cartItem.product.id == productId) {
        count += cartItem.quantity.toInt();
      }
    });
    return count;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.unitPrice * cartItem.quantity;
    });
    return total;
  }

  double get deliveryPrice {
    if (_items.isEmpty) return 0.0;
    if (_freeDeliveryFrom > 0 && totalAmount >= _freeDeliveryFrom) {
      return 0.0;
    }
    
    double price = _deliveryPrice > 0 ? _deliveryPrice : 500.0; // Default min 500

    if (_distanceInKm > 0) {
      if (_distanceInKm <= 5) {
        price = 500.0;
      } else {
        // 500 base + 100 for each km above 5
        price = 500.0 + ((_distanceInKm - 5) * 100);
      }
    }
    
    // Round up to nearest 100 (e.g., 610 -> 700)
    return (price / 100).ceil() * 100.0;
  }

  double get distanceInKm => _distanceInKm;
  bool get isCalculatingDelivery => _isCalculatingDelivery;
  double? get restaurantLat => _restaurantLat;
  double? get restaurantLng => _restaurantLng;

  double get finalAmount => totalAmount + deliveryPrice;

  void setDeliverySettings({
    required double basePrice,
    required double freeFrom,
    required String restaurantId,
    double? lat,
    double? lng,
  }) {
    _deliveryPrice = basePrice;
    _freeDeliveryFrom = freeFrom;
    _restaurantId = restaurantId;
    _restaurantLat = lat;
    _restaurantLng = lng;
    notifyListeners();
  }

  Future<void> updateDeliveryPriceByDistance(double customerLat, double customerLng) async {
    // Reset distance to trigger recalculation
    _distanceInKm = 0.0;
    
    debugPrint('Calculating distance: Restaurant($_restaurantLat, $_restaurantLng) -> Customer($customerLat, $customerLng)');
    if (_restaurantLat == null || _restaurantLng == null) {
      debugPrint('Distance calculation skipped: Restaurant coordinates missing');
      return;
    }

    _isCalculatingDelivery = true;
    notifyListeners();

    try {
      final start = LatLng(_restaurantLat!, _restaurantLng!);
      final end = LatLng(customerLat, customerLng);
      
      _distanceInKm = await RoutingService.getRoadDistance(start, end);
      debugPrint('Distance calculated: $_distanceInKm km');
    } catch (e) {
      debugPrint('Error updating delivery price: $e');
    } finally {
      _isCalculatingDelivery = false;
      notifyListeners();
    }
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = _authRepository.token;
      List<CartItem> loadedItems = [];

      if (token != null) {
        loadedItems = await _cartRepository.getCart();
      } else {
        loadedItems = await _localCartStorage.getCart();
      }

      _items.clear();
      for (var item in loadedItems) {
        _items[item.uniqueKey] = item;
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      if (_items.isNotEmpty) {
        _restaurantId = _items.values.first.product.restaurantId;
        _fetchRestaurantDetails();
      }
      notifyListeners();
    }
  }

  Future<void> _fetchRestaurantDetails() async {
    // Set default coordinates and price for Masoor Family Restaurant
    // _restaurantLat = 40.809289;
    // _restaurantLng = 44.486711;
    // _deliveryPrice = 500.0; // Default base price
    debugPrint('Restaurant details initialized with defaults: $_restaurantLat, $_restaurantLng');

    if (_restaurantId == null || _restaurantId!.isEmpty) {
      debugPrint('No restaurantId found, using defaults.');
      notifyListeners();
      return;
    }
    try {
      final restaurant = await _restaurantRepository.getRestaurantById(_restaurantId!, _authRepository.token).timeout(const Duration(seconds: 5));
      // If API provides coordinates, use them, otherwise keep defaults
      if (restaurant.location?.lat != null && restaurant.location?.lng != null) {
        _restaurantLat = restaurant.location!.lat!;
        _restaurantLng = restaurant.location!.lng!;
      }
      _deliveryPrice = restaurant.delivery.basePrice;
      _freeDeliveryFrom = restaurant.delivery.freeDeliveryFrom;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching restaurant details: $e');
      notifyListeners();
    }
  }

  Future<void> _syncLocalCartToRemote() async {
    final localItems = await _localCartStorage.getCart();
    if (localItems.isEmpty) return;

    for (var item in localItems) {
      try {
        await _cartRepository.addToCart(
          productId: item.product.id,
          variantId: item.variantId,
          variantName: item.variantName,
          attributes: item.attributes,
          unitPrice: item.unitPrice,
          cookingTime: item.cookingTime,
          is18Plus: item.is18Plus,
          quantity: item.quantity.toInt(),
          note: item.note,
        );
      } catch (e) {
        debugPrint('Error syncing item ${item.product.id}: $e');
      }
    }
    await _localCartStorage.clearCart();
  }

  Future<void> addItem(ProductModel product, {
    String? variantId,
    String? variantName,
    List<CartAttribute> attributes = const [],
    double? unitPrice,
    int quantity = 1,
    String? note,
  }) async {
    try {
      final token = _authRepository.token;
      if (token != null) {
        await _cartRepository.addToCart(
          productId: product.id,
          variantId: variantId,
          variantName: variantName,
          attributes: attributes,
          unitPrice: unitPrice ?? product.displayPrice,
          cookingTime: product.cookingTime,
          is18Plus: product.is18Plus,
          quantity: quantity,
          note: note,
        );
      } else {
        // Local handling
        final newItem = CartItem(
          product: product,
          variantId: variantId,
          variantName: variantName,
          attributes: attributes,
          quantity: quantity.toDouble(),
          unitPrice: unitPrice ?? product.displayPrice,
          cookingTime: product.cookingTime ?? 0,
          is18Plus: product.is18Plus ?? false,
          note: note,
        );
        
        final key = newItem.uniqueKey;
        if (_items.containsKey(key)) {
          final existing = _items[key]!;
          _items[key] = CartItem(
            product: existing.product,
            variantId: existing.variantId,
            variantName: existing.variantName,
            attributes: existing.attributes,
            quantity: existing.quantity + quantity,
            unitPrice: existing.unitPrice,
            cookingTime: existing.cookingTime,
            is18Plus: existing.is18Plus,
            note: existing.note,
          );
        } else {
          _items[key] = newItem;
        }
        await _localCartStorage.saveCart(_items.values.toList());
      }
      
      await loadCart();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String key) async {
    final item = _items[key];
    if (item == null) return;

    try {
      final token = _authRepository.token;
      if (token != null) {
        await _cartRepository.deleteFromCart(
          productId: item.product.id,
          variantId: item.variantId,
        );
      } else {
        _items.remove(key);
        await _localCartStorage.saveCart(_items.values.toList());
      }
      await loadCart();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> decreaseQuantity(String key) async {
    final item = _items[key];
    if (item == null) return;

    try {
      final token = _authRepository.token;
      if (token != null) {
        await _cartRepository.deleteFromCart(
          productId: item.product.id,
          variantId: item.variantId,
          quantity: 1,
        );
      } else {
        if (item.quantity > 1) {
          _items[key] = CartItem(
            product: item.product,
            variantId: item.variantId,
            variantName: item.variantName,
            attributes: item.attributes,
            quantity: item.quantity - 1,
            unitPrice: item.unitPrice,
            cookingTime: item.cookingTime,
            is18Plus: item.is18Plus,
            note: item.note,
          );
        } else {
          _items.remove(key);
        }
        await _localCartStorage.saveCart(_items.values.toList());
      }
      await loadCart();
    } catch (e) {
      debugPrint('Error decreasing quantity: $e');
      rethrow;
    }
  }

  Future<void> removeOneItemByProductId(String productId) async {
    final key = _items.keys.firstWhere(
      (k) => _items[k]!.product.id == productId,
      orElse: () => '',
    );
    if (key.isNotEmpty) {
      await decreaseQuantity(key);
    }
  }

  Future<void> clearCart() async {
    try {
      final token = _authRepository.token;
      if (token != null) {
        await _cartRepository.deleteAllFromCart();
      } else {
        await _localCartStorage.clearCart();
      }
      _items.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }
}
