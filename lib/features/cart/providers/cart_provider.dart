import 'package:flutter/material.dart';
import '../../../core/models/food_model.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalItemCount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.effectiveUnitPrice * cartItem.quantity;
    });
    return total;
  }

  void addItem(FoodItem item, {String? selectedSize, List<String>? selectedOptions, double? effectiveUnitPrice}) {
    final size = selectedSize ?? (item.sizes.isNotEmpty ? item.sizes[0] : 'Standard');
    final options = selectedOptions ?? [];
    final unitPrice = effectiveUnitPrice ?? item.price;

    // Create a temporary item to get the unique key
    final tempItem = CartItem(foodItem: item, selectedSize: size, selectedOptions: options, effectiveUnitPrice: unitPrice);
    final key = tempItem.uniqueKey;

    if (_items.containsKey(key)) {
      _items[key]!.quantity += 1;
    } else {
      _items[key] = CartItem(
        foodItem: item,
        selectedSize: size,
        selectedOptions: options,
        effectiveUnitPrice: unitPrice,
      );
    }
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  void decreaseQuantity(String key) {
    if (!_items.containsKey(key)) return;

    if (_items[key]!.quantity > 1) {
      _items[key]!.quantity -= 1;
    } else {
      _items.remove(key);
    }
    notifyListeners();
  }

  void removeOneItemByFoodId(String foodId) {
    final key = _items.keys.firstWhere(
      (k) => _items[k]!.foodItem.id == foodId,
      orElse: () => '',
    );
    if (key.isNotEmpty) {
      decreaseQuantity(key);
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
