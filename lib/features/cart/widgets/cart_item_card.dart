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

    return Dismissible(
      key: ValueKey(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        cartProvider.removeItem(item.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
              ),
              if (cartItem.quantity > 1)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
                    ),
                    child: Text(
                      'x${cartItem.quantity}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            softWrap: true,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.price.toStringAsFixed(0)} ֏',
                style: TextStyle(color: Colors.blue[900]),
              ),
              if (cartItem.quantity > 1)
                Text(
                  '${Provider.of<LocalizationProvider>(context).translate('total')}՝ ${cartItem.totalIndividualPrice.toStringAsFixed(0)} ֏',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                onPressed: () => cartProvider.decreaseQuantity(item.id),
              ),
              Text(
                '${cartItem.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                onPressed: () => cartProvider.addItem(item),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
