import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/cart_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/address_provider.dart';
import '../providers/orders_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/card_entry_form.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/providers/main_tabs_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/widgets/universal_map.dart';
import '../../home/providers/home_provider.dart';
import '../../../core/models/restaurant_model.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  UniversalMapController? _mapController;
  String? _selectedSavedAddressId;

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

  Widget _buildAddressDetailTag(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddressEditDialog(
    BuildContext context,
    AddressProvider addressProvider,
    LocalizationProvider l10n,
  ) {
    final address = addressProvider.selectedAddress;
    final addressController = TextEditingController(text: address?.address);
    final entranceController = TextEditingController(text: address?.entrance);
    final floorController = TextEditingController(text: address?.floor);
    final apartmentController = TextEditingController(text: address?.apartment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10100F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Խմբագրել հասցեն',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditTextField(addressController, 'Հասցե'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEditTextField(entranceController, 'Շքամուտք'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildEditTextField(floorController, 'Հարկ')),
                ],
              ),
              const SizedBox(height: 12),
              _buildEditTextField(apartmentController, 'Դուռ / Բնակարան'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Չեղարկել',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              String typedAddress = addressController.text;
              double? lat = address?.latitude;
              double? lng = address?.longitude;

              // Try geocoding the typed address to find coordinates
              if (typedAddress.isNotEmpty && typedAddress != address?.address) {
                try {
                  List<Location> locations = await locationFromAddress(
                    typedAddress,
                  );
                  if (locations.isNotEmpty) {
                    lat = locations.first.latitude;
                    lng = locations.first.longitude;
                    _mapController?.animateTo(lat, lng);
                  }
                } catch (_) {}
              }

              if (address?.id != null) {
                addressProvider.updateAddressDetails(
                  address!.id,
                  address: typedAddress,
                  lat: lat,
                  lng: lng,
                  entrance: entranceController.text,
                  floor: floorController.text,
                  apartment: apartmentController.text,
                );
              } else {
                addressProvider.addAddress(
                  'Առաքման վայր',
                  typedAddress,
                  lat: lat,
                  lng: lng,
                  entrance: entranceController.text,
                  floor: floorController.text,
                  apartment: apartmentController.text,
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              'Պահպանել',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildInlinePaymentItem(
    BuildContext context,
    PaymentProvider payment,
    LocalizationProvider l10n,
    PaymentMethodType type,
    IconData icon,
    String title,
  ) {
    final isSelected = payment.selectedMethodType == type;
    return GestureDetector(
      onTap: () {
        if (type == PaymentMethodType.card && payment.cards.isEmpty) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            useRootNavigator: true,
            builder: (_) => const CardEntryForm(),
          );
        } else {
          payment.setMethodType(type);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF10100F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Segoe UI',
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSavedAddressesBottomSheet(BuildContext context, AuthProvider authProvider, AddressProvider addressProvider, LocalizationProvider l10n) {
    final savedAddresses = authProvider.user?.addresses ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          margin: const EdgeInsets.only(bottom: 0),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          decoration: const BoxDecoration(
            color: Color(0xFF0F0F0F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Իմ հասցեները',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              if (savedAddresses.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: const Text(
                    'Պահպանված հասցեներ չկան',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              else
                ...savedAddresses.map((addr) {
                  final isSelected = _selectedSavedAddressId == addr.id;
                  return GestureDetector(
                    onTap: () {
                      if (addr.id != null) {
                        setState(() => _selectedSavedAddressId = addr.id);
                      }
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: isSelected ? Colors.black : Colors.white70,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  addr.label ?? 'Հասցե',
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (addr.address != null && addr.address!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    addr.address!,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black.withOpacity(0.55)
                                          : Colors.white.withValues(alpha: 0.45),
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.black, size: 22),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
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
    final homeProvider = Provider.of<HomeProvider>(context);

    // Get restaurant info for delivery settings
    RestaurantModel? restaurant;
    if (cart.items.isNotEmpty) {
      try {
        final restaurantId = cart.items.first.product.restaurantId;
        restaurant = homeProvider.restaurants.firstWhere((r) => r.id == restaurantId);
      } catch (_) {}
    }

    final double deliveryFee = (restaurant != null && cart.totalAmount < restaurant.delivery.freeDeliveryFrom) 
        ? restaurant.delivery.basePrice 
        : 0.0;
    
    final double finalTotal = cart.totalAmount + deliveryFee;

    final currentPos = address.selectedAddress?.latitude != null
        ? LatLng(
            address.selectedAddress!.latitude!,
            address.selectedAddress!.longitude!,
          )
        : const LatLng(40.8142, 44.4842); // Default to Vanadzor

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            const SizedBox(
              width: 266,
              height: 24,
              child: Text(
                'Վճարում',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Segoe UI',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (!auth.isAuthenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'LoginScreen'),
                    builder: (context) =>
                        const LoginScreen(isCheckoutFlow: false),
                  ),
                );
              } else {
                // Pop back to root and switch to Profile tab
                Navigator.popUntil(context, (r) => r.isFirst);
                context.read<MainTabsController>().switchTo(2);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF161616),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 370,
                height: 24,
                child: Text(
                  'Ապրանքներ',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Segoe UI',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF10100F),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  children: [
                    ...cart.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.product.name.getLocalized(lang),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${item.quantity.toInt()} բաժին',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${item.totalPrice.toStringAsFixed(0)} ֏',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ապրանքներ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${cart.totalAmount.toStringAsFixed(0)} ֏',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Առաքում',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          deliveryFee > 0 ? '${deliveryFee.toStringAsFixed(0)} ֏' : 'Անվճար',
                          style: TextStyle(
                            color: deliveryFee > 0 ? Colors.white : Colors.greenAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ընդհանուր',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${finalTotal.toStringAsFixed(0)} ֏',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 370,
                height: 24,
                child: Text(
                  'Առաքում',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Segoe UI',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 220,
                  child: Stack(
                    children: [
                      RepaintBoundary(
                        child: UniversalMap(
                          key: const ValueKey('payment_delivery_map'),
                          initialPosition: currentPos,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          // Night mode style only for Google Maps
                          _mapController?.setMapStyle('''
[
  {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
]
''');
                        },
                        onTap: (LatLng point) async {
                          if (address.selectedAddressId != null) {
                            address.updateAddressDetails(
                              address.selectedAddressId!,
                              address: 'Որոնվում է...',
                            );
                          }

                          String readableAddress = 'Ընտրված հասցե';
                          try {
                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(
                                  point.latitude,
                                  point.longitude,
                                );
                            if (placemarks.isNotEmpty) {
                              Placemark place = placemarks.first;
                              List<String> parts = [];
                              String? street =
                                  place.street ??
                                  place.thoroughfare ??
                                  place.name;
                              if (street != null &&
                                  street.isNotEmpty &&
                                  street != place.locality) {
                                parts.add(street);
                              }
                              String? city =
                                  place.locality ??
                                  place.subAdministrativeArea;
                              if (city != null && city.isNotEmpty) {
                                parts.add(city);
                              }
                              readableAddress =
                                  parts.isNotEmpty
                                      ? parts.join(', ')
                                      : (place.locality ?? 'Ընտրված վայր');
                            }
                          } catch (_) {
                            // Fallback to OSM Nominatim API if native geocoding fails (e.g. on Web)
                            try {
                              final url = Uri.parse(
                                'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1',
                              );
                              final response = await http.get(url, headers: {
                                'Accept-Language': 'hy',
                              });
                              if (response.statusCode == 200) {
                                final data = json.decode(response.body);
                                if (data['address'] != null) {
                                  final addr = data['address'];
                                  final road = addr['road'] ?? addr['pedestrian'] ?? addr['path'] ?? addr['suburb'];
                                  final house = addr['house_number'];
                                  final city = addr['city'] ?? addr['town'] ?? addr['village'];
                                  
                                  List<String> parts = [];
                                  if (road != null) {
                                    parts.add(house != null ? '$road $house' : road);
                                  }
                                  if (city != null && city != road) {
                                    parts.add(city);
                                  }
                                  
                                  if (parts.isNotEmpty) {
                                    readableAddress = parts.join(', ');
                                  } else {
                                    readableAddress = data['display_name'] ?? 'Ընտրված վայր';
                                  }
                                }
                              } else {
                                readableAddress = 'Ընտրված վայր';
                              }
                            } catch (e) {
                              readableAddress = 'Ընտրված վայր';
                            }
                          }

                          if (address.selectedAddressId != null) {
                            address.updateAddressDetails(
                              address.selectedAddressId!,
                              address: readableAddress,
                              lat: point.latitude,
                              lng: point.longitude,
                            );
                          } else {
                            address.addAddress(
                              'Առաքման վայր',
                              readableAddress,
                              lat: point.latitude,
                              lng: point.longitude,
                            );
                          }
                        },
                        googleMarkers: {
                          Marker(
                            markerId: const MarkerId('selected_address'),
                            position: currentPos,
                          ),
                        },
                        osmMarkers: [
                          osm.Marker(
                            point: latlong.LatLng(currentPos.latitude, currentPos.longitude),
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on, color: Colors.white, size: 40),
                          ),
                        ],
                        myLocationEnabled: true,
                      ),
                    ),
                    Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: _getCurrentLocation,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (address.selectedAddress != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                  child: Text(
                    address.selectedAddress!.address,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showAddressEditDialog(context, address, l10n),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10100F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              address.selectedAddress?.address ??
                                  'Վանաձոր, Վարդանանց 15/3',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Segoe UI',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            deliveryFee > 0 ? '${deliveryFee.toStringAsFixed(0)} ֏' : 'Անվճար',
                            style: TextStyle(
                              color: deliveryFee > 0 ? Colors.white : Colors.greenAccent,
                              fontFamily: 'Segoe UI',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (address.selectedAddress != null &&
                          (address.selectedAddress!.entrance != null ||
                              address.selectedAddress!.floor != null ||
                              address.selectedAddress!.apartment != null)) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (address.selectedAddress!.entrance != null)
                              _buildAddressDetailTag(
                                'Շքամուտք: ${address.selectedAddress!.entrance}',
                              ),
                            if (address.selectedAddress!.floor != null)
                              _buildAddressDetailTag(
                                'Հարկ: ${address.selectedAddress!.floor}',
                              ),
                            if (address.selectedAddress!.apartment != null)
                              _buildAddressDetailTag(
                                'Դուռ: ${address.selectedAddress!.apartment}',
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Show selected saved address label
              if (_selectedSavedAddressId != null)
                Builder(builder: (context) {
                  final saved = auth.user?.addresses.where((a) => a.id == _selectedSavedAddressId).firstOrNull;
                  if (saved == null) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                saved.label ?? 'Ընտրված հասցե',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              if (saved.address != null && saved.address!.isNotEmpty)
                                Text(
                                  saved.address!,
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _selectedSavedAddressId = null),
                          child: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.4), size: 18),
                        ),
                      ],
                    ),
                  );
                }),
              GestureDetector(
                onTap: () => _showSavedAddressesBottomSheet(context, auth, address, l10n),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedSavedAddressId != null
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFF10100F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedSavedAddressId != null
                          ? Colors.greenAccent.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _selectedSavedAddressId != null
                                ? Icons.check_circle_outline
                                : Icons.bookmark_border_outlined,
                            color: _selectedSavedAddressId != null
                                ? Colors.greenAccent
                                : Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedSavedAddressId != null ? '\u0538\u0576\u057f\u0580\u057e\u0561\u056e \u0570\u0561\u057d\u0581\u0565\u0576' : '\u053b\u0574 \u0570\u0561\u057d\u0581\u0565\u0576\u0565\u0580\u0568',
                            style: TextStyle(
                              color: _selectedSavedAddressId != null
                                  ? Colors.greenAccent
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: _selectedSavedAddressId != null
                            ? Colors.greenAccent.withValues(alpha: 0.7)
                            : Colors.white38,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 370,
                height: 24,
                child: Text(
                  'Վճարման Տարբերակներ',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Segoe UI',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildInlinePaymentItem(
                context,
                payment,
                l10n,
                PaymentMethodType.card,
                Icons.credit_card,
                'Քարտ',
              ),
              const SizedBox(height: 12),
              _buildInlinePaymentItem(
                context,
                payment,
                l10n,
                PaymentMethodType.idram,
                Icons.account_balance_wallet_outlined,
                'Idram',
              ),
              const SizedBox(height: 12),
              _buildInlinePaymentItem(
                context,
                payment,
                l10n,
                PaymentMethodType.cash,
                Icons.payments_outlined,
                'Կանխիկ',
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () async {
                  if (auth.isAuthenticated) {
                    final deliveryAddress = address.selectedAddress;
                    await orders.addOrder(
                      cart.items,
                      cart.totalAmount,
                      deliveryPrice: deliveryFee,
                      paymentMethod: payment.selectedMethodType.name,
                      phone: auth.phone ?? '',
                      address: _selectedSavedAddressId != null
                          ? {} // Backend will resolve address from addressId
                          : {'address': deliveryAddress?.address ?? ""},
                      addressId: _selectedSavedAddressId,
                    );
                    await cart.clearCart();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.translate('orderSuccess'))),
                      );
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.translate('registerToPurchase')),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Հաստատել Պատվերը',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Segoe UI',
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
