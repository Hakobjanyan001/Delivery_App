import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/utils/geocoding_helper.dart';
import '../providers/cart_provider.dart';
import '../providers/payment_provider.dart';
import '../models/payment_card.dart';
import '../widgets/location_picker_dialog.dart';
import 'payment_webview_screen.dart';
import '../../../core/services/payment_service.dart';
import '../../support/widgets/support_hub_sheet.dart';
import '../providers/orders_provider.dart';
import '../providers/address_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'cash'; // 'cash' or 'card'
  final _phoneController = TextEditingController();
  final _cashController = TextEditingController();
  
  // Card details
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  double _change = 0.0;
  bool _showNewCardForm = false;
  bool _isProcessingPayment = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _cashController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _calculateChange(double total, String value) {
    if (value.isEmpty) {
      setState(() => _change = 0.0);
      return;
    }
    final cash = double.tryParse(value) ?? 0.0;
    setState(() {
      _change = cash >= total ? cash - total : 0.0;
    });
  }

  Future<void> _fetchLocationForAddress(LocalizationProvider l10n, TextEditingController addrController, Function(bool) setFetching) async {
    setFetching(true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(l10n.translate('locationPermissionDenied'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(l10n.translate('locationPermissionDenied'));
      }

      Position position = await Geolocator.getCurrentPosition();
      
      if (!mounted) return;
      
      // Open Map Picker Dialog
      final LatLng? pickedLocation = await showDialog<LatLng>(
        context: context,
        builder: (ctx) => LocationPickerDialog(
          initialPosition: LatLng(position.latitude, position.longitude),
        ),
      );

      if (pickedLocation != null) {
        final address = await GeocodingHelper.getAddressFromCoordinates(
          pickedLocation.latitude,
          pickedLocation.longitude,
        );
        addrController.text = address;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('locationError'))),
      );
    } finally {
      setFetching(false);
    }
  }

  void _showAddAddressDialog(BuildContext context, AddressProvider provider, LocalizationProvider l10n) {
    final titleController = TextEditingController();
    final addrController = TextEditingController();
    bool isFetching = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          title: const Text('Ավելացնել նոր հասցե'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Անվանում (օր․ Տուն)', hintText: 'Տուն'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addrController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Հասցե',
                    suffixIcon: isFetching
                        ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                        : IconButton(
                            icon: const Icon(Icons.my_location, color: Colors.blue),
                            onPressed: () => _fetchLocationForAddress(l10n, addrController, (val) => setStateBuilder(() => isFetching = val)),
                          ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Չեղարկել')),
            ElevatedButton(
              onPressed: () {
                if (addrController.text.isNotEmpty) {
                  provider.addAddress(titleController.text, addrController.text);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Պահպանել'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOrder(BuildContext context, CartProvider cart, LocalizationProvider l10n) async {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    if (addressProvider.selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Խնդրում ենք ընտրել կամ ավելացնել առաքման հասցե')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    if (_paymentMethod == 'cash') {
      final cash = double.tryParse(_cashController.text) ?? 0.0;
      if (cash < cart.totalAmount) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translate('insufficientCash'))),
        );
        return;
      }
      if (context.mounted) Provider.of<OrdersProvider>(context, listen: false).addOrder(cart.items, cart.totalAmount);
      _showSuccessDialog(context, cart, l10n);
    } else {
      // Payment Card Flow
      String? cardId;
      if (!_showNewCardForm && paymentProvider.selectedCard != null) {
        cardId = paymentProvider.selectedCard!.id;
      }

      setState(() => _isProcessingPayment = true);

      try {
        final paymentUrl = await PaymentService.initiatePayment(
          amount: cart.totalAmount,
          currency: 'AMD',
          cardId: cardId,
        );

        if (paymentUrl != null && context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          final nav = Navigator.of(context);
          
          final success = await nav.push<bool>(
            MaterialPageRoute(
              builder: (_) => PaymentWebViewScreen(url: paymentUrl),
            ),
          );

          if (success == true && context.mounted) {
            if (_showNewCardForm) {
              await paymentProvider.addCard(PaymentCard(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                last4: _cardNumberController.text.substring(_cardNumberController.text.length - 4),
                brand: 'Visa',
                expiryDate: _expiryController.text,
              ));
            }
            if (context.mounted) {
              Provider.of<OrdersProvider>(context, listen: false).addOrder(cart.items, cart.totalAmount);
              _showSuccessDialog(context, cart, l10n);
            }
          } else if (context.mounted) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Վճարումը չհաջողվեց')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Կապի սխալ վճարման համակարգի հետ')),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessingPayment = false);
      }
    }
  }

  void _showSuccessDialog(BuildContext context, CartProvider cart, LocalizationProvider l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('orderSuccess')),
        content: Text(l10n.translate('orderMessage')),
        actions: [
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.of(ctx).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('OK', style: TextStyle(color: Colors.blue[900])),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final l10n = Provider.of<LocalizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('checkout'), style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.blue[900]),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(l10n.translate('phone')),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: '+374 XX XXXXXX',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty ? l10n.translate('requiredField') : null,
                ),
                const SizedBox(height: 20),
                
                _buildSectionTitle(l10n.translate('address')),
                Consumer<AddressProvider>(
                  builder: (context, addrProv, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (addrProv.addresses.isNotEmpty) ...[
                          ...addrProv.addresses.map((addr) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: addrProv.selectedAddressId == addr.id ? Colors.blue[50] : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: addrProv.selectedAddressId == addr.id ? Colors.blue[900]! : Colors.grey[300]!),
                                ),
                                child: ListTile(
                                  leading: Icon(Icons.location_on, color: addrProv.selectedAddressId == addr.id ? Colors.blue[900] : Colors.grey),
                                  title: Text(addr.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(addr.address),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                        onPressed: () => addrProv.removeAddress(addr.id),
                                      ),
                                      if (addrProv.selectedAddressId == addr.id) const Icon(Icons.check_circle, color: Colors.blue),
                                    ],
                                  ),
                                  onTap: () => addrProv.selectAddress(addr.id),
                                ),
                              )),
                          TextButton.icon(
                            onPressed: () => _showAddAddressDialog(context, addrProv, l10n),
                            icon: const Icon(Icons.add),
                            label: const Text('Ավելացնել նոր հասցե'),
                          ),
                        ] else ...[
                          InkWell(
                            onTap: () => _showAddAddressDialog(context, addrProv, l10n),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.grey[600]),
                                  const SizedBox(width: 10),
                                  Text('Ավելացրեք հասցե', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                                  const Spacer(),
                                  const Icon(Icons.add_location_alt, color: Colors.blue),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                _buildSectionTitle(l10n.translate('paymentMethod')),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(l10n.translate('cash'))),
                        selected: _paymentMethod == 'cash',
                        onSelected: (selected) => setState(() => _paymentMethod = 'cash'),
                        selectedColor: Colors.blue[900]?.withValues(alpha: 0.2),
                        checkmarkColor: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(l10n.translate('card'))),
                        selected: _paymentMethod == 'card',
                        onSelected: (selected) => setState(() => _paymentMethod = 'card'),
                        selectedColor: Colors.blue[900]?.withValues(alpha: 0.2),
                        checkmarkColor: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_paymentMethod == 'card') ...[
                  Consumer<PaymentProvider>(
                    builder: (context, payment, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (payment.cards.isNotEmpty && !_showNewCardForm) ...[
                            const SizedBox(height: 10),
                            ...payment.cards.map((card) => _buildCardItem(card, payment)),
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => setState(() => _showNewCardForm = true),
                                icon: const Icon(Icons.add_card, size: 20),
                                label: const Text('Ավելացնել նոր քարտ', style: TextStyle(fontSize: 14)),
                              ),
                            ),
                          ],
                          if (payment.cards.isEmpty || _showNewCardForm) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50]?.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.blue[100]!),
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
                                          onPressed: () => setState(() => _showNewCardForm = false),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildSectionTitle(l10n.translate('cardNumber')),
                                  TextFormField(
                                    controller: _cardNumberController,
                                    decoration: InputDecoration(
                                      hintText: 'XXXX XXXX XXXX XXXX',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) => _paymentMethod == 'card' && _showNewCardForm && (value == null || value.isEmpty) ? l10n.translate('requiredField') : null,
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionTitle(l10n.translate('expiryDate')),
                                            TextFormField(
                                              controller: _expiryController,
                                              decoration: InputDecoration(
                                                hintText: 'MM/YY',
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              validator: (value) => _paymentMethod == 'card' && _showNewCardForm && (value == null || value.isEmpty) ? l10n.translate('requiredField') : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionTitle(l10n.translate('cvv')),
                                            TextFormField(
                                              controller: _cvvController,
                                              decoration: InputDecoration(
                                                hintText: '123',
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              keyboardType: TextInputType.number,
                                              obscureText: true,
                                              validator: (value) => _paymentMethod == 'card' && _showNewCardForm && (value == null || value.isEmpty) ? l10n.translate('requiredField') : null,
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
                  ),
                ]
                else ...[
                   _buildSectionTitle(l10n.translate('cashAmount')),
                   TextFormField(
                    controller: _cashController,
                    decoration: InputDecoration(
                      hintText: '0 ֏',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixText: '֏',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _calculateChange(cart.totalAmount, value),
                    validator: (value) => _paymentMethod == 'cash' && (value == null || value.isEmpty) ? l10n.translate('requiredField') : null,
                  ),
                  const SizedBox(height: 10),
                  if (_change > 0)
                    Text(
                      '${l10n.translate('changeNeeded')}: ${_change.toStringAsFixed(0)} ֏',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700]),
                    ),
                ],

                const SizedBox(height: 40),
                
                // Order Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.translate('total'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '${cart.totalAmount.toStringAsFixed(0)} ֏',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isProcessingPayment ? null : () => _submitOrder(context, cart, l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isProcessingPayment 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(l10n.translate('confirmOrder'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const SupportHubSheet(),
          );
        },
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.support_agent, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildCardItem(PaymentCard card, PaymentProvider provider) {
    final isSelected = provider.selectedCardId == card.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? Colors.blue[900]! : Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Icon(Icons.credit_card, color: Colors.blue[900]),
        title: Text('**** **** **** ${card.last4}'),
        subtitle: Text(card.expiryDate),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => _confirmDeleteCard(context, provider, card),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
        onTap: () => provider.selectCard(card.id),
      ),
    );
  }

  void _confirmDeleteCard(BuildContext context, PaymentProvider provider, PaymentCard card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ջնջել քարտը'),
        content: Text('Ցանկանո՞ւմ եք ջնջել ${card.last4}-ով ավարտվող քարտը։'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Չեղարկել')),
          TextButton(
            onPressed: () {
              provider.removeCard(card.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Ջնջել', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
