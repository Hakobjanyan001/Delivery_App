import 'common_models.dart';

class ProductModel {
  final String id;
  final String restaurantId;
  final String categoryId;
  final String? subcategoryId;
  final LocalizedString name;
  final LocalizedString description;
  final List<String> images;
  final double price;
  final double? discountPrice;
  final bool isDiscountManual;
  final bool isAvailable;
  final String type; // 'weight' | 'piece'
  final int cookingTime;
  final bool is18Plus;
  final List<ProductAttribute> attributes;
  final List<ProductVariant> variants;

  ProductModel({
    required this.id,
    required this.restaurantId,
    required this.categoryId,
    this.subcategoryId,
    required this.name,
    required this.description,
    required this.images,
    required this.price,
    this.discountPrice,
    this.isDiscountManual = false,
    this.isAvailable = true,
    this.type = 'piece',
    this.cookingTime = 0,
    this.is18Plus = false,
    this.attributes = const [],
    this.variants = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      subcategoryId: json['subcategoryId']?.toString(),
      name: LocalizedString.fromJson(json['name'] ?? {}),
      description: LocalizedString.fromJson(json['description'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice'] != null ? (json['discountPrice'] as num).toDouble() : null,
      isDiscountManual: json['isDiscountManual'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      type: json['type'] ?? 'piece',
      cookingTime: json['cookingTime'] ?? 0,
      is18Plus: json['is18Plus'] ?? false,
      attributes: (json['attributes'] as List? ?? [])
          .map((e) => ProductAttribute.fromJson(e))
          .toList(),
      variants: (json['variants'] as List? ?? [])
          .map((e) => ProductVariant.fromJson(e))
          .toList(),
    );
  }

  String get mainImageUrl => images.isNotEmpty ? images.first : '';

  double get displayPrice => (discountPrice != null && discountPrice! > 0) ? discountPrice! : price;
}

class ProductAttribute {
  final String id;
  final LocalizedString name;
  final List<AttributeOption> options;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.options,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['_id'] ?? '',
      name: LocalizedString.fromJson(json['name'] ?? {}),
      options: (json['options'] as List? ?? [])
          .map((e) => AttributeOption.fromJson(e))
          .toList(),
    );
  }
}

class AttributeOption {
  final LocalizedString name;
  final double price;

  AttributeOption({
    required this.name,
    required this.price,
  });

  factory AttributeOption.fromJson(Map<String, dynamic> json) {
    return AttributeOption(
      name: LocalizedString.fromJson(json['name'] ?? {}),
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class ProductVariant {
  final LocalizedString name;
  final double price;

  ProductVariant({
    required this.name,
    required this.price,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      name: LocalizedString.fromJson(json['name'] ?? {}),
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
