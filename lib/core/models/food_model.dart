class FoodItem {
  final String id;
  final String? restaurantId; 
  final String name;
  final String nameEn;
  final String nameRu;
  final String order;
  final String description;
  final String descriptionEn;
  final String descriptionRu;
  final double price;
  final String imageUrl;
  final String category;
  final int prepTime;
  final String unit;  
  final List<String> sizes;
  final List<double>? sizePrices;
  final double? slicePrice;
  final List<String> availableOptions;
  final List<String> features; 

  FoodItem({
    required this.id,
    this.restaurantId,
    required this.name,
    required this.nameEn,
    required this.nameRu,
    required this.order,
    required this.description,
    required this.descriptionEn,
    required this.descriptionRu,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.prepTime,
    this.unit = 'հատ',
    this.sizes = const ['Փոքր', 'Միջին', 'Մեծ'],
    this.sizePrices,
    this.slicePrice,
    this.availableOptions = const [],
    this.features = const [],
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString(),
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      nameRu: json['nameRu'] ?? '',
      order: json['order']?.toString() ?? '0',
      description: json['description'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      descriptionRu: json['descriptionRu'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      prepTime: json['prepTime'] ?? 0,
      unit: json['unit'] ?? 'հատ',
      sizes: List<String>.from(json['sizes'] ?? ['Փոքր', 'Միջին', 'Մեծ']),
      sizePrices: json['sizePrices'] != null ? List<double>.from(json['sizePrices']) : null,
      slicePrice: (json['slicePrice'])?.toDouble(),
      availableOptions: List<String>.from(json['availableOptions'] ?? []),
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'nameEn': nameEn,
      'nameRu': nameRu,
      'order': order,
      'description': description,
      'descriptionEn': descriptionEn,
      'descriptionRu': descriptionRu,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'prepTime': prepTime,
      'unit': unit,
      'sizes': sizes,
      'sizePrices': sizePrices,
      'slicePrice': slicePrice,
      'availableOptions': availableOptions,
      'features': features,
    };
  }

  String localizedName(String langCode) {
    if (langCode == 'en') return nameEn;
    if (langCode == 'ru') return nameRu;
    return name;
  }

  String localizedDescription(String langCode) {
    if (langCode == 'en') return descriptionEn;
    if (langCode == 'ru') return descriptionRu;
    return description;
  }
}

class Restaurant {
  final String id;
  final String name; 
  final String nameEn;
  final String nameRu;
  final String description;
  final String descriptionEn;
  final String descriptionRu;
  final String workingHours;
  final String delivery;
  final String imageUrl;
  final String category;
  final double price;
  final double rating;

  Restaurant({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameRu,
    required this.description,
    required this.descriptionEn,
    required this.descriptionRu,
    required this.workingHours,
    required this.delivery,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      nameRu: json['nameRu'] ?? '',
      description: json['description'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      descriptionRu: json['descriptionRu'] ?? '',
      workingHours: json['workingHours'] ?? '',
      delivery: json['delivery'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'nameRu': nameRu,
      'description': description,
      'descriptionEn': descriptionEn,
      'descriptionRu': descriptionRu,
      'delivery': delivery,
      'workingHours': workingHours,
      'imageUrl': imageUrl,
      'category': category,
      'price': price,
      'rating': rating,
    };
  }

  String localizedName(String langCode) {
    if (langCode == 'en') return nameEn;
    if (langCode == 'ru') return nameRu;
    return name;
  }
}