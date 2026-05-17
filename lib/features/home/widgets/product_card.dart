import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product_model.dart';
import '../../../core/localization/localization_provider.dart';
import '../../cart/providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String lang;
  final LocalizationProvider l10n;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.lang,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: isDesktop ? 160 : 170,
              width: double.infinity,
              child: product.mainImageUrl.isNotEmpty
                  ? Image.network(
                      product.mainImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, err, stack) => _FallbackImage(),
                    )
                  : _FallbackImage(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.getLocalized(lang),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Consumer<CartProvider>(
                      builder: (_, cart, child) {
                        final qty = cart.getItemQuantity(product.id);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              qty > 0 ? '$qty x' : '1 ${l10n.translate('portion')}',
                              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12),
                            ),
                            Text(
                              '${product.displayPrice.toStringAsFixed(0)}֏',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Consumer<CartProvider>(
                      builder: (_, cart, child) {
                        final qty = cart.getItemQuantity(product.id);
                        if (qty > 0) {
                          return _QuantityRow(
                            quantity: qty,
                            onDecrement: () => cart.removeOneItemByProductId(product.id),
                            onIncrement: () => cart.addItem(product),
                          );
                        }
                        return _AddButton(
                          label: l10n.translate('add'),
                          onTap: onTap,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Icon(
          Icons.fastfood,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          size: 40,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.surface, offset: const Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityRow({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _PillBtn(label: '-', filled: false, onTap: onDecrement)),
        const SizedBox(width: 8),
        _PillBtn(label: '$quantity', filled: false, onTap: null, fixedWidth: 40),
        const SizedBox(width: 8),
        Expanded(child: _PillBtn(label: '+', filled: true, onTap: onIncrement)),
      ],
    );
  }
}

class _PillBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback? onTap;
  final double? fixedWidth;

  const _PillBtn({
    required this.label,
    required this.filled,
    required this.onTap,
    this.fixedWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fixedWidth,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? theme.colorScheme.onSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: filled ? null : Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(color: theme.colorScheme.surface, offset: const Offset(0, 4), blurRadius: 0),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: filled ? theme.colorScheme.surface : theme.colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
