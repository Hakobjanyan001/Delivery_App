import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../../cart/providers/payment_provider.dart';
import '../../cart/providers/orders_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../widgets/guest_auth_view.dart';
import '../../support/screens/support_chat_screen.dart';
import '../../../core/providers/main_tabs_controller.dart';
import '../widgets/profile/profile_home_view.dart';
import '../widgets/profile/edit_profile_view.dart';
import '../widgets/profile/orders_view.dart';
import '../widgets/profile/addresses_view.dart';
import '../widgets/profile/profile_common_widgets.dart';

import '../widgets/profile/profile_view_factory.dart';

// Active view within the profile screen
enum ProfileViewType { home, editProfile, orders, addresses }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileViewType _view = ProfileViewType.home;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrdersProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  void dispose() {
    // Ensure nav bar is restored when leaving this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(true);
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final l10n = Provider.of<LocalizationProvider>(context);

    if (!auth.isAuthenticated) return const GuestAuthView();

    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final content = PopScope(
      canPop: _view == ProfileViewType.home,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_view != ProfileViewType.home) {
          context.read<MainTabsController>().setNavBarVisibility(true);
          setState(() => _view = ProfileViewType.home);
        }
      },
      child: _buildCurrentView(context, auth, l10n, isDesktop),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: content,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: content,
    );
  }

  Widget _buildCurrentView(
    BuildContext context,
    AuthProvider auth,
    LocalizationProvider l10n,
    bool isDesktop,
  ) {
    return ProfileViewFactory.createView(
      viewType: _view,
      isDesktop: isDesktop,
      onNavigateToHome: () {
        context.read<MainTabsController>().setNavBarVisibility(true);
        setState(() => _view = ProfileViewType.home);
      },
      onEditProfile: () {
        context.read<MainTabsController>().setNavBarVisibility(false);
        setState(() => _view = ProfileViewType.editProfile);
      },
      onViewOrders: () {
        context.read<MainTabsController>().setNavBarVisibility(false);
        setState(() => _view = ProfileViewType.orders);
      },
      onViewAddresses: () {
        context.read<MainTabsController>().setNavBarVisibility(false);
        setState(() => _view = ProfileViewType.addresses);
      },
      onShowPaymentSelection: () =>
          _showPaymentSelection(context, Provider.of<PaymentProvider>(context, listen: false), l10n),
      onShowSupportOptions: () => _showSupportOptions(context, l10n),
      showSheet: _showSheet,
    );
  }

  // ── Responsive sheet helper ───────────────────────────────────────────────

  Future<void> _showSheet(
    BuildContext context, {
    required Widget Function(BuildContext ctx, bool isDesktop) builder,
    bool scrollControlled = false,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    if (isDesktop) {
      return showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: builder(ctx, true),
          ),
        ),
      );
    } else {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: scrollControlled,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        builder: (ctx) => builder(ctx, false),
      );
    }
  }

  // ── Payment selection ─────────────────────────────────────────────────────

  void _showPaymentSelection(
    BuildContext context,
    PaymentProvider payment,
    LocalizationProvider l10n,
  ) {
    Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(false);

    _showSheet(context, builder: (ctx, isDesktop) {
      return SheetContainer(
        isDesktop: isDesktop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
              title: l10n.translate('paymentMethod'),
              isDesktop: isDesktop,
              onClose: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 20),
            PaymentOption(
              icon: Icons.payments_outlined,
              label: l10n.translate('cash'),
              description: l10n.translate('cashDescription'),
              isSelected: payment.selectedMethodType == PaymentMethodType.cash,
              onTap: () {
                payment.setMethodType(PaymentMethodType.cash);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            PaymentOption(
              icon: Icons.account_balance_wallet_outlined,
              label: 'iDram',
              description: l10n.translate('idramDescription'),
              isSelected: payment.selectedMethodType == PaymentMethodType.idram,
              onTap: () {
                payment.setMethodType(PaymentMethodType.idram);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            PaymentOption(
              icon: Icons.credit_card_outlined,
              label: l10n.translate('card'),
              description: payment.cards.isNotEmpty
                  ? '•••• ${payment.cards.first.last4}'
                  : l10n.translate('addCardDescription'),
              isSelected: payment.selectedMethodType == PaymentMethodType.card,
              onTap: () {
                if (payment.cards.isEmpty) {
                  Navigator.pop(ctx);
                } else {
                  payment.setMethodType(PaymentMethodType.card);
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      );
    }).then((_) {
      if (context.mounted) {
        Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(true);
      }
    });
  }

  // ── Support ───────────────────────────────────────────────────────────────

  void _showSupportOptions(BuildContext context, LocalizationProvider l10n) {
    Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(false);

    _showSheet(context, builder: (ctx, isDesktop) {
      return SheetContainer(
        isDesktop: isDesktop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
              title: l10n.translate('support'),
              isDesktop: isDesktop,
              onClose: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('howCanWeHelp'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            SupportOption(
              icon: Icons.phone_outlined,
              iconBg: Colors.green.withValues(alpha: 0.12),
              iconColor: Colors.greenAccent,
              title: '+374 60 515515',
              subtitle: l10n.translate('callSupport'),
              onTap: () async {
                final uri = Uri.parse('tel:+37460515515');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            SupportOption(
              icon: Icons.chat_bubble_outline_rounded,
              iconBg: Colors.blue.withValues(alpha: 0.12),
              iconColor: Colors.lightBlueAccent,
              title: l10n.translate('onlineChat'),
              subtitle: l10n.translate('chatDescription'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'SupportChatScreen'),
                    builder: (_) => const SupportChatScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }).then((_) {
      if (context.mounted) {
        Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(true);
      }
    });
  }
}
