import '../../../core/models/product_model.dart';

class CartItem {
  final ProductModel product;

  /// Variant (size / type)
  final String? variantId;
  final String? variantName;

  /// Attributes (toppings / extras)
  final List<CartAttribute> attributes;

  /// Weight or pieces count
  final double quantity;

  /// Final calculated price PER UNIT (after variant + attributes)
  final double unitPrice;

  /// Total cooking time snapshot
  final int cookingTime;

  /// Snapshot flags (important for order history)
  final bool is18Plus;
  final String? note;

  CartItem({
    required this.product,
    this.variantId,
    this.variantName,
    this.attributes = const [],
    required this.quantity,
    required this.unitPrice,
    required this.cookingTime,
    required this.is18Plus,
    this.note,
  });

  /// 🔥 Total price
  double get totalPrice => unitPrice * quantity;

  /// 🔥 Unique key for merging items in cart
  String get uniqueKey {
    final attrKey = attributes
        .map((a) => '${a.name}_${a.values.join("-")}')
        .join('_');

    return '${product.id}_${variantId ?? 'noVar'}_${note ?? 'noNote'}_$attrKey';
  }

  // ─────────────────────────────
  // FROM JSON
  // ─────────────────────────────
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['productId'];
    final nameSnapshot = json['nameSnapshot'];

    final product = productData is Map<String, dynamic>
        ? ProductModel.fromJson(productData)
        : (nameSnapshot is Map<String, dynamic>
            ? ProductModel.fromJson({
                '_id': productData,
                'name': nameSnapshot,
                'price': (json['unitPriceSnapshot'] ?? json['unitPrice'] ?? 0).toDouble(),
              })
            : ProductModel.fromJson({
                '_id': productData,
                'name': {
                  'en': 'Unknown',
                  'ru': 'Неизвестно',
                  'hy': 'Անհայտ'
                },
                'price': (json['unitPriceSnapshot'] ?? json['unitPrice'] ?? 0).toDouble(),
              }));

    return CartItem(
      product: product,
      variantId: json['variantId'],
      variantName: json['variantName'],

      attributes: (json['attributes'] ?? [])
          .map<CartAttribute>((a) => CartAttribute.fromJson(a))
          .toList(),

      quantity: (json['quantity'] ?? 1).toDouble(),

      unitPrice: (json['unitPriceSnapshot'] ?? json['unitPrice'] ?? json['price'] ?? product.displayPrice).toDouble(),

      cookingTime: json['cookingTime'] ?? product.cookingTime ?? 0,

      is18Plus: json['is18Plus'] ?? product.is18Plus ?? false,
      note: json['note'],
    );
  }

  // ─────────────────────────────
  // TO JSON
  // ─────────────────────────────
  Map<String, dynamic> toJson({bool isLocal = false}) {
    return {
      'productId': isLocal ? product.toJson() : product.id,
      'productName': product.name.hy, // snapshot name for backend
      'variantId': variantId,
      'variantName': variantName,
      'attributes': attributes.map((a) => a.toJson()).toList(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'cookingTime': cookingTime,
      'is18Plus': is18Plus,
      'note': note,
    };
  }
}

class CartAttribute {
  final String name;
  final List<String> values;

  CartAttribute({
    required this.name,
    required this.values,
  });

  factory CartAttribute.fromJson(Map<String, dynamic> json) {
    return CartAttribute(
      name: json['name'],
      values: List<String>.from(json['values'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'values': values,
    };
  }
}