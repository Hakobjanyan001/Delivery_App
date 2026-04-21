import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import 'checkout_screen.dart';
import '../../support/widgets/support_hub_sheet.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/theme/app_theme.dart';


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Only watch localization here for title.
    final l10n = context.watch<LocalizationProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.translate('cartTitle'), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const SupportHubSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: (!auth.isAuthenticated || auth.isAnonymous) 
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('DEBUG: isAuthenticated=${auth.isAuthenticated}, isAnonymous=${auth.isAnonymous}', style: TextStyle(color: Colors.red)),
                  const Icon(Icons.lock_outline, size: 80, color: AppColors.primary),
                  const SizedBox(height: 20),
                  Text(
                    l10n.translate('registerToPurchase'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(isCheckoutFlow: false),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(l10n.translate('login'), style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          )
        : Selector<CartProvider, bool>(
            selector: (_, cartProv) => cartProv.items.isEmpty,
            builder: (context, isEmpty, child) {
          if (isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('DEBUG: isAuthenticated=${auth.isAuthenticated}, isAnonymous=${auth.isAnonymous}', style: const TextStyle(color: Colors.red)),
                   Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(l10n.translate('emptyCart'), style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        return CartItemCard(
                          cartItem: cart.items[index],
                          cartProvider: cart,
                        );
                      },
                    );
                  },
                ),
              ),
              CartTotalSection(l10n: l10n),
            ],
          );
        },
      ),
    );
  }
}

class CartTotalSection extends StatelessWidget {
  final LocalizationProvider l10n;
  const CartTotalSection({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Extra bottom padding for nav bar
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.translate('total'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Selector<CartProvider, double>(
                selector: (_, cartProv) => cartProv.totalAmount,
                builder: (context, totalAmount, child) {
                  return Text(
                    '${totalAmount.toStringAsFixed(0)} ֏',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.isAnonymous) {
                final loggedIn = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(isCheckoutFlow: true),
                  ),
                );
                if (loggedIn != true) return;
              }
              
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              minimumSize: const Size(double.infinity, 50),
              elevation: 2,
            ),
            child: Text(l10n.translate('checkout'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
