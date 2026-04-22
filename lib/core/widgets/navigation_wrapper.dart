import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../localization/localization_provider.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/cart/screens/checkout_screen.dart';
import '../providers/search_provider.dart';
import '../../features/home/widgets/search_overlay_widget.dart';

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
    String name = (routeName == null || routeName == '/' || routeName == '' || routeName == 'HomeScreen') 
        ? 'HomeScreen' 
        : routeName;
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
        _currentRoute != 'RegisterScreen';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          if (widget.child != null) widget.child!,
          
          // Search Overlay Layer
          Consumer<SearchProvider>(
            builder: (context, search, child) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutExpo,
                top: search.isSearchActive ? 60 : MediaQuery.of(context).size.height,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: search.isSearchActive ? 1.0 : 0.0,
                  child: SearchOverlayWidget(
                    onClose: () {
                      search.setSearchActive(false);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              );
            },
          ),

          if (showNavBar)
            Consumer<SearchProvider>(
              builder: (context, search, child) {
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                final bottomOffset = search.isSearchActive ? (keyboardHeight > 0 ? keyboardHeight + 40 : 120.0) : 0.0;
                
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  bottom: bottomOffset,
                  left: 0,
                  right: 0,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNavBar(isAuthenticated, search.isSearchActive),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavBar(bool isAuthenticated, bool isSearchActive) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final String route = _currentRoute ?? 'HomeScreen';
    final bool isHome = route == 'HomeScreen';
    final bool isCart = route == 'CartScreen';

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
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Separate Search Button
            Consumer<SearchProvider>(
              builder: (context, search, child) {
                return GestureDetector(
                  onTap: () => search.toggleSearchActive(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Icon(
                      search.isSearchActive ? Icons.close : Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
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
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1F1F1F) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
