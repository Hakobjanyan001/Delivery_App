import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoor/core/models/product_model.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import '../../../cart/providers/cart_provider.dart';

mixin FoodDetailMixin<T extends StatefulWidget> on State<T> {
  late ProductModel product;
  String? selectedVariantName;
  int quantity = 1;
  bool isLoading = false;
  final TextEditingController noteController = TextEditingController();

  void initProduct(ProductModel p) {
    product = p;
    if (p.variants.isNotEmpty) {
      selectedVariantName = p.variants.first.name.hy;
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  double get effectivePrice {
    if (selectedVariantName != null && product.variants.isNotEmpty) {
      try {
        final v = product.variants.firstWhere(
          (v) =>
              v.name.en == selectedVariantName ||
              v.name.hy == selectedVariantName ||
              v.name.ru == selectedVariantName,
        );
        return v.displayPrice;
      } catch (_) {}
    }
    return product.displayPrice;
  }

  Future<void> addToCart(BuildContext ctx) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final cart = Provider.of<CartProvider>(ctx, listen: false);
    final l10n = Provider.of<LocalizationProvider>(ctx, listen: false);
    final lang = l10n.currentLocale.languageCode;
    final messenger = ScaffoldMessenger.of(ctx);
    final name = product.name.getLocalized(lang);

    String? variantId;
    if (selectedVariantName != null) {
      try {
        variantId = product.variants.firstWhere(
          (v) =>
              v.name.en == selectedVariantName ||
              v.name.hy == selectedVariantName ||
              v.name.ru == selectedVariantName,
        ).id;
      } catch (_) {}
    }

    final nav = Navigator.of(ctx);

    try {
      await cart.addItem(
        product,
        variantId: variantId,
        variantName: selectedVariantName,
        attributes: const [],
        unitPrice: effectivePrice,
        quantity: quantity,
        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      );

      if (mounted) nav.pop();

      messenger.showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$name ${l10n.translate('addedToCart')}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          ),
        ]),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      messenger.showSnackBar(SnackBar(
        content: Text(e.toString(), style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onError)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        backgroundColor: Theme.of(context).colorScheme.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  Widget sectionLabel(BuildContext context, String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.4,
        ),
      );

  Widget imagePlaceholder(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: Icon(Icons.fastfood_rounded, size: 56, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)),
        ),
      );
}
