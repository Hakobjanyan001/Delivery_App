import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoor/core/models/product_model.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import 'food_detail_mixin.dart';
import 'food_detail_widgets.dart';

class FoodDetailDesktop extends StatefulWidget {
  final ProductModel product;

  const FoodDetailDesktop({super.key, required this.product});

  @override
  State<FoodDetailDesktop> createState() => _FoodDetailDesktopState();
}

class _FoodDetailDesktopState extends State<FoodDetailDesktop> with FoodDetailMixin {
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              Expanded(child: _buildDetailsSection(context, lang)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: 340,
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          product.mainImageUrl.isNotEmpty
              ? Image.network(
                  product.mainImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => imagePlaceholder(context),
                )
              : imagePlaceholder(context),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, String lang) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                  size: 22,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 4, 28, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name.getLocalized(lang),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  if (product.description.getLocalized(lang).isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      product.description.getLocalized(lang),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${product.displayPrice.toStringAsFixed(0)} ֏',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildVariants(lang),
                  _buildNoteField(lang),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06))),
            ),
            child: _buildCta(context, lang),
          ),
        ],
      ),
    );
  }

  Widget _buildVariants(String lang) {
    if (product.variants.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel(context, lang == 'hy' ? 'Տարբերակ' : (lang == 'en' ? 'Size' : 'Размер')),
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
                child: Column(
                  children: [
                    Text(
                      vName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (variant.discountPrice != null && variant.discountPrice! > 0 && variant.discountPrice! != variant.price) ...[
                      Text(
                        '${variant.price.toStringAsFixed(0)} ֏',
                        style: TextStyle(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: isSelected
                              ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.4)
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${variant.discountPrice!.toStringAsFixed(0)} ֏',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.surface
                                  : Colors.orangeAccent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.2) : Colors.orangeAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${(((variant.price - variant.discountPrice!) / variant.price) * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Theme.of(context).colorScheme.surface : Colors.orangeAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        '${variant.price.toStringAsFixed(0)} ֏',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNoteField(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel(context, lang == 'hy' ? 'Մեկնաբանություն' : (lang == 'en' ? 'Note' : 'Комментарий')),
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

  Widget _buildCta(BuildContext ctx, String lang) {
    final totalPrice = (effectivePrice * quantity).toStringAsFixed(0);
    return Row(
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StepperButton(
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
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              StepperButton(
                icon: Icons.add_rounded,
                onTap: () => setState(() => quantity++),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
