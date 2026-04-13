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
      total += cartItem.foodItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(FoodItem item) {
    if (_items.containsKey(item.id)) {
      // If item already in cart, increment quantity
      _items.update(
        item.id,
        (existingItem) => CartItem(
          foodItem: existingItem.foodItem,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      // Add new item
      _items.putIfAbsent(
        item.id,
        () => CartItem(foodItem: item),
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void decreaseQuantity(String id) {
    if (!_items.containsKey(id)) return;

    if (_items[id]!.quantity > 1) {
      _items.update(
        id,
        (existingItem) => CartItem(
          foodItem: existingItem.foodItem,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
