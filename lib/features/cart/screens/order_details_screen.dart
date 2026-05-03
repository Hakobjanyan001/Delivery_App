import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../models/order_model.dart';
import '../../../core/widgets/universal_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlong;

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 20),
            ),

          ),
        ),
        title: Text(
          'Պատվեր #${order.id.substring(order.id.length - 5)}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 22),
        ),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Timeline ───────────────────────────────────────────
            _buildSectionTitle(context, l10n.translate('status')),
            const SizedBox(height: 16),
            _buildStatusTimeline(context, l10n),

            const SizedBox(height: 40),

            // ── Items List ────────────────────────────────────────────────
            _buildSectionTitle(context, l10n.translate('items')),
            const SizedBox(height: 16),
            _buildItemsCard(context, order, l10n),

            const SizedBox(height: 40),

            // ── Delivery Section ──────────────────────────────────────────
            _buildSectionTitle(context, l10n.translate('delivery')),
            const SizedBox(height: 16),
            _buildDeliveryCard(context, l10n),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {

    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );

  }

  Widget _buildStatusTimeline(BuildContext context, LocalizationProvider l10n) {

    final status = order.status.toLowerCase();
    
    // Define steps
    final steps = [
      {'key': 'pending', 'label': l10n.translate('pending')},
      {'key': 'accepted', 'label': l10n.translate('accepted')},
      {'key': 'preparing', 'label': l10n.translate('preparing')},
      {'key': 'on_way', 'label': l10n.translate('on_the_way')},
      {'key': 'delivered', 'label': l10n.translate('delivered')},
    ];

    int currentStepIndex = steps.indexWhere((s) => s['key'] == status);
    if (status == 'cancelled') currentStepIndex = -1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),

      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final bool isPast = index <= currentStepIndex;
          final bool isCurrent = index == currentStepIndex;
          
          return _buildStatusRow(
            context,
            step['label'] ?? '',
            '', // We don't have exact times for each step yet
            isActive: isPast,
            isFirst: index == 0,
            isLast: index == steps.length - 1,
            isHighlighted: isCurrent,
          );

        }).reversed.toList(),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String time, {required bool isActive, bool isFirst = false, bool isLast = false, bool isHighlighted = false}) {

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.green : (isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                  shape: BoxShape.circle,
                  boxShadow: isHighlighted ? [
                    BoxShadow(color: Colors.green.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)
                  ] : null,
                ),

              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),

                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isHighlighted ? Colors.green : (isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                      fontSize: 16,
                      fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.w700,
                    ),

                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),

                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, OrderModel order, LocalizationProvider l10n) {

    return Consumer<LocalizationProvider>(
      builder: (context, l10n, child) {
        final lang = l10n.currentLocale.languageCode;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
          ),

          child: Column(
            children: [
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.product.name.getLocalized(lang),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 15, fontWeight: FontWeight.w600),

                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${item.quantity.toInt()} ${l10n.translate('portion')}',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 13, fontWeight: FontWeight.bold),

                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${item.totalPrice.toStringAsFixed(0)} ֏',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w900),

                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    if (item.note != null && item.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 0),
                        child: Text(
                          '${l10n.translate('note') ?? 'Մեկնաբանություն'}՝ ${item.note}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),

                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
              Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.translate('total'),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w900),

                  ),
                  Text(
                    '${order.totalAmount.toStringAsFixed(0)} ֏',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w900),

                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliveryCard(BuildContext context, LocalizationProvider l10n) {

    final LatLng deliveryLocation = LatLng(order.latitude ?? 40.8142, order.longitude ?? 44.4842);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: SizedBox(
              height: 200,
              child: UniversalMap(
                initialPosition: deliveryLocation,
                isReadOnly: true,
                googleMarkers: {
                  Marker(
                    markerId: const MarkerId('delivery_location'),
                    position: deliveryLocation,
                  ),
                },
                osmMarkers: [
                  osm.Marker(
                    point: latlong.LatLng(deliveryLocation.latitude, deliveryLocation.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.black, size: 40),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.address,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w900),

                  ),
                ),
                Text(
                  '500֏',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w900),

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
