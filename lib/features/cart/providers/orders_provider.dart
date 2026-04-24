import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';
import '../data/orders_repository.dart';

class OrdersProvider with ChangeNotifier {
  final OrdersRepository _repository = OrdersRepository();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => [..._orders].reversed.toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repository.getMyOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<OrderModel?> addOrder(List<CartItem> items, double total, {
    required Map<String, dynamic> address,
    required String phone,
    required String paymentMethod,
    double deliveryPrice = 0.0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _repository.createOrder(
        items: items.map((i) => i.toJson()).toList(),
        totalAmount: total,
        deliveryPrice: deliveryPrice,
        address: address,
        phone: phone,
        paymentMethod: paymentMethod,
      );
      _orders.add(order);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
