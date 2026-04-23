import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

class FoodDetailDialog extends StatefulWidget {
  final ProductModel product;

  const FoodDetailDialog({super.key, required this.product});

  @override
  State<FoodDetailDialog> createState() => _FoodDetailDialogState();
}

class _FoodDetailDialogState extends State<FoodDetailDialog> {
  String? _selectedVariantName;
  final Map<String, String> _selectedAttributes = {};
  int _quantity = 1;

  double get _effectivePrice {
    double price = widget.product.displayPrice;
    
    // Add variant price if selected
    if (_selectedVariantName != null) {
      final variant = widget.product.variants.firstWhere((v) => v.name.en == _selectedVariantName || v.name.hy == _selectedVariantName || v.name.ru == _selectedVariantName);
      price = variant.price;
    }

    // Add attribute prices
    _selectedAttributes.forEach((attrId, optionName) {
      final attribute = widget.product.attributes.firstWhere((a) => a.id == attrId);
      final option = attribute.options.firstWhere((o) => o.name.en == optionName || o.name.hy == optionName || o.name.ru == optionName);
      price += option.price;
    });

    return price;
  }

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      _selectedVariantName = widget.product.variants.first.name.hy; // Default to Armenian
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        product.mainImageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: const Color(0xFF1A1A1A),
                          child: const Icon(Icons.fastfood, size: 60, color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name.getLocalized(lang),
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
                                if (product.description.getLocalized(lang).isNotEmpty)
                                  Text(product.description.getLocalized(lang),
                                      style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.6))),
                              ],
                            ),
                          ),
                          Text(
                            '${(_effectivePrice * _quantity).toStringAsFixed(0)} ֏',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (product.variants.isNotEmpty) ...[
                      const Text('Տարբերակներ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: product.variants.map((variant) {
                          final variantName = variant.name.getLocalized(lang);
                          final isSelected = _selectedVariantName == variantName;
                          return ChoiceChip(
                            label: Text('$variantName (${variant.price.toStringAsFixed(0)} ֏)'),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedVariantName = variantName),
                            selectedColor: Colors.white,
                            backgroundColor: Colors.black,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Refined Slice Option (Only for Large)
                      if (_selectedSize == 'Մեծ' && food.slicePrice != null)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CheckboxListTile(
                            title: const Text('Վաճառել կտորով', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                            subtitle: Text('Մեկ կտորի գինը՝ ${food.slicePrice!.toStringAsFixed(0)} ֏', style: const TextStyle(color: Colors.black54)),
                            value: _isPieceMode,
                            onChanged: (val) => setState(() => _isPieceMode = val ?? false),
                            fillColor: WidgetStateProperty.all(Colors.black),
                            checkColor: Colors.white,
                            side: const BorderSide(color: Colors.black, width: 2),
                            checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],

                    if (product.attributes.isNotEmpty) ...[
                      const Text('Հատկանիշներ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 10),
                      ...product.attributes.map((attr) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(attr.name.getLocalized(lang), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: attr.options.map((opt) {
                                final optName = opt.name.getLocalized(lang);
                                final isSelected = _selectedAttributes[attr.id] == optName;
                                return ChoiceChip(
                                  label: Text('$optName ${opt.price > 0 ? '(+${opt.price.toStringAsFixed(0)} ֏)' : ''}'),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedAttributes[attr.id] = optName;
                                      } else {
                                        _selectedAttributes.remove(attr.id);
                                      }
                                    });
                                  },
                                  selectedColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.black,
                                iconSize: 32,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('$_quantity',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
                              ),
                              IconButton(
                                onPressed: () => setState(() => _quantity++),
                                icon: const Icon(Icons.add_circle_outline),
                                color: Colors.black,
                                iconSize: 32,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
                child: ElevatedButton(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final l10n = Provider.of<LocalizationProvider>(context, listen: false);
                    final messenger = ScaffoldMessenger.of(context);
                    final cartItemName = product.name.getLocalized(lang);
                    final addedMsg = l10n.translate('addedToCart');
                    
                    if (!authProvider.isAuthenticated) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'LoginScreen'),
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                      return;
                    }

                    final cart = Provider.of<CartProvider>(context, listen: false);
                    for (int i = 0; i < _quantity; i++) {
                      cart.addItem(
                        product,
                        selectedSize: _selectedVariantName ?? 'Standard',
                        selectedOptions: _selectedAttributes.values.toList(),
                        effectiveUnitPrice: _effectivePrice,
                      );
                    }
                    
                    Navigator.pop(context);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('$cartItemName $addedMsg'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    '${lang == 'hy' ? 'Ավելացնել' : (lang == 'en' ? 'Add' : 'Добавить')} • ${(_effectivePrice * _quantity).toStringAsFixed(0)} ֏',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
