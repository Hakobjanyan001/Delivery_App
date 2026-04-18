import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/localization/localization_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/cart/providers/payment_provider.dart';
import 'features/cart/providers/orders_provider.dart';
import 'features/cart/providers/address_provider.dart';
import 'core/services/firebase_service.dart';
import 'core/widgets/navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
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
    final authProvider = Provider.of<AuthProvider>(context);
    
    return MaterialApp(
      title: 'MASOOR',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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
      home: authProvider.isAuthenticated 
          ? const HomeScreen() 
          : const LoginScreen(),
    );
  }
}