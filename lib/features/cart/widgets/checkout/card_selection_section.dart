import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../models/payment_card.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import 'checkout_widgets.dart';

class CardSelectionSection extends StatelessWidget {
  final bool showNewCardForm;
  final Function(bool) onToggleNewCard;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final Function(PaymentProvider, PaymentCard) onDeleteCard;
  final LocalizationProvider l10n;

  const CardSelectionSection({
    super.key,
    required this.showNewCardForm,
    required this.onToggleNewCard,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.onDeleteCard,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, payment, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (payment.cards.isNotEmpty && !showNewCardForm) ...[
              const SizedBox(height: 10),
              ...payment.cards.map((card) {
                final isSelected = payment.selectedCardId == card.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.credit_card, color: Theme.of(context).colorScheme.onSurface),
                    title: Text('**** **** **** ${card.last4}'),
                    subtitle: Text(card.expiryDate),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => onDeleteCard(payment, card),
                        ),
                        if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onSurface),
                      ],
                    ),
                    onTap: () => payment.selectCard(card.id),
                  ),
                );
              }),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => onToggleNewCard(true),
                  icon: const Icon(Icons.add_card, size: 20),
                  label: const Text('Ավելացնել նոր քարտ', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
            if (payment.cards.isEmpty || showNewCardForm) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Նոր քարտի տվյալներ', style: TextStyle(fontWeight: FontWeight.bold)),
                        if (payment.cards.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => onToggleNewCard(false),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SectionTitle(title: l10n.translate('cardNumber')),
                    TextFormField(
                      controller: cardNumberController,
                      decoration: InputDecoration(
                        hintText: 'XXXX XXXX XXXX XXXX',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => showNewCardForm && (value == null || value.isEmpty) ? l10n.translate('requiredField') : null,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionTitle(title: l10n.translate('expiryDate')),
                              TextFormField(
                                controller: expiryController,
                                decoration: InputDecoration(
                                  hintText: 'MM/YY',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (value) => showNewCardForm && (value == null || value.isEmpty) ? l10n.translate('requiredField') : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionTitle(title: l10n.translate('cvv')),
                              TextFormField(
                                controller: cvvController,
                                decoration: InputDecoration(
                                  hintText: '123',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                validator: (value) => showNewCardForm && (value == null || value.isEmpty) ? l10n.translate('requiredField') : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
