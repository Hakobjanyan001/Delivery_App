import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context);
    final orders = ordersProvider.orders;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          'Իմ պատվերները',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                'Պատվերներ դեռ չկան',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 16,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Active Orders ─────────────────────────────────────
                  _buildSectionHeader('Ակտիվ պատվերնններ'),
                  const SizedBox(height: 12),
                  Builder(builder: (_) {
                    final active = orders
                        .where((o) => o.status != 'Կատարված' && o.status != 'Delivered')
                        .toList();
                    if (active.isEmpty) {
                      return _buildEmptyState('Ակտիվ պատվերնններ չկան');
                    }
                    return Column(
                      children: active.asMap().entries.map((e) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: e.key < active.length - 1 ? 10 : 0),
                          child: _buildDetailedOrderCard(e.value),
                        );
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 32),

                  // ── Completed Orders ──────────────────────────────────
                  _buildSectionHeader('Կատարված պատվերնններ'),
                  const SizedBox(height: 12),
                  Builder(builder: (_) {
                    final done = orders
                        .where((o) => o.status == 'Կատարված' || o.status == 'Delivered')
                        .toList();
                    if (done.isEmpty) {
                      return _buildEmptyState('Կատարված պատվերնններ չկան');
                    }
                    return Column(
                      children: done.asMap().entries.map((e) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: e.key < done.length - 1 ? 10 : 0),
                          child: _buildDetailedOrderCard(e.value),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDetailedOrderCard(dynamic order) {
    final itemNames = order.items
        .map<String>((it) => '${it.foodItem.name} ×${it.quantity}')
        .join('\n');
    final shortId = order.id.length > 6
        ? order.id.substring(order.id.length - 6)
        : order.id;
    final date =
        '${order.date.day.toString().padLeft(2, '0')}.${order.date.month.toString().padLeft(2, '0')}.${order.date.year}  ${order.date.hour.toString().padLeft(2, '0')}:${order.date.minute.toString().padLeft(2, '0')}';

    final bool isActive =
        order.status != 'Կատարված' && order.status != 'Delivered';
    final Color statusColor =
        isActive ? Colors.white : Colors.greenAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10100F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '# $shortId',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            itemNames.isNotEmpty ? itemNames : 'Պատվեր',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              Text(
                '${order.totalAmount.toStringAsFixed(0)} ֏',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF10100F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
