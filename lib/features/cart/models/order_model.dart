import 'cart_item.dart';

class OrderModel {
  final String id;
  final DateTime date;
  final double totalAmount;
  final List<CartItem> items;
  final String status;
  final String address;
  final double? latitude;
  final double? longitude;
  final double deliveryPrice;

  OrderModel({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.items,
    required this.address,
    this.status = "pending",
    this.latitude,
    this.longitude,
    this.deliveryPrice = 0.0,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final addressData = json['address'];
    return OrderModel(
      id: json['id'] ?? json['_id'] ?? '',
      date: DateTime.parse(json['createdAt'] ?? json['date'] ?? DateTime.now().toIso8601String()),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      items: (json['items'] as List? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
      status: json['status'] ?? "pending",
      address: addressData is Map 
          ? (addressData['address'] ?? "") 
          : (addressData ?? ""),
      latitude: addressData is Map ? (addressData['lat']?.toDouble()) : null,
      longitude: addressData is Map ? (addressData['lng']?.toDouble()) : null,
      deliveryPrice: (json['deliveryPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'address': {
        'address': address,
        'lat': latitude,
        'lng': longitude,
      },
      'deliveryPrice': deliveryPrice,
    };
  }
}
