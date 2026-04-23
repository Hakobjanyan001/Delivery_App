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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? json['_id'] ?? '',
      date: DateTime.parse(json['createdAt'] ?? json['date'] ?? DateTime.now().toIso8601String()),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      items: (json['items'] as List? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
      status: json['status'] ?? "Ընդունված է",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
    };
  }
}
