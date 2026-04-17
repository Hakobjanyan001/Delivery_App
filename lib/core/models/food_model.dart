class FoodItem {
  final String id;
  final String name; // Armenian (Default)
  final String nameEn;
  final String nameRu;
  final double price;
  final String imageUrl;
  final String category;
  final List<String> sizes;
  final List<double>? sizePrices; // Optional fixed prices for each size
  final double? slicePrice; // Price per slice if piece mode is available
  final List<String> availableOptions;

  FoodItem({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameRu,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.sizes = const ['Փոքր', 'Միջին', 'Մեծ'],
    this.sizePrices,
    this.slicePrice,
    this.availableOptions = const [],
  });

  String localizedName(String langCode) {
    if (langCode == 'en') return nameEn;
    if (langCode == 'ru') return nameRu;
    return name;
  }
}

class Restaurant {
  final String id;
  final String name; // Armenian (Default)
  final String nameEn;
  final String nameRu;
  final double rating;
  final String imageUrl;
  final String category;
  final double price;

  Restaurant({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameRu,
    required this.rating,
    required this.imageUrl,
    required this.category,
    required this.price,
  });

  String localizedName(String langCode) {
    if (langCode == 'en') return nameEn;
    if (langCode == 'ru') return nameRu;
    return name;
  }
}
