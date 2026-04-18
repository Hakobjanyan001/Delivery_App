import 'package:flutter/material.dart';
import '../../features/auth/screens/profile_screen.dart';
import '../../features/cart/screens/cart_screen.dart';

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

  // Track the current route to hide the button on ProfileScreen
  void updateRoute(String? routeName) {
    // Default to 'HomeScreen' if name is null (typical for initial route)
    final String name = routeName ?? 'HomeScreen';
    if (_currentRoute != name) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentRoute = name;
          });
        }
      });
    }
  }

  void _navigateToProfile() {
    if (_currentRoute == 'ProfileScreen') return;
    widget.navigatorKey.currentState?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'ProfileScreen'),
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _navigateToCart() {
    if (_currentRoute == 'CartScreen') return;
    widget.navigatorKey.currentState?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'CartScreen'),
        builder: (_) => const CartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hide button if we are in ProfileScreen or if it's the LoginScreen (optional but recommended)
    final bool showProfileButton = _currentRoute != 'ProfileScreen' && _currentRoute != 'LoginScreen';

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Threshold for swipe detection
        if (details.primaryVelocity == null) return;
        
        if (details.primaryVelocity! > 500) {
          // Swipe Right -> Profile
          _navigateToProfile();
        } else if (details.primaryVelocity! < -500) {
          // Swipe Left -> Cart
          _navigateToCart();
        }
      },
      child: Stack(
        children: [
          if (widget.child != null) widget.child!,
          
          if (showProfileButton)
            Positioned(
              left: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: _navigateToProfile,
                backgroundColor: Colors.blue[900],
                mini: true, // Smaller as requested "նշանը"
                heroTag: null,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom NavigatorObserver to update the NavigationWrapper
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
