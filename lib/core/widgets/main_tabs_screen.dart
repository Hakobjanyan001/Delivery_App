import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/main_tabs_controller.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/auth/screens/profile_screen.dart';
import 'app_header.dart';

/// Root container for the 3 main tabs. Hosts a [PageView] so users can
/// swipe between Home, Cart, and Profile. Tab clicks drive the same
/// controller via [MainTabsController].
class MainTabsScreen extends StatelessWidget {
  const MainTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = context.watch<MainTabsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: PageView(
              controller: tabs.pageController,
              physics: const _SmoothPagePhysics(),
              children: const [
                HomeScreen(),
                CartScreen(),
                ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Slightly heavier resistance + ease curve when settling between pages.
class _SmoothPagePhysics extends ScrollPhysics {
  const _SmoothPagePhysics({super.parent});

  @override
  _SmoothPagePhysics applyTo(ScrollPhysics? ancestor) {
    return _SmoothPagePhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 1.0,
        stiffness: 80,
        damping: 18,
      );
}
