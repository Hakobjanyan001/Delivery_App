import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

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
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        cartProvider.removeItem(cartItem.uniqueKey);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Image - Square on the left
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              child: Image.network(
                item.mainImageUrl,
                width: 100,
                // height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  // height: 100,
                  color: const Color(0xFF161616),
                  child: const Icon(
                    Icons.fastfood_outlined,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Middle section: Title and subtitle/controls
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.getLocalized(lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'x${cartItem.quantity} `${cartItem.totalIndividualPrice.toStringAsFixed(0)}֏',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),

                        // Separated Quantity Controls
                        Row(
                          children: [
                            // Minus Button
                            GestureDetector(
                              onTap: () => cartProvider.decreaseQuantity(
                                cartItem.uniqueKey,
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Plus Button
                            GestureDetector(
                              onTap: () => cartProvider.addItem(
                                item,
                                selectedSize: cartItem.selectedSize,
                                selectedOptions: cartItem.selectedOptions,
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
