import 'package:flutter/material.dart';
import '../providers/payment_provider.dart';
import '../widgets/card_entry_form.dart';

class PaymentMethodSelector extends StatelessWidget {
  final PaymentProvider payment;

  const PaymentMethodSelector({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMethodItem(
          context,
          type: PaymentMethodType.cash,
          icon: Icons.payments_outlined,
          title: 'Կանխիկ',
        ),
        const SizedBox(height: 12),
        _buildMethodItem(
          context,
          type: PaymentMethodType.idram,
          icon: Icons.account_balance_wallet_outlined,
          title: 'iDram',
        ),
        const SizedBox(height: 12),
        _buildMethodItem(
          context,
          type: PaymentMethodType.card,
          icon: Icons.credit_card_outlined,
          title: 'Քարտ',
        ),
      ],
    );
  }

  Widget _buildMethodItem(
    BuildContext context, {
    required PaymentMethodType type,
    required IconData icon,
    required String title,
  }) {
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
          color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.surface, size: 20),
          ],
        ),
      ),
    );
  }
}
