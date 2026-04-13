import '../../../core/models/food_model.dart';

class CartItem {
  final FoodItem foodItem;
  final String selectedSize;
  final List<String> selectedOptions;
  final double effectiveUnitPrice; // Final price after size multiplier
  int quantity;

  CartItem({
    required this.foodItem,
    required this.selectedSize,
    required this.effectiveUnitPrice,
    this.selectedOptions = const [],
    this.quantity = 1,
  });

  double get totalIndividualPrice => effectiveUnitPrice * quantity;

  // Unique key: same food + different size/options = separate cart entry
  String get uniqueKey => '${foodItem.id}_${selectedSize}_${selectedOptions.join("_")}';
}
