import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:masoor/features/cart/providers/orders_provider.dart';
import 'package:masoor/features/cart/providers/address_provider.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import 'package:masoor/features/auth/widgets/profile/profile_common_widgets.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);

    return Row(
      children: [
        Expanded(
          child: Selector<OrdersProvider, ({int count, bool loading})>(
            selector: (_, p) => (count: p.orders.length, loading: p.isLoading),
            builder: (context, data, _) {
              if (data.loading) return const StatCardShimmer();
              return StatCard(
                icon: Icons.shopping_bag_outlined,
                value: data.count.toString(),
                label: l10n.translate('orders'),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Selector<AddressProvider, ({int count, bool loading})>(
            selector: (_, p) => (count: p.addresses.length, loading: p.isLoading),
            builder: (context, data, _) {
              if (data.loading) return const StatCardShimmer();
              return StatCard(
                icon: Icons.location_on_outlined,
                value: data.count.toString(),
                label: l10n.translate('addresses'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class StatCardShimmer extends StatelessWidget {
  const StatCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.grey[200]!,
      highlightColor: isDark ? Colors.white24 : Colors.grey[100]!,
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
