import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/product_model.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  static const String _cartKey = 'user_cart_items';

  CartProvider() {
    loadCart();
  }

  List<CartItem> get items => _items.values.toList();

  int get totalItemCount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  int getItemQuantity(String productId) {
    int count = 0;
    _items.forEach((key, cartItem) {
      if (cartItem.product.id == productId) {
        count += cartItem.quantity;
      }
    });
    return count;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.effectiveUnitPrice * cartItem.quantity;
    });
    return total;
  }

  void addItem(ProductModel product, {String? selectedSize, List<String>? selectedOptions, double? effectiveUnitPrice}) {
    // Matching the new backend-driven fields
    final size = selectedSize ?? 'Standard'; 
    final options = selectedOptions ?? [];
    final unitPrice = effectiveUnitPrice ?? product.price;

    final tempItem = CartItem(product: product, selectedSize: size, selectedOptions: options, effectiveUnitPrice: unitPrice);
    final key = tempItem.uniqueKey;

    if (_items.containsKey(key)) {
      _items[key]!.quantity += 1;
    } else {
      _items[key] = CartItem(
        product: product,
        selectedSize: size,
        selectedOptions: options,
        effectiveUnitPrice: unitPrice,
      );
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    _saveCart();
    notifyListeners();
  }

  void decreaseQuantity(String key) {
    if (!_items.containsKey(key)) return;

    if (_items[key]!.quantity > 1) {
      _items[key]!.quantity -= 1;
    } else {
      _items.remove(key);
    }
    _saveCart();
    notifyListeners();
  }

  void removeOneItemByProductId(String productId) {
    final key = _items.keys.firstWhere(
      (k) => _items[k]!.product.id == productId,
      orElse: () => '',
    );
    if (key.isNotEmpty) {
      decreaseQuantity(key);
    }
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _items.values.map((item) => item.toJson()).toList();
      await prefs.setString(_cartKey, json.encode(cartData));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);
      if (cartString != null) {
        final List<dynamic> cartData = json.decode(cartString);
        _items.clear();
        for (var itemData in cartData) {
          final item = CartItem.fromJson(itemData as Map<String, dynamic>);
          _items[item.uniqueKey] = item;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }
}
