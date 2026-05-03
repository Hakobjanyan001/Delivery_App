import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../models/cart_item.dart';
import '../../home/providers/home_provider.dart';
import '../../../core/models/restaurant_model.dart';
import 'payment_screen.dart';
import '../../../core/providers/main_tabs_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final l10n = context.watch<LocalizationProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomSheet: null,
      body: SafeArea(
        child: cart.items.isEmpty
            ? _buildEmptyState(context, l10n)
            : LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 700;
                  
                  if (isWide) {
                    return GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        constraints.maxWidth > 1200 ? 60 : 24, 
                        24, 
                        constraints.maxWidth > 1200 ? 60 : 24, 
                        40
                      ),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                      ),
                      itemCount: cart.items.length,
                      itemBuilder: (_, index) =>
                          _CartGridItem(item: cart.items[index]),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 40),
                    itemCount: cart.items.length,
                    itemBuilder: (_, index) =>
                        _CartListItem(item: cart.items[index]),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, LocalizationProvider l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.translate('emptyCart'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.translate('emptyCartSubtext') ?? 'Looks like you haven\'t added anything yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                try {
                  context.read<MainTabsController>().switchTo(0);
                } catch (_) {}
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Text(
              l10n.translate('backToHome'),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRID ITEM
// ─────────────────────────────────────────────────────────────────────────────
class _CartGridItem extends StatelessWidget {
  const _CartGridItem({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final lang = context.read<LocalizationProvider>().currentLocale.languageCode;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Expanded(
            flex: 11,
            child: Stack(
              fit: StackFit.expand,
              children: [
                item.product.mainImageUrl.isNotEmpty
                    ? Image.network(
                        item.product.mainImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(context),
                      )
                    : _placeholder(context),
                // Gradient Overlay for readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: const [0, 0.3, 1],
                      ),
                    ),
                  ),
                ),
                // Remove Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: _IconButton(
                    icon: Icons.close_rounded,
                    onTap: () => cart.removeItem(item.uniqueKey),
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    iconColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            flex: 9,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name.getLocalized(lang),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          height: 1.2,
                        ),
                      ),
                      if (_hasDetails(item)) ...[
                        const SizedBox(height: 6),
                        Text(
                          _detailsText(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.45),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.totalPrice.toStringAsFixed(0)} ֏',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      _QuantityControls(item: item),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.fastfood_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      );

  bool _hasDetails(CartItem i) =>
      (i.variantName?.isNotEmpty ?? false) || i.attributes.isNotEmpty;

  String _detailsText(CartItem i) {
    final v = i.variantName ?? '';
    final a = i.attributes
        .map((a) => a.values.join(', '))
        .where((e) => e.isNotEmpty)
        .join(' • ');
    if (v.isNotEmpty && a.isNotEmpty) return '$v • $a';
    return v.isNotEmpty ? v : a;
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: iconColor ?? Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIST ITEM
// ─────────────────────────────────────────────────────────────────────────────
class _CartListItem extends StatelessWidget {
  const _CartListItem({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final lang = context.read<LocalizationProvider>().currentLocale.languageCode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            SizedBox(
              width: 120,
              child: item.product.mainImageUrl.isNotEmpty
                  ? Image.network(
                      item.product.mainImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.product.name.getLocalized(lang),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _IconButton(
                              icon: Icons.close_rounded,
                              onTap: () => cart.removeItem(item.uniqueKey),
                              backgroundColor: Colors.transparent,
                              iconColor: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                        if (_hasDetails(item)) ...[
                          const SizedBox(height: 4),
                          Text(
                            _detailsText(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.45),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.totalPrice.toStringAsFixed(0)} ֏',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        _QuantityControls(item: item),
                      ],
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

  Widget _placeholder(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.fastfood_rounded,
            size: 32,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      );

  bool _hasDetails(CartItem i) =>
      (i.variantName?.isNotEmpty ?? false) || i.attributes.isNotEmpty;

  String _detailsText(CartItem i) {
    final v = i.variantName ?? '';
    final a = i.attributes
        .map((a) => a.values.join(', '))
        .where((e) => e.isNotEmpty)
        .join(' • ');
    if (v.isNotEmpty && a.isNotEmpty) return '$v • $a';
    return v.isNotEmpty ? v : a;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUANTITY CONTROLS — own widget so context.watch is scoped per item
// ─────────────────────────────────────────────────────────────────────────────
class _QuantityControls extends StatelessWidget {
  const _QuantityControls({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: Icons.remove_rounded,
            filled: false,
            onTap: () => cart.decreaseQuantity(item.uniqueKey),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: -0.5,
              ),
            ),
          ),
          _Btn(
            icon: Icons.add_rounded,
            filled: true,
            onTap: () => cart.addItem(
              item.product,
              variantId: item.variantId,
              variantName: item.variantName,
              attributes: item.attributes,
              unitPrice: item.unitPrice,
              note: item.note,
            ),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.filled, required this.onTap});
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: filled ? cs.primary : cs.surface,
          shape: BoxShape.circle,
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? cs.onPrimary : cs.onSurface,
        ),
      ),
    );
  }
}