import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../localization/localization_provider.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../providers/search_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/widgets/search_overlay_widget.dart';

import '../../features/cart/providers/cart_provider.dart';
import '../../features/cart/screens/payment_screen.dart';
import '../../features/auth/screens/profile_screen.dart';

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

class _NavigationWrapperState extends State<NavigationWrapper> with RouteAware {
  String? _currentRoute;

  @override
  void initState() {
    super.initState();
    _currentRoute = 'HomeScreen';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void updateRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty) return; // Ignore dialogs/menus without explicit names

    String name = (routeName == '/') ? 'HomeScreen' : routeName;
    if (name.startsWith('/')) name = name.substring(1);
    if (_currentRoute != name) {
      if (mounted) setState(() => _currentRoute = name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isAuthenticated = authProvider.isAuthenticated;
    final bool hasSeenOnboarding = context.watch<OnboardingProvider>().hasSeenOnboarding;

    final bool showNavBar = hasSeenOnboarding &&
        _currentRoute != 'OnboardingScreen' &&
        _currentRoute != 'FoodDetail' &&
        _currentRoute != 'LoginScreen' &&
        _currentRoute != 'RegisterScreen' &&
        _currentRoute != 'OrdersScreen' &&
        _currentRoute != 'OrderDetailsScreen' &&
        _currentRoute != 'ProfileScreen';

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          if (widget.child != null) widget.child!,

          if (showNavBar)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: 0,
              left: 0,
              right: 0,
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_currentRoute == 'CartScreen')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                        child: Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            if (cart.items.isEmpty) return const SizedBox.shrink();
                            return GestureDetector(
                              onTap: () async {
                                if (!isAuthenticated) {
                                  final success = await widget.navigatorKey.currentState?.push<bool>(
                                    MaterialPageRoute(
                                      settings: const RouteSettings(name: 'LoginScreen'),
                                      builder: (context) => const LoginScreen(isCheckoutFlow: true),
                                    ),
                                  );
                                  if (success != true) return;
                                }
                                widget.navigatorKey.currentState?.push(
                                  MaterialPageRoute(
                                    settings: const RouteSettings(name: 'PaymentScreen'),
                                    builder: (context) => const PaymentScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Հաջորդ քայլ ${cart.totalAmount.toStringAsFixed(0)} ֏',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    _buildNavBar(isAuthenticated),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavBar(bool isAuthenticated) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final String route = _currentRoute ?? 'HomeScreen';
    final bool isHome = route == 'HomeScreen';
    final bool isCart = route == 'CartScreen';
    final bool isProfile = route == 'ProfileScreen';
    final bool isPayment = route == 'PaymentScreen';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main Navigation Pill (Home & Cart)
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavBarItem(
                    icon: Icons.home_outlined,
                    label: l10n.translate('home'),
                    isActive: isHome,
                    onTap: () {
                      if (!isHome) widget.navigatorKey.currentState?.popUntil((route) => route.isFirst);
                    },
                  ),
                  _NavBarItem(
                    icon: Icons.shopping_cart_outlined,
                    label: l10n.translate('cart'),
                    isActive: isCart,
                    onTap: () {
                      if (!isCart) {
                        widget.navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            settings: const RouteSettings(name: 'CartScreen'),
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  _NavBarItem(
                    icon: Icons.person_outline,
                    label: l10n.translate('profile'),
                    isActive: isProfile,
                    onTap: () {
                      if (!isAuthenticated) {
                        widget.navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            settings: const RouteSettings(name: 'LoginScreen'),
                            builder: (context) => const LoginScreen(isCheckoutFlow: false),
                          ),
                        );
                      } else if (!isProfile) {
                        widget.navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            settings: const RouteSettings(name: 'ProfileScreen'),
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1F1F1F) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppNavigatorObserver extends NavigatorObserver {
  final Function(String?) onRouteChanged;
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
