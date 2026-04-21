import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/profile_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../core/theme/app_theme.dart';
import '../localization/localization_provider.dart';
import '../providers/search_provider.dart';

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
  bool _isSearchShowing = false;

  @override
  void initState() {
    super.initState();
    // Default to 'HomeScreen' to ensure nav bar is visible on initial load
    _currentRoute = 'HomeScreen';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {}); // Trigger rebuild to catch initial state
    });
  }

  // Track the current route to hide the button on ProfileScreen
  void updateRoute(String? routeName) {
    // Treat null, '/', or 'HomeScreen' variant as HomeScreen
    String name = (routeName == null || routeName == '/' || routeName == '' || routeName == 'HomeScreen') 
        ? 'HomeScreen' 
        : routeName;
    
    // Clean up potential route name issues (e.g. leading slashes)
    if (name.startsWith('/')) name = name.substring(1);

    if (_currentRoute != name) {
      if (mounted) {
        setState(() {
          _currentRoute = name;
        });
      }
    }
  }

  void _navigateToProfile(bool isAuthenticated) {
    if (_currentRoute == 'ProfileScreen' || _currentRoute == 'LoginScreen') return;
    
    if (isAuthenticated) {
      widget.navigatorKey.currentState?.push(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'ProfileScreen'),
          builder: (_) => const ProfileScreen(),
        ),
      );
    } else {
      widget.navigatorKey.currentState?.push(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'LoginScreen'),
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isAuthenticated = authProvider.isAuthenticated;

    // Show bar everywhere EXCEPT Onboarding and FoodDetail
    final bool showNavBar = _currentRoute != 'OnboardingScreen' && _currentRoute != 'FoodDetail';

    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (showNavBar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildNavBar(isAuthenticated),
          ),
      ],
    );
  }

  Widget _buildNavBar(bool isAuthenticated) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final String route = _currentRoute ?? 'HomeScreen';
    final bool isHome = route == 'HomeScreen';
    final bool isProfile = route == 'ProfileScreen';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // Home & Account Pill
            Container(
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F), // Total Black background
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavBarItem(
                    icon: Icons.home_outlined,
                    label: l10n.translate('home'),
                    isActive: isHome,
                    onTap: () {
                      if (!isHome) {
                        widget.navigatorKey.currentState?.popUntil((route) => route.isFirst);
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                   _NavBarItem(
                    icon: Icons.account_circle_outlined,
                    label: l10n.translate('profile'), 
                    isActive: isProfile,
                    onTap: () => _navigateToProfile(isAuthenticated),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Search or Language Button
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: IconButton(
                icon: Icon(
                  isProfile ? Icons.language : Icons.search,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => isProfile 
                  ? _showLanguageBottomSheet(context) 
                  : _showSearchOverlay(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final navContext = widget.navigatorKey.currentContext;
    if (navContext == null) return;
    
    final l10n = Provider.of<LocalizationProvider>(context, listen: false);

    showModalBottomSheet(
      context: navContext,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 30),
            _buildLanguageOption(context, l10n, const Locale('hy'), '🇦🇲 Հայերեն'),
            const SizedBox(height: 12),
            _buildLanguageOption(context, l10n, const Locale('en'), '🇺🇸 English'),
            const SizedBox(height: 12),
            _buildLanguageOption(context, l10n, const Locale('ru'), '🇷🇺 Русский'),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, LocalizationProvider l10n, Locale locale, String label) {
    final bool isSelected = l10n.currentLocale.languageCode == locale.languageCode;
    
    return GestureDetector(
      onTap: () {
        l10n.setLocale(locale);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  void _showSearchOverlay(BuildContext context) {
    if (_isSearchShowing) return;
    
    final navContext = widget.navigatorKey.currentContext;
    if (navContext == null) return;
    
    setState(() => _isSearchShowing = true);
    
    showModalBottomSheet(
      context: navContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchOverlay(),
    ).then((_) {
      if (mounted) setState(() => _isSearchShowing = false);
      // Clear search when closed
      final searchProv = Provider.of<SearchProvider>(context, listen: false);
      searchProv.clearSearch();
    });
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1F1F1F) : Colors.transparent, // Dark grey for active
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = bottomInset > 0 ? bottomInset : 100.0;
    
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Shrink to fit content
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: (value) {
                searchProvider.updateQuery(value);
              },
              decoration: InputDecoration(
                hintText: l10n.translate('searchHint'),
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () {
                    _controller.clear();
                    searchProvider.clearSearch();
                  },
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10), // Small padding at the bottom
          ],
        ),
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
