import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/food_model.dart';
import '../../../core/localization/localization_provider.dart';
import 'food_detail_dialog.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  void _openDetail(BuildContext context, LocalizationProvider l10n) {
    final lang = l10n.currentLocale.languageCode;
    // Create a temporary FoodItem from Restaurant data
    final food = FoodItem(
      id: restaurant.id,
      name: 'Հատուկ կերակուր ${restaurant.name}',
      nameEn: 'Special Dish ${restaurant.nameEn}',
      nameRu: 'Специальное блюдо ${restaurant.nameRu}',
      price: restaurant.price,
      imageUrl: restaurant.imageUrl,
      category: restaurant.category,
      sizes: ['Փոքր', 'Մեծ'],
      sizePrices: [restaurant.price, restaurant.price * 1.7],
      slicePrice: restaurant.category.toLowerCase().contains('pizza') ? 250 : null,
      availableOptions: ['Կծու', 'Կրկնակի բաժին', 'Առանց սոխի'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodDetailDialog(food: food),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () => _openDetail(context, l10n),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  restaurant.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.localizedName(lang),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            restaurant.category,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${restaurant.price.toStringAsFixed(0)} ֏',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant.rating}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
