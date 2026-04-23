import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/food_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

class FoodDetailDialog extends StatefulWidget {
  final FoodItem food;

  const FoodDetailDialog({super.key, required this.food});

  @override
  State<FoodDetailDialog> createState() => _FoodDetailDialogState();
}

class _FoodDetailDialogState extends State<FoodDetailDialog> {
  late String _selectedSize;
  final Set<String> _selectedOptions = {};
  int _quantity = 1;
  bool _isPieceMode = false;

  // Price multiplier per size position (index 0 = base, 1 = mid, 2 = large)
  static const List<double> _multipliers = [1.0, 1.35, 1.7];

  double get _effectivePrice {
    final sizes = widget.food.sizes;
    if (sizes.isEmpty) return widget.food.price;
    final idx = sizes.indexOf(_selectedSize).clamp(0, sizes.length - 1);
    
    // Check if in piece mode (only for Large size)
    if (_isPieceMode && _selectedSize == 'Մեծ' && widget.food.slicePrice != null) {
      return widget.food.slicePrice!;
    }

    // Check if custom prices are defined for this food item
    if (widget.food.sizePrices != null && idx < widget.food.sizePrices!.length) {
      return widget.food.sizePrices![idx];
    }
    
    // Fallback to multipliers if no custom prices
    final multiplierIdx = idx.clamp(0, _multipliers.length - 1);
    return widget.food.price * _multipliers[multiplierIdx];
  }

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.food.sizes.isNotEmpty ? widget.food.sizes[0] : 'Standard';
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
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
              // Drag handle
              const SizedBox(height: 10),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Food image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        food.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Icon(Icons.fastfood, size: 60, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name & Price Box
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
                            child: Text(food.localizedName(lang),
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${(_effectivePrice * _quantity).toStringAsFixed(0)} ֏',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                              if (_selectedSize != food.sizes.first)
                                Text(
                                  '${l10n.translate('total')}: ${food.price.toStringAsFixed(0)} ֏',
                                  style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.5), decoration: TextDecoration.lineThrough),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Size Selection
                    if (food.sizes.isNotEmpty) ...[
                      const Text('Չափս', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: food.sizes.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final size = entry.value;
                          final isSelected = _selectedSize == size;
                          final multiplier = _multipliers[idx.clamp(0, _multipliers.length - 1)];
                          final sizePrice = (food.price * multiplier).toStringAsFixed(0);
                          return ChoiceChip(
                            label: Text('$size  $sizePrice ֏'),
                            selected: isSelected,
                            onSelected: (_) => setState(() {
                              _selectedSize = size;
                              if (size != 'Մեծ') _isPieceMode = false;
                            }),
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

                    // Options / Attributes
                    if (food.availableOptions.isNotEmpty) ...[
                      const Text('Հատկանիշներ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 10),
                      ...food.availableOptions.map((option) {
                        final isSelected = _selectedOptions.contains(option);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CheckboxListTile(
                            title: Text(option, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                            value: isSelected,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            fillColor: WidgetStateProperty.all(Colors.black),
                            checkColor: Colors.white,
                            side: const BorderSide(color: Colors.black, width: 2),
                            checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedOptions.add(option);
                                } else {
                                  _selectedOptions.remove(option);
                                }
                              });
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
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

              // Add to Cart button
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
                child: ElevatedButton(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final l10n = Provider.of<LocalizationProvider>(context, listen: false);
                    final messenger = ScaffoldMessenger.of(context);
                    final cartItemName = food.localizedName(l10n.currentLocale.languageCode);
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
                        food,
                        selectedSize: _isPieceMode ? '$_selectedSize (Կտոր)' : _selectedSize,
                        selectedOptions: _selectedOptions.toList(),
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
