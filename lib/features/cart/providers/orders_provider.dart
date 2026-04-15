import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';

class OrdersProvider with ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => [..._orders].reversed.toList();

  void addOrder(List<CartItem> items, double total) {
    _orders.add(OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      totalAmount: total,
      items: items,
    ));
    notifyListeners();
  }
}
