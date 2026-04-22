import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/localization_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import 'checkout_screen.dart';
import '../../support/widgets/support_hub_sheet.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/profile_screen.dart';
import '../../../core/theme/app_theme.dart';


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Only watch localization here for title.
    final l10n = context.watch<LocalizationProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 70,
        centerTitle: false,
        leadingWidth: 120,
        leading: Row(
          children: [
            const BackButton(),
            Image.asset(
              'assets/images/masoor_branch.png',
              width: 72,
              height: 48,
              fit: BoxFit.contain,
            ),
          ],
        ),
        title: null,
        actions: [
          Center(
            child: GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse('tel:+37460515515');
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.phone_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('+374 60 515515', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 8.0),
            child: GestureDetector(
              onTap: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
                  Navigator.push(context, MaterialPageRoute(settings: const RouteSettings(name: 'LoginScreen'), builder: (context) => const LoginScreen(isCheckoutFlow: false)));
                } else {
                  Navigator.push(context, MaterialPageRoute(settings: const RouteSettings(name: 'ProfileScreen'), builder: (context) => const ProfileScreen()));
                }
              },
              child: Container(
                width: 45, height: 45,
                decoration: BoxDecoration(color: const Color(0xFF161616), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                child: const Icon(Icons.person_outline, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
      body: (!auth.isAuthenticated || auth.isAnonymous) 
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  Text(
                    l10n.translate('registerToPurchase'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'LoginScreen'),
                          builder: (context) => const LoginScreen(isCheckoutFlow: false),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(l10n.translate('login'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                   Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(l10n.translate('emptyCart'), style: const TextStyle(fontSize: 18, color: Colors.white)),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), // Extra bottom padding for nav bar
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.isAnonymous) {
                final loggedIn = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'LoginScreen'),
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
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              minimumSize: const Size(double.infinity, 60),
              elevation: 0,
            ),
            child: Text(
              l10n.translate('checkout'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
