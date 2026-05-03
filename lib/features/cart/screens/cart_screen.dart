import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../models/cart_item.dart';
import '../../home/providers/home_provider.dart';
import '../../../core/models/restaurant_model.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
Widget build(BuildContext context) {
  final cart = context.watch<CartProvider>();
  final l10n = context.watch<LocalizationProvider>();
  final auth = context.read<AuthProvider>();

  return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,

    body: SafeArea(
      child: cart.items.isEmpty
          ? _buildEmptyState(context, l10n)
          : Column(
              children: [
                // LIST
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: cart.items.length,
                    itemBuilder: (_, index) {
                      return _buildCartItem(context, cart.items[index]);
                    },
                  ),
                ),

                // // CHECKOUT (NO STACK, NO POSITIONED)
                // _buildCheckoutBar(context, cart, l10n, auth),
              ],
            ),
    ),
  );
}

  // ================= CART ITEM =================
  Widget _buildCartItem(BuildContext context, CartItem item) {
    final cart = context.read<CartProvider>();
    final l10n = context.read<LocalizationProvider>();
    final lang = l10n.currentLocale.languageCode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 110,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),

      child: Row(
        children: [
          // IMAGE
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),


            clipBehavior: Clip.antiAlias,
            child: item.product.mainImageUrl.isNotEmpty
                ? Image.network(
                    item.product.mainImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.fastfood, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), size: 40),

                  )
                : Icon(Icons.fastfood, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), size: 40),


          ),

          // INFO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.product.name.getLocalized(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),

                  ),

                  // PRICE + CONTROLS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_hasDetails(item))
                              Text(
                                _buildDetailsText(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),

                              ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.totalPrice.toStringAsFixed(0)} ֏',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                          ],
                        ),
                      ),

                      _quantityControls(context, cart, item),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasDetails(CartItem item) {
    return (item.variantName != null && item.variantName!.isNotEmpty) ||
        item.attributes.isNotEmpty;
  }

  String _buildDetailsText(CartItem item) {
    final variant = item.variantName ?? '';

    final attrs = item.attributes
        .map((a) => a.values.join(", "))
        .where((e) => e.isNotEmpty)
        .join(" • ");

    if (variant.isNotEmpty && attrs.isNotEmpty) {
      return "$variant • $attrs";
    } else if (variant.isNotEmpty) {
      return variant;
    } else {
      return attrs;
    }
  }

  Widget _quantityControls(BuildContext context, CartProvider cart, CartItem item) {

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
      ),

      child: Row(
        children: [
          _circleBtn(
            context,
            icon: Icons.remove,
            onTap: () => cart.decreaseQuantity(item.uniqueKey),
            outlined: true,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),

            ),
          ),
          _circleBtn(
            context,
            icon: Icons.add,
            onTap: () => cart.addItem(

              item.product,
              variantId: item.variantId,
              variantName: item.variantName,
              attributes: item.attributes,
              unitPrice: item.unitPrice,
              note: item.note,
            ),
            filled: true,
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
    bool outlined = false,
  }) {

    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 16,
          color: filled ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface,
        ),

        style: IconButton.styleFrom(
          backgroundColor: filled ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
          shape: const CircleBorder(),
          side: outlined
              ? BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))
              : null,
        ),

      ),
    );
  }

  // ================= EMPTY =================
  Widget _buildEmptyState(BuildContext context, LocalizationProvider l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),

            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.translate('emptyCart'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),

          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.translate('backToHome'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),

          ),
        ],
      ),
    );
  }

  // ================= CHECKOUT =================
  Widget _buildCheckoutBar(
    BuildContext context,
    CartProvider cart,
    LocalizationProvider l10n,
    AuthProvider auth,
  ) {
    final home = context.read<HomeProvider>();

    RestaurantModel? restaurant;

    if (cart.items.isNotEmpty) {
      final restaurantId = cart.items.first.product.restaurantId;

      try {
        restaurant = home.restaurants
            .firstWhere((r) => r.id == restaurantId);
      } catch (_) {
        restaurant = null;
      }
    }

    final deliveryFee = (restaurant != null &&
            cart.totalAmount < restaurant.delivery.freeDeliveryFrom)
        ? restaurant.delivery.basePrice
        : 0.0;

    final total = cart.totalAmount + deliveryFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (restaurant != null && deliveryFee > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${l10n.translate('freeDeliveryFrom')} ${restaurant.delivery.freeDeliveryFrom.toStringAsFixed(0)} ֏',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),

              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('total'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                      fontSize: 14,
                    ),

                  ),
                  Text(
                    '${total.toStringAsFixed(0)} ֏',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),

                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () {
                  if (auth.isAuthenticated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginScreen(isCheckoutFlow: true),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                child: Text(
                  l10n.translate('checkout'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}