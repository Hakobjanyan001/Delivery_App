import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/profile_screen.dart';
import '../../auth/screens/login_screen.dart';

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
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 20,
        title: ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          child: Image.asset(
            'assets/images/masoor_branch.png',
            width: 56,
            height: 38,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.phone_in_talk_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  '+374 60 515515',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (!auth.isAuthenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'LoginScreen'),
                    builder: (context) =>
                        const LoginScreen(isCheckoutFlow: false),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'ProfileScreen'),
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF161616),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyState(context, l10n)
          : Stack(
              children: [
                Positioned.fill(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      ...cart.items.map(
                        (item) => _buildCartItem(context, cart, item),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartProvider cart, dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      height: 104,
      decoration: const BoxDecoration(color: Color(0xFF131313)),
      child: Row(
        children: [
          Container(
            width: 104,
            height: 104,
            color: const Color(0xFF1E1E1E),
            child: Image.network(
              item.foodItem.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.fastfood, color: Colors.white24, size: 40),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.foodItem.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
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
                            if (item.selectedSize != null &&
                                    item.selectedSize.isNotEmpty ||
                                item.selectedOptions.isNotEmpty)
                              Text(
                                '${item.selectedSize}${item.selectedOptions.isNotEmpty ? " • ${item.selectedOptions.join(', ')}" : ""}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.totalIndividualPrice.toStringAsFixed(0)} ֏',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => cart.decreaseQuantity(item.uniqueKey),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => cart.addItem(
                              item.foodItem,
                              selectedSize: item.selectedSize,
                              selectedOptions: item.selectedOptions,
                              effectiveUnitPrice: item.effectiveUnitPrice,
                            ),
                            child: Container(
                              width: 32,
                              height: 32,
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
}
