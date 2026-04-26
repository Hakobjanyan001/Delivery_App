import 'package:flutter/material.dart';

/// Drives the 3 main tabs (Home / Cart / Profile).
///
/// Owns the [PageController] used by the root [PageView] and exposes the
/// current tab index. The bottom nav bar reads/writes through this controller,
/// and listens to [pageController] for real-time indicator tracking during
/// swipes.
class MainTabsController extends ChangeNotifier {
  static const Duration switchDuration = Duration(milliseconds: 350);
  static const Curve switchCurve = Curves.easeInOut;

  final PageController pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  bool _isNavBarVisible = true;

  MainTabsController() {
    pageController.addListener(_onPageChanged);
  }

  int get currentIndex => _currentIndex;
  bool get isNavBarVisible => _isNavBarVisible;

  void setNavBarVisibility(bool visible) {
    if (_isNavBarVisible != visible) {
      _isNavBarVisible = visible;
      notifyListeners();
    }
  }

  void _onPageChanged() {
    if (!pageController.hasClients) return;
    final page = pageController.page;
    if (page == null) return;
    final rounded = page.round();
    if (rounded != _currentIndex) {
      _currentIndex = rounded;
      notifyListeners();
    }
  }

  /// Animates to [index]. No-op if already there.
  void switchTo(int index) {
    if (index == _currentIndex) return;
    if (!pageController.hasClients) {
      _currentIndex = index;
      notifyListeners();
      return;
    }
    pageController.animateToPage(
      index,
      duration: switchDuration,
      curve: switchCurve,
    );
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.dispose();
  }
}
