import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/localization_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/cart/providers/payment_provider.dart';
import 'features/cart/providers/orders_provider.dart';
import 'features/cart/providers/address_provider.dart';
import 'core/providers/search_provider.dart';
import 'core/widgets/navigation_wrapper.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const MasoorApp(),
    ),
  );
}

class MasoorApp extends StatefulWidget {
  const MasoorApp({super.key});

  @override
  State<MasoorApp> createState() => _MasoorAppState();
}

class _MasoorAppState extends State<MasoorApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<State<NavigationWrapper>> _wrapperKey = GlobalKey<State<NavigationWrapper>>();

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, l10n, child) {
        return MaterialApp(
          title: 'MASOOR',
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: l10n.currentLocale,
          supportedLocales: const [
            Locale('hy'),
            Locale('en'),
            Locale('ru'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          navigatorObservers: [
            AppNavigatorObserver(
              onRouteChanged: (name) {
                final state = _wrapperKey.currentState;
                if (state != null) {
                  (state as dynamic).updateRoute(name);
                }
              },
            ),
          ],
          builder: (context, child) {
            return NavigationWrapper(
              key: _wrapperKey,
              navigatorKey: _navigatorKey,
              child: child,
            );
          },
          home: Consumer2<AuthProvider, OnboardingProvider>(
            builder: (context, authProvider, onboardingProvider, _) {
              if (!onboardingProvider.hasSeenOnboarding) {
                return const OnboardingScreen();
              }
              return const HomeScreen();
            },
          ),
        );
      },
    );
  }
}