import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../features/cart/providers/orders_provider.dart';
import '../../features/cart/providers/address_provider.dart';
import '../../features/cart/providers/payment_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../providers/main_tabs_controller.dart';

abstract class OrderCommand {
  Future<bool> execute(BuildContext context);
}

class PlaceOrderCommand implements OrderCommand {
  @override
  Future<bool> execute(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final payment = Provider.of<PaymentProvider>(context, listen: false);
    final address = Provider.of<AddressProvider>(context, listen: false);
    final orders = Provider.of<OrdersProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (cart.items.isEmpty) return false;

    // Execute payment strategy
    final paymentSuccess = await payment.strategy.processPayment(cart.finalAmount);
    if (!paymentSuccess) return false;

    // Create order in repository
    final order = await orders.addOrder(
      cart.items,
      cart.totalAmount,
      address: {
        'address': address.selectedAddress?.address ?? '',
        'lat': address.selectedAddress?.latitude,
        'lng': address.selectedAddress?.longitude,
      },
      phone: auth.phone ?? '',
      paymentMethod: payment.strategy.name,
      addressId: address.selectedAddressId,
      deliveryPrice: cart.deliveryPrice,
    );

    if (order != null) {
      cart.clearCart();
      // Reset navigation
      Navigator.popUntil(context, (r) => r.isFirst);
      Provider.of<MainTabsController>(context, listen: false).switchTo(2); // Go to Profile/Orders
      return true;
    }

    return false;
  }
}
