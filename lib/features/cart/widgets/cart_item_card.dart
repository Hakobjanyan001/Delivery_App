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
    final item = cartItem.foodItem;
    final l10n = Provider.of<LocalizationProvider>(context);

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
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 65, height: 65,
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (cartItem.quantity > 1)
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
                        ),
                        child: Text('x${cartItem.quantity}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),

                    // Size chip
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildTag(cartItem.selectedSize, Colors.blue[50]!, Colors.blue[900]!),
                        ...cartItem.selectedOptions.map(
                          (opt) => _buildTag(opt, Colors.orange[50]!, Colors.orange[800]!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${cartItem.effectiveUnitPrice.toStringAsFixed(0)} ֏',
                            style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                        if (cartItem.quantity > 1)
                          Text('${l10n.translate('total')}՝ ${cartItem.totalIndividualPrice.toStringAsFixed(0)} ֏',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),

              // Quantity controls
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 22),
                    onPressed: () => cartProvider.addItem(
                      item,
                      selectedSize: cartItem.selectedSize,
                      selectedOptions: cartItem.selectedOptions,
                    ),
                  ),
                  Text('${cartItem.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                    onPressed: () => cartProvider.decreaseQuantity(cartItem.uniqueKey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color fg) {
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
