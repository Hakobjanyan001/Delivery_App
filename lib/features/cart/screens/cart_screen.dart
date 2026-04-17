import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import 'checkout_screen.dart';
import '../../support/widgets/support_hub_sheet.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = Provider.of<LocalizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('cartTitle'), style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.blue[900]),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(l10n.translate('emptyCart'), style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      return CartItemCard(
                        cartItem: cart.items[index],
                        cartProvider: cart,
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                  ),
                  child: Column(
                    children: [
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.translate('total'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(
                            '${cart.totalAmount.toStringAsFixed(0)} ֏',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
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
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(l10n.translate('checkout'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const SupportHubSheet(),
          );
        },
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.support_agent, color: Colors.white),
      ),
    );
  }
}
