import 'package:flutter/material.dart';
import '../../../core/models/product_model.dart';
import 'food_detail/food_detail_mobile.dart';
import 'food_detail/food_detail_desktop.dart';

void showFoodDetail(BuildContext context, ProductModel product) {
  final isDesktop = MediaQuery.of(context).size.width >= 900;

  if (isDesktop) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      routeSettings: const RouteSettings(name: 'FoodDetail'),
      builder: (_) => FoodDetailDesktop(product: product),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: 'FoodDetail'),
      builder: (_) => FoodDetailMobile(product: product),
    );
  }
}
