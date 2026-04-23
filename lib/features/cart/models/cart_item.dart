import '../../../core/models/product_model.dart';

class CartItem {
  final ProductModel product;
  final String selectedSize;
  final List<String> selectedOptions;
  final double effectiveUnitPrice; 
  int quantity;

  CartItem({
    required this.product,
    required this.selectedSize,
    required this.effectiveUnitPrice,
    this.selectedOptions = const [],
    this.quantity = 1,
  });

  double get totalIndividualPrice => effectiveUnitPrice * quantity;

  String get uniqueKey => '${product.id}_${selectedSize}_${selectedOptions.join("_")}';

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product'] ?? {
        '_id': json['productId'],
        'name': json['name'],
        'price': json['price'],
      }),
      selectedSize: json['selectedSize'] ?? 'Standard',
      selectedOptions: List<String>.from(json['selectedOptions'] ?? []),
      effectiveUnitPrice: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'name': product.name.toJson(),
      'quantity': quantity,
      'price': effectiveUnitPrice,
      'selectedSize': selectedSize,
      'selectedOptions': selectedOptions,
    };
  }
}
