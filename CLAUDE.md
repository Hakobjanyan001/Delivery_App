# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Figma Design File

File key: `eirewL7ojTipdopeca8ef0`  
URL: https://www.figma.com/design/eirewL7ojTipdopeca8ef0/Masoor?node-id=0-1

Screen node IDs: Home `2:2`, Cart `54:1435`, Search `84:3462`, Checkout `54:2126`, Profile `16:467`, Sign up `64:3241`, Sign in `64:3369`, Order history `54:1257`, Personal info `153:7425`, Addresses `153:7665`, Order detail `54:3059`, Splash `16:451`, Onboarding 1/2/3 `6:39`/`4:5`/`6:28`.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter run -d macos --debug   # Run on macOS (primary dev target)
flutter analyze          # Lint (uses flutter_lints)
flutter test             # Run all tests
flutter test test/path/to/test.dart  # Run a single test file
flutter build apk        # Android release build
flutter build ios        # iOS release build

# Restart the running macOS app
pkill -f "Masoor|flutter_tools" 2>/dev/null; flutter run -d macos --debug
```

## Architecture

**MASOOR** is a Flutter food delivery app targeting Armenian-speaking users. The app name in `pubspec.yaml` is `masoor`.

### State Management
All state is managed via the `provider` package (`ChangeNotifier` + `MultiProvider`). Providers are registered in `main.dart`:
- `AuthProvider` — authentication state, wraps `AuthRepository` (singleton)
- `CartProvider` — cart items, dual-mode (local vs. remote depending on auth)
- `HomeProvider` — banners, categories, restaurants, products fetched concurrently
- `OrdersProvider`, `PaymentProvider`, `AddressProvider` — checkout flow state
- `LocalizationProvider` — in-app locale (hy/en/ru), persisted to SharedPreferences
- `SearchProvider`, `OnboardingProvider` — search overlay and first-launch flow
- `MainTabsController` — owns the `PageController` for the root 3-tab `PageView` (Home/Cart/Profile); the bottom nav reads/writes through it and listens to `pageController.page` for real-time indicator tracking during swipes

### Root layout & Navigation
The app's `home:` is `MainTabsScreen` (after onboarding), which renders a fixed `AppHeader` plus a 3-tab `PageView` containing `HomeScreen`, `CartScreen`, `ProfileScreen`. Tab switches and swipes are coordinated by `MainTabsController`.

Beyond the tabs, there are no named routes — pushed screens use `MaterialPageRoute` with `RouteSettings(name: '...')` for tracking only. `NavigationWrapper` wraps the entire app (set as `builder:` in `MaterialApp`) and uses `AppNavigatorObserver` to watch push/pop events. It overlays:
- the bottom nav pill (hidden on a denylist of pushed screens: `LoginScreen`, `RegisterScreen`, `OrdersScreen`, `OrderDetailsScreen`, `PaymentScreen`, `PaymentWebViewScreen`, `CheckoutScreen`, `SearchScreen`, `SupportChatScreen`, `PhoneAuthScreen`, `FoodDetail`, `OnboardingScreen`)
- a "next step / total" checkout button when the Cart tab is active and the cart is non-empty (gates on auth and pushes `LoginScreen(isCheckoutFlow: true)` first if guest)

### API Layer
Backend: `https://backend.digicraft.am/api` (defined in `lib/core/constants/api_constants.dart`).

All HTTP calls use the `http` package directly — no Dio, no interceptor layer. The `AuthRepository` is a singleton that holds the JWT token in memory and persists it via SharedPreferences (`auth_token` key). All authenticated requests pass `Authorization: Bearer <token>` manually.

The repository layer is split per feature:
- `lib/core/services/api_services.dart` — legacy `ApiManager` (basic fetches)
- `lib/features/home/data/` — per-entity repositories (banner, category, restaurant, product)
- `lib/features/cart/data/cart_repository.dart` — remote cart (authenticated)
- `lib/features/cart/data/local_cart_storage.dart` — guest cart via SharedPreferences

### Cart Dual-Mode Logic
`CartProvider` checks `AuthRepository.token` on every mutation:
- If token is present → calls `CartRepository` (remote API)
- If no token → stores cart in `LocalCartStorage` (SharedPreferences JSON)
- On login, `CartProvider` listens to `AuthRepository.authStateChanges` and syncs local items to remote via `_syncLocalCartToRemote()`

### Localization
No ARB files or `intl` package. All strings live as static `Map<String, Map<String, String>>` inside `LocalizationProvider`. To add a string, add it to all three locale maps (`hy`, `en`, `ru`) and access it with `l10n.translate('key')`. Default locale is Armenian (`hy`).

### Map Widget
`UniversalMap` (`lib/core/widgets/universal_map.dart`) abstracts both `flutter_map` (OpenStreetMap) and `google_maps_flutter`. The `forceOSM: true` flag (default) always uses OSM tiles. Google Maps is wired but not actively used. `UniversalMapController` provides a unified `animateTo()` regardless of underlying map type.

### Auth Notes
Phone authentication is mocked — `verifyPhone` returns a hardcoded `'mock-verification-id'` after 1 second, and SMS code `123456` is hardcoded to succeed. The `signInAnonymously` method uses a 500-second delay (likely a bug — should be 500ms). Firebase code is present in comments throughout `AuthRepository` as reference for a potential future migration back.

### Theme
Dark-only theme defined in `lib/core/theme/app_theme.dart`. `AppTheme.lightTheme` is an alias for `darkTheme`. Primary colors: background `#0F0F0F`, surface `#10100F`, white text/accents. Use `AppColors` constants rather than hardcoding hex values.

### Payment
`PaymentService` (`lib/core/services/payment_service.dart`) is a stub — the base URL is a placeholder. Payment flow opens a WebView (`payment_webview_screen.dart`) with a URL returned from the backend.
