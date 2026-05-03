import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'core/localization/localization_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/cart/providers/payment_provider.dart';
import 'features/cart/providers/orders_provider.dart';
import 'features/cart/providers/address_provider.dart';
import 'core/providers/search_provider.dart';
import 'core/providers/main_tabs_controller.dart';
import 'core/widgets/navigation_wrapper.dart';
import 'core/widgets/main_tabs_screen.dart';
import 'features/home/providers/home_provider.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'core/providers/theme_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "YOUR_API_KEY",
          appId: "YOUR_APP_ID",
          messagingSenderId: "YOUR_SENDER_ID",
          projectId: "YOUR_PROJECT_ID",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => AuthProvider(), lazy: false),
        ChangeNotifierProxyProvider<AuthProvider, LocalizationProvider>(
          create: (_) => LocalizationProvider(),
          update: (context, auth, l10n) {
            if (auth.user != null) {
              l10n!.syncWithUser(auth.user!.language);
            }
            return l10n!;
          },
        ),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => MainTabsController()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
    return Consumer2<LocalizationProvider, ThemeProvider>(
      builder: (context, l10n, themeProvider, child) {
        return MaterialApp(
          title: 'MASOOR',
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
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
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: NavigationWrapper(
                key: _wrapperKey,
                navigatorKey: _navigatorKey,
                child: child,
              ),
            );
          },
          home: Consumer2<AuthProvider, OnboardingProvider>(
            builder: (context, authProvider, onboardingProvider, _) {
              if (!onboardingProvider.hasSeenOnboarding) {
                return const OnboardingScreen();
              }
              return const MainTabsScreen();
            },
          ),
        );
      },
    );
  }
}