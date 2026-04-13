class FoodItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
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
