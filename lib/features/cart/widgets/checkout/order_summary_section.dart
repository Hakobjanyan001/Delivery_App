import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'package:masoor/core/localization/localization_provider.dart';

class OrderSummarySection extends StatelessWidget {
  final LocalizationProvider l10n;

  const OrderSummarySection({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProv, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.translate('subtotal') ?? 'Ապրանքներ', style: const TextStyle(fontSize: 16)),
                  Text('${cartProv.totalAmount.toStringAsFixed(0)} ֏', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(l10n.translate('delivery') ?? 'Առաքում', style: const TextStyle(fontSize: 16)),
                      if (cartProv.distanceInKm > 0)
                        Text(
                          ' (${cartProv.distanceInKm.toStringAsFixed(1)} կմ)',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                    ],
                  ),
                  if (cartProv.isCalculatingDelivery)
                    Text('Հաշվարկվում է...', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary))
                  else
                    Text('${cartProv.deliveryPrice.toStringAsFixed(0)} ֏', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.translate('total') ?? 'Ընդամենը',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${cartProv.finalAmount.toStringAsFixed(0)} ֏',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
