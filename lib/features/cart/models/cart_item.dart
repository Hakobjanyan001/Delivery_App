import '../../../core/models/food_model.dart';

class CartItem {
  final FoodItem foodItem;
  int quantity;

  CartItem({
    required this.foodItem,
    this.quantity = 1,
  });

  double get totalIndividualPrice => foodItem.price * quantity;
}
