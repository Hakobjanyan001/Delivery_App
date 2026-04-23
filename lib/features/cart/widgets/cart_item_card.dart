import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../../../core/theme/app_theme.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final CartProvider cartProvider;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    final item = cartItem.product;
    final l10n = context.watch<LocalizationProvider>();
    final lang = l10n.currentLocale.languageCode;

    return Dismissible(
      key: ValueKey(cartItem.uniqueKey),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        cartProvider.removeItem(cartItem.uniqueKey);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                item.mainImageUrl,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 85, height: 85,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.getLocalized(lang),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1 ${lang == 'en' ? 'portion' : (lang == 'ru' ? 'порция' : 'բաժին')}',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${cartItem.totalIndividualPrice.toStringAsFixed(0)} ֏',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity controls (Pill shape)
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                    onPressed: () => cartProvider.decreaseQuantity(cartItem.uniqueKey),
                    constraints: const BoxConstraints(minWidth: 32),
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    '${cartItem.quantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    onPressed: () => cartProvider.addItem(
                      item,
                      selectedSize: cartItem.selectedSize,
                      selectedOptions: cartItem.selectedOptions,
                    ),
                    constraints: const BoxConstraints(minWidth: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagWidget extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const TagWidget({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
