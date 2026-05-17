import 'package:flutter/material.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import 'checkout_widgets.dart';

class PaymentMethodSection extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onChanged;
  final LocalizationProvider l10n;

  const PaymentMethodSection({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: l10n.translate('paymentMethod')),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Center(child: Text(l10n.translate('cash'))),
                selected: selectedMethod == 'cash',
                onSelected: (selected) => onChanged('cash'),
                selectedColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                checkmarkColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: Center(child: Text(l10n.translate('card'))),
                selected: selectedMethod == 'card',
                onSelected: (selected) => onChanged('card'),
                selectedColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                checkmarkColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
