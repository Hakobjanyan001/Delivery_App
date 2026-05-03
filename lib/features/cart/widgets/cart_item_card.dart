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
        child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onError, size: 28),

      ),
      onDismissed: (direction) {
        cartProvider.removeItem(cartItem.uniqueKey);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  child: Icon(
                    Icons.fastfood_outlined,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (cartItem.note != null && cartItem.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          cartItem.note!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),

                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'x${cartItem.quantity} `${cartItem.totalPrice.toStringAsFixed(0)}֏',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),

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
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                                  ),

                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${cartItem.quantity}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),

                            ),
                            const SizedBox(width: 16),
                            // Plus Button
                            GestureDetector(
                              onTap: () => cartProvider.addItem(
                                item,
                                variantId: cartItem.variantId,
                                variantName: cartItem.variantName,
                                attributes: cartItem.attributes,
                                unitPrice: cartItem.unitPrice,
                                note: cartItem.note,
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Theme.of(context).colorScheme.surface,
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
