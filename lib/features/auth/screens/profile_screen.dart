import 'package:flutter/material.dart';
import 'package:masoor/features/auth/models/address_model.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../cart/providers/payment_provider.dart';
import '../../cart/providers/orders_provider.dart';
import '../../cart/providers/address_provider.dart';
import '../../cart/screens/order_details_screen.dart';
import '../../cart/widgets/card_entry_form.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/localization/widgets/language_selector.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/guest_auth_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../support/screens/support_chat_screen.dart';
import '../../../core/providers/main_tabs_controller.dart';
import '../../../core/providers/theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlong;
import '../../../core/widgets/universal_map.dart';
import '../../../core/widgets/location_picker_modal.dart';


// Active view within the profile screen
enum _View { home, editProfile, orders, addresses }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  _View _view = _View.home;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _nameController.text = auth.userName ?? '';
      _emailController.text = auth.email ?? '';
      _phoneController.text = auth.phone ?? '';
      Provider.of<OrdersProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final l10n = Provider.of<LocalizationProvider>(context);

    if (!auth.isAuthenticated) return const GuestAuthView();

    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final content = _buildCurrentView(context, auth, l10n, isDesktop);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: content,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: content,
    );

  }

  Widget _buildCurrentView(
    BuildContext context,
    AuthProvider auth,
    LocalizationProvider l10n,
    bool isDesktop,
  ) {
    final payment = Provider.of<PaymentProvider>(context);
    final ordersProvider = Provider.of<OrdersProvider>(context);

    switch (_view) {
      case _View.home:
        return _buildHome(context, auth, payment, ordersProvider, l10n, isDesktop);
      case _View.editProfile:
        return _buildEditProfile(context, auth, l10n);
      case _View.orders:
        return _buildOrdersView(context, ordersProvider, l10n);
      case _View.addresses:
        return _buildAddressesView(context, auth, l10n);
    }
  }

  // ── Home ─────────────────────────────────────────────────────────────────

  Widget _buildHome(
    BuildContext context,
    AuthProvider auth,
    PaymentProvider payment,
    OrdersProvider ordersProvider,
    LocalizationProvider l10n,
    bool isDesktop,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(

      padding: EdgeInsets.fromLTRB(20, isDesktop ? 32 : 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card
          _buildProfileCard(auth, l10n),
          const SizedBox(height: 28),

          // Quick stats row
          _buildStatsRow(ordersProvider),
          const SizedBox(height: 28),

          // My account section
          _buildSectionLabel(l10n.translate('orders')),
          const SizedBox(height: 10),
          _buildMenuCard([
            _buildMenuRow(
              icon: Icons.receipt_long_outlined,
              label: l10n.translate('orders'),
              onTap: () => setState(() => _view = _View.orders),
            ),
            _buildDivider(),
            _buildMenuRow(
              icon: Icons.location_on_outlined,
              label: l10n.translate('myAddresses'),
              onTap: () => setState(() => _view = _View.addresses),
            ),
          ]),

          const SizedBox(height: 28),

          // Settings section
          _buildSectionLabel(l10n.translate('settings')),
          const SizedBox(height: 10),
          _buildMenuCard([
            _buildMenuRow(
              icon: Icons.credit_card_outlined,
              label: l10n.translate('paymentMethods'),
              subtitle: _currentPaymentLabel(payment, l10n),
              onTap: () => _showPaymentSelection(context, payment, l10n),
            ),
            _buildDivider(),
            _buildMenuRow(
               icon: Icons.language_outlined,
              label: l10n.translate('language'),
              trailing: LanguageSelector(color: Theme.of(context).colorScheme.onSurface),
            ),

            _buildDivider(),
            _buildMenuRow(
              icon: themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              label: themeProvider.isDarkMode ? l10n.translate('darkMode') : l10n.translate('lightMode'),
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: (val) => themeProvider.toggleTheme(),
                activeColor: Theme.of(context).colorScheme.surface,
                activeTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),

              ),
            ),
            _buildDivider(),
            _buildMenuRow(
              icon: Icons.headset_mic_outlined,
              label: l10n.translate('support'),
              onTap: () => _showSupportOptions(context, l10n),
            ),
          ]),


          const SizedBox(height: 28),

          // Logout
          _buildLogoutButton(auth, l10n),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AuthProvider auth, LocalizationProvider l10n) {
    return GestureDetector(
      onTap: () => setState(() => _view = _View.editProfile),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07)),
        ),

        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),

              child: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), size: 28),
            ),

            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.userName?.isNotEmpty == true ? auth.userName! : l10n.translate('user'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    auth.phone ?? '+374 -- -- -- --',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                l10n.translate('editShort'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(OrdersProvider ordersProvider) {
    final orderCount = ordersProvider.orders.length;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.shopping_bag_outlined,
            value: orderCount.toString(),
            label: l10n(context).translate('orders'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Consumer<AddressProvider>(
            builder: (ctx, ap, _) => _buildStatCard(
              icon: Icons.location_on_outlined,
              value: ap.addresses.length.toString(),
              label: l10n(context).translate('addresses'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
      ),

      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 22),
          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),

      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
      ),

      child: Column(children: children),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String label,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), size: 18),
            ),

            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  ],
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25), size: 20)
                    : const SizedBox.shrink()),

          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 0,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
    );

  }

  Widget _buildLogoutButton(AuthProvider auth, LocalizationProvider l10n) {
    return GestureDetector(
      onTap: auth.logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
            const SizedBox(width: 10),
            Text(
              l10n.translate('logout'),
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit Profile ──────────────────────────────────────────────────────────

  Widget _buildEditProfile(
    BuildContext context,
    AuthProvider auth,
    LocalizationProvider l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubHeader(l10n.translate('personalData')),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _nameController,
                  hintText: l10n.translate('name'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _emailController,
                  hintText: l10n.translate('email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _phoneController,
                  hintText: l10n.translate('phone'),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await auth.updateProfile(
                      name: _nameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                    );
                    if (success && mounted) {
                      setState(() => _view = _View.home);
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.translate('profileUpdated'))),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(40),
                    ),

                      child: Center(
                        child: auth.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.primary, strokeWidth: 2),
                              )

                          : Text(
                              l10n.translate('save'),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Orders view ───────────────────────────────────────────────────────────

  Widget _buildOrdersView(
    BuildContext context,
    OrdersProvider ordersProvider,
    LocalizationProvider l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubHeader(l10n.translate('orders')),
        Expanded(
          child: ordersProvider.isLoading
              ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)))
              : ordersProvider.orders.isEmpty

                  ? _buildEmptyState(l10n.translate('noOrders'), Icons.receipt_long_outlined)
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
                color: _getStatusColor(order.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusLabel(order.status, l10n),
                style: TextStyle(
                  color: _getStatusColor(order.status),
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

  // ── Addresses view ────────────────────────────────────────────────────────

  Widget _buildAddressesView(
    BuildContext context,
    AuthProvider auth,
    LocalizationProvider l10n,
  ) {
    final addresses = auth.user?.addresses ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubHeader(l10n.translate('myAddresses'), action: GestureDetector(
          onTap: () => _showAddNewAddressDialog(context, auth, l10n),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+ ${l10n.translate('add')}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),

          ),
        )),
        Expanded(
          child: addresses.isEmpty
              ? _buildEmptyState(l10n.translate('noAddresses'), Icons.location_on_outlined)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  itemCount: addresses.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final addr = addresses[i];
                    return Container(
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
                            child: Icon(Icons.location_on_outlined,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 20),
                          ),

                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    addr.label != null && addr.label!.isNotEmpty ? addr.label! : 'Հասցե',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                if (addr.address != null && addr.address!.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    addr.address!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                                      fontSize: 12,
                                    ),

                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                _showAddressEditInline(ctx, auth, addr, l10n),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.edit_outlined,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 16),
                            ),
                          ),

                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Shared sub-screen header ──────────────────────────────────────────────

  Widget _buildSubHeader(String title, {Widget? action}) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _view = _View.home),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 20),
              ),

            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

            ),
            if (action != null) action,
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), size: 56),

          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 15),

          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  LocalizationProvider l10n(BuildContext context) =>
      Provider.of<LocalizationProvider>(context, listen: false);

  String _currentPaymentLabel(PaymentProvider payment, LocalizationProvider l10n) {
    if (payment.selectedMethodType == PaymentMethodType.card &&
        payment.selectedCard != null) {
      return '•••• ${payment.selectedCard!.last4}';
    } else if (payment.selectedMethodType == PaymentMethodType.idram) {
      return l10n.translate('idram');
    }
    return l10n.translate('cash');
  }

  String _getStatusLabel(String status, LocalizationProvider l10n) {
    final key = status.toLowerCase() == 'on_way' ? 'on_the_way' : status.toLowerCase();
    return l10n.translate(key);
  }

  Color _getStatusColor(String status) {
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

  // ── Responsive sheet helper ───────────────────────────────────────────────

  // Shows a bottom sheet on mobile, a centered dialog on desktop.
  Future<void> _showSheet(
    BuildContext context, {
    required Widget Function(BuildContext ctx, bool isDesktop) builder,
    bool scrollControlled = false,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    if (isDesktop) {
      return showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: builder(ctx, true),
          ),
        ),
      );
    } else {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: scrollControlled,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        builder: (ctx) => builder(ctx, false),
      );
    }
  }

  // ── Payment selection ─────────────────────────────────────────────────────

  void _showPaymentSelection(
    BuildContext context,
    PaymentProvider payment,
    LocalizationProvider l10n,
  ) {
    // Hide nav bar
    Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(false);

    _showSheet(context, builder: (ctx, isDesktop) {
      return _SheetContainer(
        isDesktop: isDesktop,
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHeader(
                title: l10n.translate('paymentMethod'),
                isDesktop: isDesktop,
                onClose: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 20),
              _PaymentOption(
                icon: Icons.payments_outlined,
                label: l10n.translate('cash'),
                description: l10n.translate('cashDescription'),
                isSelected: payment.selectedMethodType == PaymentMethodType.cash,
                onTap: () {
                  payment.setMethodType(PaymentMethodType.cash);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 10),
              _PaymentOption(
                icon: Icons.account_balance_wallet_outlined,
                label: 'iDram',
                description: l10n.translate('idramDescription'),
                isSelected: payment.selectedMethodType == PaymentMethodType.idram,
                onTap: () {
                  payment.setMethodType(PaymentMethodType.idram);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 10),
              _PaymentOption(
                icon: Icons.credit_card_outlined,
                label: l10n.translate('card'),
                description: payment.cards.isNotEmpty
                    ? '•••• ${payment.cards.first.last4}'
                    : l10n.translate('addCardDescription'),
                isSelected: payment.selectedMethodType == PaymentMethodType.card,
                onTap: () {
                  if (payment.cards.isEmpty) {
                    Navigator.pop(ctx);
                    _showCardEntry(context);
                  } else {
                    payment.setMethodType(PaymentMethodType.card);
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }).then((_) {
      if (context.mounted) {
        Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(true);
      }
    });
  }

  void _showCardEntry(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    if (isDesktop) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: const CardEntryForm(isDialog: true),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        builder: (_) => const CardEntryForm(isDialog: false),
      );
    }
  }

  // ── Support ───────────────────────────────────────────────────────────────

  void _showSupportOptions(BuildContext context, LocalizationProvider l10n) {
    // Hide nav bar
    Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(false);

    _showSheet(context, builder: (ctx, isDesktop) {
      return _SheetContainer(
        isDesktop: isDesktop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(
              title: l10n.translate('support'),
              isDesktop: isDesktop,
              onClose: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('howCanWeHelp'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 13,
              ),

            ),
            const SizedBox(height: 20),
            _SupportOption(
              icon: Icons.phone_outlined,
              iconBg: Colors.green.withValues(alpha: 0.12),
              iconColor: Colors.greenAccent,
              title: '+374 60 515515',
              subtitle: l10n.translate('callSupport'),
              onTap: () async {
                final uri = Uri.parse('tel:+37460515515');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            _SupportOption(
              icon: Icons.chat_bubble_outline_rounded,
              iconBg: Colors.blue.withValues(alpha: 0.12),
              iconColor: Colors.lightBlueAccent,
              title: l10n.translate('onlineChat'),
              subtitle: l10n.translate('chatDescription'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'SupportChatScreen'),
                    builder: (_) => const SupportChatScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }).then((_) {
      if (context.mounted) {
        Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(true);
      }
    });
  }

  // ── Address forms ─────────────────────────────────────────────────────────

  void _showAddNewAddressDialog(BuildContext context, AuthProvider auth, LocalizationProvider l10n) {
    final titleCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    double lat = 40.8142; 
    double lng = 44.4842;

    // Hide nav bar
    Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(false);

    _showSheet(context, scrollControlled: true, builder: (ctx, isDesktop) {
      return _SheetContainer(
        isDesktop: isDesktop,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHeader(
                title: l10n.translate('newAddress'),
                isDesktop: isDesktop,
                onClose: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 20),
              _AddressField(controller: titleCtrl, hint: l10n.translate('addressNameHint'), icon: Icons.label_outline),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (ctx, setSheetState) {
                  final currentPos = LatLng(lat, lng);
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 160,
                          child: Stack(
                            children: [
                              IgnorePointer(
                                child: UniversalMap(
                                  key: ValueKey('preview_${lat}_${lng}'),
                                  initialPosition: currentPos,
                                  isReadOnly: true,
                                  googleMarkers: {
                                    Marker(
                                      markerId: const MarkerId('preview'),
                                      position: currentPos,
                                    ),
                                  },
                                  osmMarkers: [
                                    osm.Marker(
                                      point: latlong.LatLng(lat, lng),
                                      width: 40,
                                      height: 40,
                                      child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 40),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LocationPickerModal(
                                          initialPosition: currentPos,
                                        ),
                                      ),
                                    );
                                    if (result != null) {
                                      setSheetState(() {
                                        lat = result['position'].latitude;
                                        lng = result['position'].longitude;
                                        addrCtrl.text = result['address'];
                                      });
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AddressField(controller: addrCtrl, hint: l10n.translate('addressFullHint'), icon: Icons.location_on_outlined, enabled: false,),
                    ],
                  );
                },
              ),
              if (!isDesktop)
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                  child: const SizedBox(height: 12),
                ),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: l10n.translate('save'),
                onTap: () async {
                  if (addrCtrl.text.trim().isNotEmpty) {
                    final success = await auth.addAddress(Address(
                      label: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : l10n.translate('address'),
                      address: addrCtrl.text.trim(),
                      lat: lat,
                      lng: lng,
                    ));
                    if (success && ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    }).then((_) {
      if (context.mounted) {
        Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(true);
      }
    });
  }

  void _showAddressEditInline(
      BuildContext context, AuthProvider auth, dynamic addr, LocalizationProvider l10n) {
    final titleCtrl = TextEditingController(text: addr.label);
    final addrCtrl = TextEditingController(text: addr.address);
    double lat = addr.lat ?? 40.8142;
    double lng = addr.lng ?? 44.4842;

    // Hide nav bar
    Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(false);

    _showSheet(context, scrollControlled: true, builder: (ctx, isDesktop) {
      return _SheetContainer(
        isDesktop: isDesktop,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SheetHeader(
                      title: l10n.translate('editAddress'),
                      isDesktop: isDesktop,
                      onClose: () => Navigator.pop(ctx),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (addr.id != null) {
                        final success = await auth.deleteAddress(addr.id!);
                        if (success && ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _AddressField(controller: titleCtrl, hint: l10n.translate('addressNameHint'), icon: Icons.label_outline),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (ctx, setSheetState) {
                  final currentPos = LatLng(lat, lng);
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 160,
                          child: Stack(
                            children: [
                              IgnorePointer(
                                child: UniversalMap(
                                  key: ValueKey('edit_preview_${lat}_${lng}'),
                                  initialPosition: currentPos,
                                  isReadOnly: true,
                                  googleMarkers: {
                                    Marker(
                                      markerId: const MarkerId('preview'),
                                      position: currentPos,
                                    ),
                                  },
                                  osmMarkers: [
                                    osm.Marker(
                                      point: latlong.LatLng(lat, lng),
                                      width: 40,
                                      height: 40,
                                      child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 40),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LocationPickerModal(
                                          initialPosition: currentPos,
                                        ),
                                      ),
                                    );
                                    if (result != null) {
                                      setSheetState(() {
                                        lat = result['position'].latitude;
                                        lng = result['position'].longitude;
                                        addrCtrl.text = result['address'];
                                      });
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AddressField(
                        controller: addrCtrl, 
                        hint: l10n.translate('addressFullHint'), 
                        icon: Icons.location_on_outlined,
                        enabled: false,
                      ),
                    ],
                  );
                },
              ),
              if (!isDesktop)
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                  child: const SizedBox(height: 12),
                ),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: l10n.translate('save'),
                onTap: () async {
                  if (addrCtrl.text.trim().isNotEmpty) {
                    final success = await auth.updateAddress(Address(
                      id: addr.id,
                      label: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : l10n.translate('address'),
                      address: addrCtrl.text.trim(),
                      lat: lat,
                      lng: lng,
                    ));
                    if (success && ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    }).then((_) {
      if (context.mounted) {
        Provider.of<MainTabsController>(context, listen: false).setNavBarVisibility(true);
      }
    });
  }
}

// ── Sheet chrome widgets ──────────────────────────────────────────────────────

class _SheetContainer extends StatelessWidget {
  final Widget child;
  final bool isDesktop;

  const _SheetContainer({required this.child, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isDesktop
          ? const EdgeInsets.fromLTRB(24, 20, 24, 24)
          : const EdgeInsets.fromLTRB(24, 20, 24, 110),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: isDesktop
            ? BorderRadius.circular(28)
            : const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
      ),

      child: child,
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final bool isDesktop;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.title,
    required this.isDesktop,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDesktop) ...[
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),

          ),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),

              ),
            ),
            if (isDesktop)
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), size: 16),
                ),

              ),
          ],
        ),
      ],
    );
  }
}

// ── Reusable option tiles ─────────────────────────────────────────────────────

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.08)
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), size: 20),

            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),

                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.surface.withOpacity(0.55)
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                      fontSize: 12,
                    ),

                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface, size: 13)
                  : null,

            ),
          ],
        ),
      ),
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
        ),

        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w800)),

                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 12)),

                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), size: 14),

          ],
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool enabled;

  const _AddressField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
      ),

      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: enabled ? 0.3 : 0.1), size: 18),

          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: enabled ? 1.0 : 0.4), 
                fontSize: 15, 
                fontWeight: FontWeight.w600
              ),

              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25), fontSize: 14),

                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
          borderRadius: BorderRadius.circular(18),
        ),

        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.surface, fontSize: 16, fontWeight: FontWeight.w900)),

        ),
      ),
    );
  }
}
