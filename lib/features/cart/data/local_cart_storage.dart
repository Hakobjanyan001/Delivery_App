import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class LocalCartStorage {
  static const String _cartKey = 'local_cart_items';

  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(items.map((item) => item.toJson(isLocal: true)).toList());
    await prefs.setString(_cartKey, encodedData);
  }

  Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_cartKey);
    if (encodedData == null) return [];

    try {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      return decodedData.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
