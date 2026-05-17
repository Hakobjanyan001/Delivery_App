import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/cart_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/address_provider.dart';
import '../providers/orders_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/providers/main_tabs_controller.dart';
import '../../../core/widgets/universal_map.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/delivery_address_section.dart';
import '../widgets/payment_method_selector.dart';
import '../../../core/patterns/order_command.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}


class _PaymentScreenState extends State<PaymentScreen> {
  UniversalMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    final address = Provider.of<AddressProvider>(context, listen: false);
    if (address.selectedAddressId != null) {
      address.updateAddressCoordinates(
        address.selectedAddressId!,
        position.latitude,
        position.longitude,
      );
    }
    _mapController?.animateTo(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final payment = Provider.of<PaymentProvider>(context);
    final address = Provider.of<AddressProvider>(context);
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;
    final auth = Provider.of<AuthProvider>(context);
    final orders = Provider.of<OrdersProvider>(context);

    final currentPos = address.selectedAddress?.latitude != null
        ? LatLng(
            address.selectedAddress!.latitude!,
            address.selectedAddress!.longitude!,
          )
        : const LatLng(40.8142, 44.4842); // Default to Vanadzor

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            Text(
              'Վճարում',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          _buildUserAction(context, auth),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Ապրանքներ'),
            const SizedBox(height: 16),
            OrderSummaryCard(cart: cart, lang: lang),
            const SizedBox(height: 32),
            _buildSectionTitle('Առաքում'),
            const SizedBox(height: 16),
            DeliveryAddressSection(
              addressProvider: address,
              cartProvider: cart,
              currentPos: currentPos,
              onGetCurrentLocation: _getCurrentLocation,
              onMapCreated: (controller) => _mapController = controller,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Վճարման եղանակ'),
            const SizedBox(height: 16),
            PaymentMethodSelector(payment: payment),
            const SizedBox(height: 40),
            _buildCheckoutButton(context, cart, payment, orders, auth, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    );
  }

  Widget _buildUserAction(BuildContext context, AuthProvider auth) {
    return GestureDetector(
      onTap: () {
        if (!auth.isAuthenticated) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(isCheckoutFlow: false),
            ),
          );
        } else {
          Navigator.popUntil(context, (r) => r.isFirst);
          context.read<MainTabsController>().switchTo(2);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_outline,
          color: Theme.of(context).colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(
    BuildContext context,
    CartProvider cart,
    PaymentProvider payment,
    OrdersProvider orders,
    AuthProvider auth,
    LocalizationProvider l10n,
  ) {
    return GestureDetector(
      onTap: () async {
        final success = await PlaceOrderCommand().execute(context);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Պատվերը հաջողությամբ գրանցվեց')),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(
            'Պատվիրել',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
