import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';

class AddressSelectionSection extends StatelessWidget {
  final Function(AddressProvider) onAddAddress;

  const AddressSelectionSection({
    super.key,
    required this.onAddAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addrProv, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (addrProv.addresses.isNotEmpty) ...[
              ...addrProv.addresses.map((addr) {
                final isSelected = addrProv.selectedAddressId == addr.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.location_on, color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                    title: Text(addr.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(addr.address),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => addrProv.removeAddress(addr.id),
                        ),
                        if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onSurface),
                      ],
                    ),
                    onTap: () {
                      debugPrint('Address selected: ${addr.title}, Lat: ${addr.latitude}');
                      addrProv.selectAddress(addr.id);
                      if (addr.latitude != null && addr.longitude != null) {
                        context.read<CartProvider>().updateDeliveryPriceByDistance(addr.latitude!, addr.longitude!);
                      } else {
                        debugPrint('Cannot calculate distance: Address has no coordinates!');
                      }
                    },
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () => onAddAddress(addrProv),
                icon: const Icon(Icons.add),
                label: const Text('Ավելացնել նոր հասցե'),
              ),
            ] else ...[
              InkWell(
                onTap: () => onAddAddress(addrProv),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                      const SizedBox(width: 10),
                      Text('Ավելացրեք հասցե', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 16)),
                      const Spacer(),
                      Icon(Icons.add_location_alt, color: Theme.of(context).colorScheme.onSurface),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
