import 'package:flutter/material.dart';
import '../../screens/profile_screen.dart'; // We need this for the View enum if we move it, but for now it's in the same feature
import 'profile_home_view.dart';
import 'edit_profile_view.dart';
import 'orders_view.dart';
import 'addresses_view.dart';

// The Factory class that encapsulates view creation logic
class ProfileViewFactory {
  static Widget createView({
    required dynamic viewType, // Using dynamic to avoid circular dependency if _View is private, or we move the enum
    required bool isDesktop,
    required VoidCallback onNavigateToHome,
    required VoidCallback onEditProfile,
    required VoidCallback onViewOrders,
    required VoidCallback onViewAddresses,
    required VoidCallback onShowPaymentSelection,
    required VoidCallback onShowSupportOptions,
    required Future<void> Function(BuildContext context, {required Widget Function(BuildContext ctx, bool isDesktop) builder, bool scrollControlled}) showSheet,
  }) {
    // In a real factory, we might use a map or more complex logic
    // but even a switch here encapsulates the "creation" responsibility.
    
    switch (viewType.toString()) {
      case '_View.editProfile':
        return EditProfileView(onBack: onNavigateToHome);
      case '_View.orders':
        return OrdersView(onBack: onNavigateToHome);
      case '_View.addresses':
        return AddressesView(
          onBack: onNavigateToHome,
          showSheet: showSheet,
        );
      case '_View.home':
      default:
        return ProfileHomeView(
          isDesktop: isDesktop,
          onEditProfile: onEditProfile,
          onViewOrders: onViewOrders,
          onViewAddresses: onViewAddresses,
          onShowPaymentSelection: onShowPaymentSelection,
          onShowSupportOptions: onShowSupportOptions,
        );
    }
  }
}
