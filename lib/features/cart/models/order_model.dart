import 'cart_item.dart';

class OrderModel {
  final String id;
  final DateTime date;
  final double totalAmount;
  final List<CartItem> items;
  final String status;
  final String address;

  OrderModel({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.items,
    required this.address,
    this.status = "Ընդունված է",
  });
}
