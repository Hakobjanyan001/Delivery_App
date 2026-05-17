import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlong;
import '../../../core/widgets/universal_map.dart';
import '../../../core/widgets/location_picker_modal.dart';
import '../providers/address_provider.dart';
import '../providers/cart_provider.dart';

class DeliveryAddressSection extends StatelessWidget {
  final AddressProvider addressProvider;
  final CartProvider cartProvider;
  final LatLng currentPos;
  final VoidCallback onGetCurrentLocation;
  final Function(UniversalMapController controller) onMapCreated;

  const DeliveryAddressSection({
    super.key,
    required this.addressProvider,
    required this.cartProvider,
    required this.currentPos,
    required this.onGetCurrentLocation,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 220,
            child: Stack(
              children: [
                RepaintBoundary(
                  child: IgnorePointer(
                    child: UniversalMap(
                      key: const ValueKey('payment_delivery_map'),
                      initialPosition: currentPos,
                      isReadOnly: true,
                      onMapCreated: onMapCreated,
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
                          child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 40),
                        ),
                      ],
                      myLocationEnabled: true,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationPickerModal(
                            initialPosition: currentPos,
                          ),
                        ),
                      );

                      if (result != null) {
                        final LatLng point = result['position'];
                        final String readableAddress = result['address'];

                        if (addressProvider.selectedAddressId != null) {
                          addressProvider.updateAddressDetails(
                            addressProvider.selectedAddressId!,
                            address: readableAddress,
                            lat: point.latitude,
                            lng: point.longitude,
                          );
                          cartProvider.updateDeliveryPriceByDistance(point.latitude, point.longitude);
                        } else {
                          addressProvider.addAddress(
                            'Առաքման վայր',
                            readableAddress,
                            lat: point.latitude,
                            lng: point.longitude,
                          );
                          cartProvider.updateDeliveryPriceByDistance(point.latitude, point.longitude);
                        }
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: onGetCurrentLocation,
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
        if (addressProvider.selectedAddress != null)
          _buildAddressDetails(context, addressProvider),
      ],
    );
  }

  Widget _buildAddressDetails(BuildContext context, AddressProvider ap) {
    final addr = ap.selectedAddress!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  addr.address ?? 'Հասցե',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (addr.entrance != null || addr.floor != null || addr.apartment != null) ...[
            const SizedBox(height: 12),
            Wrap(
              children: [
                if (addr.entrance != null && addr.entrance!.isNotEmpty)
                  _buildTag(context, 'Շքամուտք: ${addr.entrance}'),
                if (addr.floor != null && addr.floor!.isNotEmpty)
                  _buildTag(context, 'Հարկ: ${addr.floor}'),
                if (addr.apartment != null && addr.apartment!.isNotEmpty)
                  _buildTag(context, 'Բնակարան: ${addr.apartment}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
