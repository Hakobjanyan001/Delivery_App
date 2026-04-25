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

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'name': name.toJson(),
      'description': description.toJson(),
      'images': images,
      'price': price,
      'discountPrice': discountPrice,
      'isDiscountManual': isDiscountManual,
      'isAvailable': isAvailable,
      'type': type,
      'cookingTime': cookingTime,
      'is18Plus': is18Plus,
      'attributes': attributes.map((e) => e.toJson()).toList(),
      'variants': variants.map((e) => e.toJson()).toList(),
    };
  }

  String get mainImageUrl => images.isNotEmpty ? images.first : '';

  double get displayPrice => (discountPrice != null && discountPrice! > 0) ? discountPrice! : price;
}

class ProductAttribute {
  final String id;
  final LocalizedString name;
  final List<String> options;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.options,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['_id'] ?? '',
      name: LocalizedString.fromJson(json['name'] ?? {}),
      options: List<String>.from(json['values'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name.toJson(),
      'options': options.map((e) => e.toString()).toList(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'price': price,
    };
  }
}

class ProductVariant {
  final String id;
  final LocalizedString name;
  final double price;

  ProductVariant({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id']?.toString() ?? '',
      name: LocalizedString.fromJson(json['name'] ?? {}),
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'price': price,
    };
  }
}
