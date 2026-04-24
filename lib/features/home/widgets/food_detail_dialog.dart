import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/models/cart_item.dart';
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
  final TextEditingController _noteController = TextEditingController();

  double get _effectivePrice {
    double price = widget.product.displayPrice;

    // Add variant price if selected
    if (_selectedVariantName != null) {
      final variant = widget.product.variants.firstWhere(
        (v) =>
            v.name.en == _selectedVariantName ||
            v.name.hy == _selectedVariantName ||
            v.name.ru == _selectedVariantName,
      );
      price = variant.price;
    }

    // Add attribute prices
    _selectedAttributes.forEach((attrId, optionName) {
      final attribute = widget.product.attributes.firstWhere(
        (a) => a.id == attrId,
      );
      final option = attribute.options.firstWhere(
        (o) =>
            o == optionName,
      );
    });

    return price;
  }

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      _selectedVariantName =
          widget.product.variants.first.name.hy; // Default to Armenian
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
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
                          child: const Icon(
                            Icons.fastfood,
                            size: 60,
                            color: Colors.white24,
                          ),
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
                                Text(
                                  product.name.getLocalized(lang),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                                if (product.description
                                    .getLocalized(lang)
                                    .isNotEmpty)
                                  Text(
                                    product.description.getLocalized(lang),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${(_effectivePrice * _quantity).toStringAsFixed(0)} ֏',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (product.variants.isNotEmpty) ...[
                      const Text(
                        'Տարբերակներ',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: product.variants.map((variant) {
                          final variantName = variant.name.getLocalized(lang);
                          final isSelected =
                              _selectedVariantName == variantName;
                          return ChoiceChip(
                            label: Text(
                              '$variantName (${variant.price.toStringAsFixed(0)} ֏)',
                            ),
                            selected: isSelected,
                            onSelected: (_) => setState(
                              () => _selectedVariantName = variantName,
                            ),
                            selectedColor: Colors.white,
                            backgroundColor: Colors.black,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Comment Section
                    const Text(
                      'Մեկնաբանություն',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Թողնել մեկնաբանություն...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.black,
                                iconSize: 32,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
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
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    final l10n = Provider.of<LocalizationProvider>(
                      context,
                      listen: false,
                    );
                    final messenger = ScaffoldMessenger.of(context);
                    final cartItemName = product.name.getLocalized(lang);
                    final addedMsg = l10n.translate('addedToCart');

                    final cart = Provider.of<CartProvider>(
                      context,
                      listen: false,
                    );
                    
                    String? selectedVariantId;
                    if (_selectedVariantName != null) {
                      try {
                        final variant = product.variants.firstWhere(
                          (v) => v.name.getLocalized(lang) == _selectedVariantName,
                        );
                        selectedVariantId = variant.id;
                      } catch (_) {}
                    }

                    final attributes = _selectedAttributes.entries.map<CartAttribute>((e) {
                      // e.key is attrId, we might want the localized name instead?
                      // Let's stick to what's available.
                      final attr = product.attributes.firstWhere((a) => a.id == e.key);
                      return CartAttribute(
                        name: attr.name.getLocalized(lang),
                        values: [e.value],
                      );
                    }).toList();

                    cart.addItem(
                      product,
                      variantId: selectedVariantId,
                      variantName: _selectedVariantName,
                      attributes: attributes,
                      unitPrice: _effectivePrice,
                      quantity: _quantity,
                      note: _noteController.text.isNotEmpty ? _noteController.text : null,
                    );

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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '${lang == 'hy' ? 'Ավելացնել' : (lang == 'en' ? 'Add' : 'Добавить')} • ${(_effectivePrice * _quantity).toStringAsFixed(0)} ֏',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
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
