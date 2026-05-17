import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:masoor/features/auth/providers/auth_provider.dart';
import 'package:masoor/features/auth/models/address_model.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import 'package:masoor/core/providers/main_tabs_controller.dart';
import 'package:masoor/core/widgets/universal_map.dart';
import 'package:masoor/core/widgets/location_picker_modal.dart';
import 'package:masoor/features/auth/widgets/profile/profile_common_widgets.dart';

class AddressesView extends StatelessWidget {
  final VoidCallback onBack;
  final Future<void> Function(BuildContext context, {required Widget Function(BuildContext ctx, bool isDesktop) builder, bool scrollControlled}) showSheet;

  const AddressesView({
    super.key,
    required this.onBack,
    required this.showSheet,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final l10n = Provider.of<LocalizationProvider>(context);
    final addresses = auth.user?.addresses ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeader(
          title: l10n.translate('myAddresses'),
          onBack: onBack,
          action: GestureDetector(
            onTap: () => _showAddNewAddressDialog(context, auth, l10n),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+ ${l10n.translate('add')}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: addresses.isEmpty
              ? EmptyState(message: l10n.translate('noAddresses'), icon: Icons.location_on_outlined)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  itemCount: addresses.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final addr = addresses[i];
                    return _buildAddressCard(ctx, auth, addr, l10n);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context, AuthProvider auth, Address addr, LocalizationProvider l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on_outlined,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addr.label != null && addr.label!.isNotEmpty ? addr.label! : 'Հասցե',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (addr.address != null && addr.address!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    addr.address!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showAddressEditInline(context, auth, addr, l10n),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNewAddressDialog(BuildContext context, AuthProvider auth, LocalizationProvider l10n) {
    final titleCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    double lat = 40.8142; 
    double lng = 44.4842;

    Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(false);

    showSheet(context, scrollControlled: true, builder: (ctx, isDesktop) {
      return SheetContainer(
        isDesktop: isDesktop,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetHeader(
                title: l10n.translate('newAddress'),
                isDesktop: isDesktop,
                onClose: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 20),
              AddressField(controller: titleCtrl, hint: l10n.translate('addressNameHint'), icon: Icons.label_outline),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (ctx, setSheetState) {
                  final currentPos = LatLng(lat, lng);
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 160,
                          child: Stack(
                            children: [
                              IgnorePointer(
                                child: UniversalMap(
                                  key: ValueKey('preview_${lat}_${lng}'),
                                  initialPosition: currentPos,
                                  isReadOnly: true,
                                  googleMarkers: {
                                    Marker(
                                      markerId: const MarkerId('preview'),
                                      position: currentPos,
                                    ),
                                  },
                                  osmMarkers: [
                                    osm.Marker(
                                      point: latlong.LatLng(lat, lng),
                                      width: 40,
                                      height: 40,
                                      child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 40),
                                    ),
                                  ],
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
                                      setSheetState(() {
                                        lat = result['position'].latitude;
                                        lng = result['position'].longitude;
                                        addrCtrl.text = result['address'];
                                      });
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AddressField(controller: addrCtrl, hint: l10n.translate('addressFullHint'), icon: Icons.location_on_outlined, enabled: false,),
                    ],
                  );
                },
              ),
              if (!isDesktop)
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                  child: const SizedBox(height: 12),
                ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.translate('save'),
                onTap: () async {
                  if (addrCtrl.text.trim().isNotEmpty) {
                    final success = await auth.addAddress(Address(
                      label: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : l10n.translate('address'),
                      address: addrCtrl.text.trim(),
                      lat: lat,
                      lng: lng,
                    ));
                    if (success && ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    }).then((_) {
      if (context.mounted) {
        Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(true);
      }
    });
  }

  void _showAddressEditInline(BuildContext context, AuthProvider auth, Address addr, LocalizationProvider l10n) {
    final titleCtrl = TextEditingController(text: addr.label);
    final addrCtrl = TextEditingController(text: addr.address);
    double lat = addr.lat ?? 40.8142;
    double lng = addr.lng ?? 44.4842;

    Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(false);

    showSheet(context, scrollControlled: true, builder: (ctx, isDesktop) {
      return SheetContainer(
        isDesktop: isDesktop,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SheetHeader(
                      title: l10n.translate('editAddress'),
                      isDesktop: isDesktop,
                      onClose: () => Navigator.pop(ctx),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (addr.id != null) {
                        final success = await auth.deleteAddress(addr.id!);
                        if (success && ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AddressField(controller: titleCtrl, hint: l10n.translate('addressNameHint'), icon: Icons.label_outline),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (ctx, setSheetState) {
                  final currentPos = LatLng(lat, lng);
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 160,
                          child: Stack(
                            children: [
                              IgnorePointer(
                                child: UniversalMap(
                                  key: ValueKey('edit_preview_${lat}_${lng}'),
                                  initialPosition: currentPos,
                                  isReadOnly: true,
                                  googleMarkers: {
                                    Marker(
                                      markerId: const MarkerId('preview'),
                                      position: currentPos,
                                    ),
                                  },
                                  osmMarkers: [
                                    osm.Marker(
                                      point: latlong.LatLng(lat, lng),
                                      width: 40,
                                      height: 40,
                                      child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 40),
                                    ),
                                  ],
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
                                      setSheetState(() {
                                        lat = result['position'].latitude;
                                        lng = result['position'].longitude;
                                        addrCtrl.text = result['address'];
                                      });
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AddressField(
                        controller: addrCtrl, 
                        hint: l10n.translate('addressFullHint'), 
                        icon: Icons.location_on_outlined,
                        enabled: false,
                      ),
                    ],
                  );
                },
              ),
              if (!isDesktop)
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                  child: const SizedBox(height: 12),
                ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.translate('save'),
                onTap: () async {
                  if (addrCtrl.text.trim().isNotEmpty) {
                    final success = await auth.updateAddress(Address(
                      id: addr.id,
                      label: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : l10n.translate('address'),
                      address: addrCtrl.text.trim(),
                      lat: lat,
                      lng: lng,
                    ));
                    if (success && ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    }).then((_) {
      if (context.mounted) {
        Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(true);
      }
    });
  }
}
