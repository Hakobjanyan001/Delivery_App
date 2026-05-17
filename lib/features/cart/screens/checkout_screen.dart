import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

import '../widgets/checkout/address_selection_section.dart';
import '../widgets/checkout/payment_method_section.dart';
import '../widgets/checkout/card_selection_section.dart';
import '../widgets/checkout/order_summary_section.dart';
import '../widgets/checkout/checkout_widgets.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      _checkAndCalculateDistance(cartProvider, addressProvider);
    });
  }

  void _checkAndCalculateDistance(CartProvider cartProvider, AddressProvider addressProvider) {
    final selected = addressProvider.selectedAddress;
    if (selected != null && selected.latitude != null && cartProvider.restaurantLat != null) {
      if (cartProvider.distanceInKm == 0 && !cartProvider.isCalculatingDelivery) {
        cartProvider.updateDeliveryPriceByDistance(selected.latitude!, selected.longitude!);
      }
    }
  }

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

  void _showAddAddressDialog(BuildContext context, AddressProvider provider, LocalizationProvider l10n) {
    final titleController = TextEditingController();
    final addrController = TextEditingController();
    LatLng? pickedCoords;
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
                            icon: Icon(Icons.my_location, color: Theme.of(context).colorScheme.onSurface),
                            onPressed: () async {
                              setStateBuilder(() => isFetching = true);
                              try {
                                Position position = await Geolocator.getCurrentPosition();
                                if (!context.mounted) return;
                                final LatLng? picked = await showDialog<LatLng>(
                                  context: context,
                                  builder: (ctx) => LocationPickerDialog(
                                    initialPosition: LatLng(position.latitude, position.longitude),
                                  ),
                                );
                                if (picked != null) {
                                  pickedCoords = picked;
                                  final address = await GeocodingHelper.getAddressFromCoordinates(picked.latitude, picked.longitude);
                                  addrController.text = address;
                                }
                              } catch (e) {
                                debugPrint('Location Error: $e');
                              } finally {
                                setStateBuilder(() => isFetching = false);
                              }
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Չեղարկել')),
            ElevatedButton(
              onPressed: () async {
                if (addrController.text.isNotEmpty) {
                  provider.addAddress(
                    titleController.text, 
                    addrController.text,
                    lat: pickedCoords?.latitude,
                    lng: pickedCoords?.longitude,
                  );
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
      if (cash < cart.finalAmount) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translate('insufficientCash'))),
        );
        return;
      }
      if (context.mounted) {
        final order = await Provider.of<OrdersProvider>(context, listen: false).addOrder(
          cart.items, 
          cart.finalAmount,
          address: addressProvider.selectedAddress!.toJson(),
          phone: _phoneController.text,
          paymentMethod: _paymentMethod,
        );
        
        if (order != null && context.mounted) {
          _showSuccessDialog(context, cart, l10n);
        }
      }
    } else {
      // Payment Card Flow
      String? cardId;
      if (!_showNewCardForm && paymentProvider.selectedCard != null) {
        cardId = paymentProvider.selectedCard!.id;
      }

      setState(() => _isProcessingPayment = true);

      try {
        final paymentUrl = await PaymentService.initiatePayment(
          amount: cart.finalAmount,
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
              await Provider.of<OrdersProvider>(context, listen: false).addOrder(
                cart.items, 
                cart.finalAmount,
                address: addressProvider.selectedAddress!.toJson(),
                phone: _phoneController.text,
                paymentMethod: _paymentMethod,
              );
              _showSuccessDialog(context, cart, l10n);
            }
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
            child: const Text('OK'),
          )
        ],
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LocalizationProvider>();
    final cartProv = Provider.of<CartProvider>(context, listen: false);
    final addrProv = Provider.of<AddressProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndCalculateDistance(cartProv, addrProv));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('checkout'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title: l10n.translate('phone')),
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
                
                SectionTitle(title: l10n.translate('address')),
                AddressSelectionSection(
                  onAddAddress: (provider) => _showAddAddressDialog(context, provider, l10n),
                ),
                const SizedBox(height: 20),

                PaymentMethodSection(
                  selectedMethod: _paymentMethod,
                  onChanged: (method) => setState(() => _paymentMethod = method),
                  l10n: l10n,
                ),
                const SizedBox(height: 20),

                if (_paymentMethod == 'card') ...[
                  CardSelectionSection(
                    showNewCardForm: _showNewCardForm,
                    onToggleNewCard: (val) => setState(() => _showNewCardForm = val),
                    cardNumberController: _cardNumberController,
                    expiryController: _expiryController,
                    cvvController: _cvvController,
                    onDeleteCard: (provider, card) => _confirmDeleteCard(context, provider, card),
                    l10n: l10n,
                  ),
                ] else ...[
                  SectionTitle(title: l10n.translate('cashAmount')),
                  TextFormField(
                    controller: _cashController,
                    decoration: InputDecoration(
                      hintText: '0 ֏',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixText: '֏',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final total = context.read<CartProvider>().finalAmount;
                      _calculateChange(total, value);
                    },
                    validator: (value) => _paymentMethod == 'cash' && (value == null || value.isEmpty) ? l10n.translate('requiredField') : null,
                  ),
                  if (_change > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${l10n.translate('changeNeeded')}: ${_change.toStringAsFixed(0)} ֏',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700]),
                    ),
                  ],
                ],

                const SizedBox(height: 40),
                OrderSummarySection(l10n: l10n),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isProcessingPayment ? null : () => _submitOrder(context, context.read<CartProvider>(), l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isProcessingPayment 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.surface, strokeWidth: 2))
                    : Text(l10n.translate('confirmOrder'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const SupportHubSheet(),
        ),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        child: Icon(Icons.support_agent, color: Theme.of(context).colorScheme.surface),
      ),
    );
  }
}
