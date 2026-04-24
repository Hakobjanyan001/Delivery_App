import 'package:flutter/material.dart';
import '../../../core/models/product_model.dart';
import '../models/cart_item.dart';
import '../data/cart_repository.dart';
import '../data/local_cart_storage.dart';
import '../../auth/data/auth_repository.dart';

class CartProvider with ChangeNotifier {
  final CartRepository _cartRepository = CartRepository();
  final LocalCartStorage _localCartStorage = LocalCartStorage();
  final AuthRepository _authRepository = AuthRepository();
  Map<String, CartItem> _items = {};
  bool _isLoading = false;
  
  // Delivery logic
  double _deliveryPrice = 0.0;
  double _freeDeliveryFrom = 0.0;
  String? _restaurantId;

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
    return _deliveryPrice;
  }

  double get finalAmount => totalAmount + deliveryPrice;

  void setDeliverySettings(double basePrice, double freeFrom, String restaurantId) {
    _deliveryPrice = basePrice;
    _freeDeliveryFrom = freeFrom;
    _restaurantId = restaurantId;
    notifyListeners();
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
