import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/profile_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../models/cart_item.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../home/providers/home_provider.dart';
import '../../../core/models/restaurant_model.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final l10n = Provider.of<LocalizationProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 101,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Image.asset(
            'assets/images/masoor_branch.png',
            width: 72,
            height: 48,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          Center(
            child: GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse('tel:+37460515515');
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.phone_outlined,
                      color: Colors.black,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '+374 60 515515',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyState(context, l10n)
            : Stack(
                children: [
                  Positioned.fill(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 10, bottom: 120),
                      children: [
                        ...cart.items.map(
                          (item) => _buildCartItem(context, cart, item),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildCheckoutBar(context, cart, l10n, auth),
                  ),
                ],
              ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProvider cart,
    CartItem item,
  ) {
    final l10n = Provider.of<LocalizationProvider>(context, listen: false);
    final lang = l10n.currentLocale.languageCode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
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
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.fastfood, color: Colors.white24, size: 40),
                  )
                : const Icon(Icons.fastfood, color: Colors.white24, size: 40),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.product.name.getLocalized(lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if ((item.variantName != null && item.variantName!.isNotEmpty) ||
                                item.attributes.isNotEmpty)
                              Text(
                                '${item.variantName ?? ""}${item.attributes.isNotEmpty ? " • ${item.attributes.map((a) => a.values.join(", ")).join(" • ")}" : ""}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.totalPrice.toStringAsFixed(0)} ֏',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => cart.decreaseQuantity(item.uniqueKey),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '${item.quantity.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => cart.addItem(
                                item.product,
                                variantId: item.variantId,
                                variantName: item.variantName,
                                attributes: item.attributes,
                                unitPrice: item.unitPrice,
                                note: item.note,
                              ),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildEmptyState(BuildContext context, LocalizationProvider l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Color(0xFF10100F),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.translate('emptyCart'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.translate('backToHome'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(
    BuildContext context,
    CartProvider cart,
    LocalizationProvider l10n,
    AuthProvider auth,
  ) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    
    // Calculate delivery based on restaurant
    RestaurantModel? restaurant;
    if (cart.items.isNotEmpty) {
      try {
        final restaurantId = cart.items.first.product.restaurantId;
        restaurant = homeProvider.restaurants.firstWhere((r) => r.id == restaurantId);
      } catch (_) {}
    }

    final double deliveryFee = (restaurant != null && cart.totalAmount < restaurant.delivery.freeDeliveryFrom) 
        ? restaurant.delivery.basePrice 
        : 0.0;
    
    final double finalTotal = cart.totalAmount + deliveryFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
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
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                '${l10n.translate('freeDeliveryFrom')} ${restaurant.delivery.freeDeliveryFrom.toStringAsFixed(0)} ֏',
                style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600),
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
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${finalTotal.toStringAsFixed(0)} ֏',
                    style: const TextStyle(
                      color: Colors.white,
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
                        settings: const RouteSettings(name: 'PaymentScreen'),
                        builder: (context) => const PaymentScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: 'LoginScreen'),
                        builder: (context) => const LoginScreen(isCheckoutFlow: true),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.translate('checkout'),
                  style: const TextStyle(
                    fontSize: 16,
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
