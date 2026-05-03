import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../core/localization/localization_provider.dart';

// ─── entry point ────────────────────────────────────────────────────────────

void showFoodDetail(BuildContext context, ProductModel product) {
  final isDesktop = MediaQuery.of(context).size.width >= 900;

  if (isDesktop) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      routeSettings: const RouteSettings(name: 'FoodDetail'),
      builder: (_) => _FoodDetailDesktop(product: product),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: 'FoodDetail'),
      builder: (_) => FoodDetailDialog(product: product),
    );
  }
}

// ─── shared state mixin ──────────────────────────────────────────────────────

mixin _FoodDetailMixin<T extends StatefulWidget> on State<T> {
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
        return v.price;
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

  // ── shared widgets ──────────────────────────────────────────────────────

  Widget buildVariants(String lang) {
    if (product.variants.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(lang == 'hy' ? 'Տարբերակ' : (lang == 'en' ? 'Size' : 'Размер')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: product.variants.map((variant) {
            final vName = variant.name.getLocalized(lang);
            final isSelected = selectedVariantName == variant.name.en ||
                selectedVariantName == variant.name.hy ||
                selectedVariantName == variant.name.ru;
            return GestureDetector(
              onTap: () => setState(() => selectedVariantName = variant.name.hy),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),

                child: Column(children: [
                  Text(vName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface,
                      )),

                  Text('${variant.price.toStringAsFixed(0)} ֏',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                      )),

                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildNoteField(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(lang == 'hy' ? 'Մեկնաբանություն' : (lang == 'en' ? 'Note' : 'Комментарий')),
        const SizedBox(height: 8),
        TextField(
          controller: noteController,
          maxLines: 3,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),

          decoration: InputDecoration(
            hintText: lang == 'hy'
                ? 'Թողնել մեկնաբանություն...'
                : (lang == 'en' ? 'Leave a note...' : 'Оставить комментарий...'),
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25)),

            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,

            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            ),

          ),
        ),
      ],
    );
  }

  Widget buildCta(BuildContext ctx, String lang) {
    final totalPrice = (effectivePrice * quantity).toStringAsFixed(0);
    return Row(children: [
      // stepper
      Container(
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
        ),

        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _StepperButton(
            icon: quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            onTap: () {
              if (quantity == 1) {
                Navigator.pop(ctx);
              } else {
                setState(() => quantity--);
              }
            },
          ),
          SizedBox(
            width: 36,
            child: Text('$quantity',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),

          ),
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: () => setState(() => quantity++),
          ),
        ]),
      ),
      const SizedBox(width: 10),
      // add button
      Expanded(
        child: GestureDetector(
          onTap: isLoading ? null : () => addToCart(ctx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 52,
            decoration: BoxDecoration(
              color: isLoading ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7) : Theme.of(context).colorScheme.onSurface,
              borderRadius: BorderRadius.circular(14),
            ),

            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Theme.of(context).colorScheme.surface),
                    )

                    : Text(
                      '${lang == 'hy' ? 'Ավելացնել' : (lang == 'en' ? 'Add' : 'Добавить')}  •  $totalPrice ֏',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.surface),
                    ),

            ),
          ),
        ),
      ),
    ]);
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.4,
        ),

      );

  Widget imagePlaceholder() => Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: Icon(Icons.fastfood_rounded, size: 56, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)),
        ),
      );

}

// ─── mobile bottom sheet ─────────────────────────────────────────────────────

class FoodDetailDialog extends StatefulWidget {
  final ProductModel product;
  const FoodDetailDialog({super.key, required this.product});

  @override
  State<FoodDetailDialog> createState() => _FoodDetailDialogState();
}

class _FoodDetailDialogState extends State<FoodDetailDialog> with _FoodDetailMixin {
  @override
  void initState() {
    super.initState();
    initProduct(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),

          child: Column(children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),

              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  // hero image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: product.mainImageUrl.isNotEmpty
                          ? Image.network(product.mainImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => imagePlaceholder())
                          : imagePlaceholder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // name + price
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(product.name.getLocalized(lang),
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.2)),

                        if (product.description.getLocalized(lang).isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(product.description.getLocalized(lang),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  height: 1.4)),

                        ],
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Text('${product.displayPrice.toStringAsFixed(0)} ֏',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),

                  ]),
                  const SizedBox(height: 20),
                  buildVariants(lang),
                  buildNoteField(lang),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // CTA
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(ctx).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06))),
              ),

              child: buildCta(ctx, lang),
            ),
          ]),
        );
      },
    );
  }
}

// ─── desktop center dialog ───────────────────────────────────────────────────

class _FoodDetailDesktop extends StatefulWidget {
  final ProductModel product;
  const _FoodDetailDesktop({required this.product});

  @override
  State<_FoodDetailDesktop> createState() => _FoodDetailDesktopState();
}

class _FoodDetailDesktopState extends State<_FoodDetailDesktop> with _FoodDetailMixin {
  @override
  void initState() {
    super.initState();
    initProduct(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 580),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ── left: image ──────────────────────────────────
            Container(
              width: 340,
              color: Theme.of(context).colorScheme.surface,

              child: Stack(fit: StackFit.expand, children: [
                product.mainImageUrl.isNotEmpty
                    ? Image.network(product.mainImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => imagePlaceholder())
                    : imagePlaceholder(),
                // subtle gradient so left edge blends into dialog bg
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.transparent, Theme.of(context).colorScheme.surface.withValues(alpha: 0.15)],

                      ),
                    ),
                  ),
                ),
              ]),
            ),

            // ── right: details ───────────────────────────────
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surface,

                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // close button row
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), size: 22),

                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),

                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),

                  // scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 4, 28, 16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // name
                        Text(product.name.getLocalized(lang),
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.2)),

                        if (product.description.getLocalized(lang).isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(product.description.getLocalized(lang),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  height: 1.5)),

                        ],
                        const SizedBox(height: 10),
                        // price badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Text('${product.displayPrice.toStringAsFixed(0)} ֏',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),

                        ),
                        const SizedBox(height: 20),
                        buildVariants(lang),
                        buildNoteField(lang),
                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),

                  // CTA
                  Container(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06))),
                    ),

                    child: buildCta(context, lang),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── shared stepper button ───────────────────────────────────────────────────

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 52,
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 20),

      ),
    );
  }
}
