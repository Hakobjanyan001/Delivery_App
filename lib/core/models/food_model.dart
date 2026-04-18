class FoodItem {
  final String id;
  final String name; // Armenian (Default)
  final String nameEn;
  final String nameRu;
  final String description;
  final String descriptionEn;
  final String descriptionRu;
  final double price;
  final String imageUrl;
  final String category;
  final int prepTime; // in minutes
  final String unit; // e.g., 'հատ', 'կտոր'
  final List<String> sizes;
  final List<double>? sizePrices;
  final double? slicePrice;
  final List<String> availableOptions;

  FoodItem({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameRu,
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
  });

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
