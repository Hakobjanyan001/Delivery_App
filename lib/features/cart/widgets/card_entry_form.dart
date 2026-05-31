import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../providers/payment_provider.dart';
import '../models/payment_card.dart';

class CardEntryForm extends StatefulWidget {
  final bool isDialog;
  const CardEntryForm({super.key, this.isDialog = false});

  @override
  State<CardEntryForm> createState() => _CardEntryFormState();
}

class _CardEntryFormState extends State<CardEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final payment = Provider.of<PaymentProvider>(context, listen: false);
      final newCard = PaymentCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        last4: _cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4),
        brand: _getCardBrand(_cardNumberController.text),
        expiryDate: _expiryController.text,
      );
      payment.addCard(newCard);
      Navigator.pop(context);
    }
  }

  String _getCardBrand(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'MasterCard';
    return 'Generic';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);

    final bottomInset = widget.isDialog ? 0.0 : MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: widget.isDialog
            ? BorderRadius.circular(28)
            : const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isDialog)
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              if (!widget.isDialog) const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.translate('cardDetails'),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  if (widget.isDialog)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white54, size: 16),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Card Number
              _buildTextField(
                controller: _cardNumberController,
                label: l10n.translate('cardNumber'),
                hint: '0000 0000 0000 0000',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                validator: (v) => (v == null || v.replaceAll(' ', '').length < 16) ? l10n.translate('requiredField') : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  // Expiry
                  Expanded(
                    child: _buildTextField(
                      controller: _expiryController,
                      label: l10n.translate('expiryDate'),
                      hint: 'MM/YY',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      validator: (v) => (v == null || v.length < 5) ? l10n.translate('requiredField') : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // CVV
                  Expanded(
                    child: _buildTextField(
                      controller: _cvvController,
                      label: l10n.translate('cvv'),
                      hint: '000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (v) => (v == null || v.length < 3) ? l10n.translate('requiredField') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Cardholder Name
              _buildTextField(
                controller: _nameController,
                label: l10n.translate('cardHolder'),
                hint: 'NAME SURNAME',
                keyboardType: TextInputType.name,
                validator: (v) => (v == null || v.isEmpty) ? l10n.translate('requiredField') : null,
              ),
              const SizedBox(height: 40),

              GestureDetector(
                onTap: _saveCard,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      l10n.translate('save'),
                      style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w900),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white12),
            filled: true,
            fillColor: const Color(0xFF161616),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');
    var newString = '';
    for (var i = 0; i < text.length; i++) {
        newString += text[i];
        if ((i + 1) % 4 == 0 && i + 1 != text.length) newString += ' ';
    }
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    var newString = '';
    for (var i = 0; i < text.length; i++) {
        newString += text[i];
        if (i == 1 && text.length > 2) newString += '/';
    }
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
