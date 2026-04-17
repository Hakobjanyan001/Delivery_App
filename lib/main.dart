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

class MasoorApp extends StatelessWidget {
  const MasoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return MaterialApp(
      title: 'MASOOR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authProvider.isAuthenticated 
          ? const HomeScreen() 
          : const LoginScreen(),
    );
  }
}