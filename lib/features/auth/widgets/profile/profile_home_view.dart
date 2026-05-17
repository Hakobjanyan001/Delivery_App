import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoor/features/auth/providers/auth_provider.dart';
import 'package:masoor/features/cart/providers/payment_provider.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import 'package:masoor/core/providers/theme_provider.dart';
import 'package:masoor/core/localization/widgets/language_selector.dart';
import 'package:masoor/features/auth/widgets/profile/profile_common_widgets.dart';
import 'package:masoor/features/auth/widgets/profile/profile_card.dart';
import 'package:masoor/features/auth/widgets/profile/profile_stats_row.dart';
import 'package:masoor/features/auth/widgets/profile/profile_logout_button.dart';
import 'package:masoor/core/constants/app_constants.dart';

class ProfileHomeView extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onEditProfile;
  final VoidCallback onViewOrders;
  final VoidCallback onViewAddresses;
  final VoidCallback onShowPaymentSelection;
  final VoidCallback onShowSupportOptions;

  const ProfileHomeView({
    super.key,
    required this.isDesktop,
    required this.onEditProfile,
    required this.onViewOrders,
    required this.onViewAddresses,
    required this.onShowPaymentSelection,
    required this.onShowSupportOptions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, isDesktop ? 32 : 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card
          ProfileCard(onEdit: onEditProfile),
          const SizedBox(height: AppConstants.sectionSpacing),

          // Quick stats row
          const ProfileStatsRow(),
          const SizedBox(height: AppConstants.sectionSpacing),

          // My account section
          SectionLabel(text: l10n.translate('orders')),
          const SizedBox(height: 10),
          MenuCard(children: [
            MenuRow(
              icon: Icons.receipt_long_outlined,
              label: l10n.translate('orders'),
              onTap: onViewOrders,
            ),
            _buildDivider(context),
            MenuRow(
              icon: Icons.location_on_outlined,
              label: l10n.translate('myAddresses'),
              onTap: onViewAddresses,
            ),
          ]),

          const SizedBox(height: AppConstants.sectionSpacing),

          // Settings section
          SectionLabel(text: l10n.translate('settings')),
          const SizedBox(height: 10),
          MenuCard(children: [
            Selector<PaymentProvider, ({PaymentMethodType type, dynamic card})>(
              selector: (_, p) => (type: p.selectedMethodType, card: p.selectedCard),
              builder: (context, paymentData, _) {
                return MenuRow(
                  icon: Icons.credit_card_outlined,
                  label: l10n.translate('paymentMethods'),
                  subtitle: _getPaymentLabel(paymentData, l10n),
                  onTap: onShowPaymentSelection,
                );
              },
            ),
            _buildDivider(context),
            MenuRow(
              icon: Icons.language_outlined,
              label: l10n.translate('language'),
              trailing: LanguageSelector(color: Theme.of(context).colorScheme.onSurface),
            ),
            _buildDivider(context),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return MenuRow(
                  icon: themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  label: themeProvider.isDarkMode ? l10n.translate('darkMode') : l10n.translate('lightMode'),
                  trailing: Switch.adaptive(
                    value: themeProvider.isDarkMode,
                    onChanged: (val) => themeProvider.toggleTheme(),
                    activeColor: Theme.of(context).colorScheme.surface,
                    activeTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                );
              },
            ),
            _buildDivider(context),
            MenuRow(
              icon: Icons.headset_mic_outlined,
              label: l10n.translate('support'),
              onTap: onShowSupportOptions,
            ),
          ]),

          const SizedBox(height: AppConstants.sectionSpacing),

          // Logout
          const ProfileLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 0,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
    );
  }

  String _getPaymentLabel(({PaymentMethodType type, dynamic card}) data, LocalizationProvider l10n) {
    if (data.type == PaymentMethodType.card && data.card != null) {
      return '•••• ${data.card.last4}';
    } else if (data.type == PaymentMethodType.idram) {
      return l10n.translate('idram');
    }
    return l10n.translate('cash');
  }
}
