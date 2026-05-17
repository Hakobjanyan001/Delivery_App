import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../localization/localization_provider.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../features/cart/screens/payment_screen.dart';
import '../providers/main_tabs_controller.dart';
import '../constants/route_constants.dart';

// Figma specs (nav node 16:599):
//   Outer:        gradient bg (transparent→black), px:16 py:8
//   Inner pill:   h:72  radius:48  blur:8  bg:rgba(15,15,15,0.9)  border:rgba(255,255,255,0.1)
//   Indicator:    radius:64  bg:rgba(255,255,255,0.1)  4px inset on all sides
//   Tab items:    flex-1  gap:8  icon:24  label:14px bold white

class NavigationWrapper extends StatefulWidget {
  final Widget? child;
  final GlobalKey<NavigatorState> navigatorKey;

  const NavigationWrapper({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  String? _currentRoute = RouteConstants.home;

  void updateRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty) return;
    String name = (routeName == '/') ? RouteConstants.home : routeName;
    if (name.startsWith('/')) name = name.substring(1);
    if (_currentRoute != name && mounted) {
      setState(() => _currentRoute = name);
    }
  }

  bool get _showNavBar {
    final onboarding = context.read<OnboardingProvider>();
    if (!onboarding.hasSeenOnboarding) return false;

    // Check if the tabs controller has explicitly hidden the nav bar
    final tabs = context.watch<MainTabsController>();
    if (!tabs.isNavBarVisible) return false;

    const hidden = {
      RouteConstants.onboarding, RouteConstants.login,
      RouteConstants.register, RouteConstants.orders, RouteConstants.orderDetails,
      RouteConstants.payment, RouteConstants.paymentWebView, RouteConstants.checkout,
      RouteConstants.search, RouteConstants.supportChat, RouteConstants.phoneAuth,
      RouteConstants.foodDetail,
    };
    return !hidden.contains(_currentRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          if (widget.child != null) widget.child!,
          if (_showNavBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _NavBar(
                navigatorKey: widget.navigatorKey,
                isAuthenticated: isAuthenticated,
                currentRoute: _currentRoute,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final bool isAuthenticated;
  final String? currentRoute;

  const _NavBar({
    required this.navigatorKey,
    required this.isAuthenticated,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final tabs = context.watch<MainTabsController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Checkout button — visible when on Cart tab
        if (tabs.currentIndex == 1)
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.items.isEmpty) return const SizedBox.shrink();
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: GestureDetector(
                      onTap: () async {
                        if (!isAuthenticated) {
                          final success = await navigatorKey.currentState
                              ?.push<bool>(MaterialPageRoute(
                            settings: const RouteSettings(name: RouteConstants.login),
                            builder: (_) => const LoginScreen(isCheckoutFlow: true),
                          ));
                          if (success != true) return;
                        }
                        navigatorKey.currentState?.push(MaterialPageRoute(
                          settings: const RouteSettings(name: RouteConstants.payment),
                          builder: (_) => const PaymentScreen(),
                        ));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface,
                          borderRadius: BorderRadius.circular(40),

                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),

                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Հաջորդ քայլ ${cart.totalAmount.toStringAsFixed(0)} ֏',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),

                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

        // Nav pill
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
              ],
            ),
          ),

          child: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: _NavPill(
                    tabs: tabs,
                    l10n: l10n,
                    currentRoute: currentRoute,
                    navigatorKey: navigatorKey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pill with the sliding indicator. The indicator tracks
/// `pageController.page` in real-time so swipes feel native, while
/// tab clicks animate via the controller's easeInOut curve.
class _NavPill extends StatelessWidget {
  final MainTabsController tabs;
  final LocalizationProvider l10n;
  final String? currentRoute;
  final GlobalKey<NavigatorState> navigatorKey;

  const _NavPill({
    required this.tabs,
    required this.l10n,
    required this.currentRoute,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(48),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          ),

          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 3;

              return Stack(
                children: [
                  // Sliding indicator — driven by PageController for real-time tracking
                  AnimatedBuilder(
                    animation: tabs.pageController,
                    builder: (context, child) {
                      final page = tabs.pageController.hasClients &&
                              tabs.pageController.page != null
                          ? tabs.pageController.page!.clamp(0.0, 2.0)
                          : tabs.currentIndex.toDouble();

                      return Positioned(
                        top: 4,
                        bottom: 4,
                        left: tabWidth * page + 4,
                        width: tabWidth - 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(64),
                          ),

                        ),
                      );
                    },
                  ),

                  // Tabs
                  Row(
                    children: [
                      _NavTab(
                        icon: Icons.home_outlined,
                        label: l10n.translate('home'),
                        onTap: () {
                          if (currentRoute == RouteConstants.foodDetail) {
                            navigatorKey.currentState?.pop();
                          }
                          tabs.switchTo(0);
                        },
                      ),
                      _NavTab(
                        icon: Icons.shopping_cart_outlined,
                        label: l10n.translate('cart'),
                        onTap: () {
                          if (currentRoute == RouteConstants.foodDetail) {
                            navigatorKey.currentState?.pop();
                          }
                          tabs.switchTo(1);
                        },
                      ),
                      _NavTab(
                        icon: Icons.person_outline,
                        label: l10n.translate('profile'),
                        onTap: () {
                          if (currentRoute == RouteConstants.foodDetail) {
                            navigatorKey.currentState?.pop();
                          }
                          tabs.switchTo(2);
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 24),

            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),

            ),
          ],
        ),
      ),
    );
  }
}

class AppNavigatorObserver extends NavigatorObserver {
  final void Function(String?) onRouteChanged;
  AppNavigatorObserver({required this.onRouteChanged});

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    onRouteChanged(route.settings.name);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    onRouteChanged(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    onRouteChanged(newRoute?.settings.name);
  }
}
