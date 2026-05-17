import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoor/features/cart/providers/orders_provider.dart';
import 'package:masoor/features/cart/screens/order_details_screen.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import 'package:masoor/features/auth/widgets/profile/profile_common_widgets.dart';

class OrdersView extends StatelessWidget {
  final VoidCallback onBack;

  const OrdersView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context);
    final l10n = Provider.of<LocalizationProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeader(title: l10n.translate('orders'), onBack: onBack),
        Expanded(
          child: ordersProvider.isLoading
              ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)))
              : ordersProvider.orders.isEmpty
                  ? EmptyState(message: l10n.translate('noOrders'), icon: Icons.receipt_long_outlined)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                      itemCount: ordersProvider.orders.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final order = ordersProvider.orders[i];
                        return _buildOrderCard(ctx, order, l10n);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order, LocalizationProvider l10n) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.address,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${order.id.substring(order.id.length - 6)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _getStatusColor(context, order.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusLabel(order.status, l10n),
                style: TextStyle(
                  color: _getStatusColor(context, order.status),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status, LocalizationProvider l10n) {
    final key = status.toLowerCase() == 'on_way' ? 'on_the_way' : status.toLowerCase();
    return l10n.translate(key);
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':   return Colors.orange;
      case 'accepted':  return Colors.blue;
      case 'preparing': return Colors.amber;
      case 'on_way':    return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default:          return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);
    }
  }
}
