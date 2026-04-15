import 'cart_item.dart';

class OrderModel {
  final String id;
  final DateTime date;
  final double totalAmount;
  final List<CartItem> items;
  final String status;

  OrderModel({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.items,
    this.status = "Ընդունված է",
  });
}
