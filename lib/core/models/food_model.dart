class FoodItem {
  final String id;
  final String name;
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
    required this.price,
    required this.imageUrl,
    required this.category,
    this.sizes = const ['Փոքր', 'Միջին', 'Մեծ'],
    this.sizePrices,
    this.slicePrice,
    this.availableOptions = const [],
  });
}

class Restaurant {
  final String id;
  final String name;
  final double rating;
  final String imageUrl;
  final String category;
  final double price;

  Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.imageUrl,
    required this.category,
    required this.price,
  });
}
