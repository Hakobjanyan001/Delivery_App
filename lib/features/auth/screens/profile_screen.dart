import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import '../providers/auth_provider.dart';
import '../../cart/providers/payment_provider.dart';
import '../../cart/providers/orders_provider.dart';
import '../../cart/screens/order_details_screen.dart';
import '../../cart/widgets/card_entry_form.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/localization/widgets/language_selector.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../support/screens/support_chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  String _activeSection = 'data';
  late TabController _tabController;
  late PageController _pageController;

  final List<String> _sections = ['data', 'orders', 'settings'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController(initialPage: 0);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeSection = _sections[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(AuthProvider auth) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      auth.updateProfile(imagePath: image.path);
    }
  }

  void _showPaymentSelection(
    BuildContext context,
    PaymentProvider payment,
    LocalizationProvider l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.translate('paymentMethod'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            _buildPaymentTypeItem(
              context,
              payment,
              l10n,
              PaymentMethodType.cash,
              Icons.payments_outlined,
              l10n.translate('cash'),
            ),
            const SizedBox(height: 12),
            _buildPaymentTypeItem(
              context,
              payment,
              l10n,
              PaymentMethodType.idram,
              Icons.account_balance_wallet_outlined,
              l10n.translate('idram'),
            ),
            const SizedBox(height: 12),
            _buildPaymentTypeItem(
              context,
              payment,
              l10n,
              PaymentMethodType.card,
              Icons.credit_card,
              l10n.translate('card'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeItem(
    BuildContext context,
    PaymentProvider payment,
    LocalizationProvider l10n,
    PaymentMethodType type,
    IconData icon,
    String title,
  ) {
    final isSelected = payment.selectedMethodType == type;
    return GestureDetector(
      onTap: () {
        if (type == PaymentMethodType.card && payment.cards.isEmpty) {
          Navigator.pop(context);
          _showCardEntry(context);
        } else {
          payment.setMethodType(type);
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.black, size: 24),
          ],
        ),
      ),
    );
  }

  void _showCardEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => const CardEntryForm(),
    );
  }

  void _showSupportOptions(BuildContext context, LocalizationProvider l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Աջակցության կենտրոն',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            _buildSupportOption(
              icon: Icons.phone_outlined,
              title: '+374 60 515515',
              subtitle: 'Զանգահարել աջակցության կենտրոն',
              onTap: () async {
                final Uri url = Uri.parse('tel:+37460515515');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildSupportOption(
              icon: Icons.chat_bubble_outline,
              title: 'Օպերատորի հետ չատ',
              subtitle: 'Գրեք մեր մասնագետին',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportChatScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final payment = Provider.of<PaymentProvider>(context);
    final ordersProvider = Provider.of<OrdersProvider>(context);
    final l10n = Provider.of<LocalizationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: !auth.isAuthenticated
            ? _buildGuestView(context, l10n)
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 20,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Custom AppBar ───────────────────────────────────────
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (_activeSection == 'edit_profile') {
                                      setState(() => _activeSection = 'data');
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF161616),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _activeSection == 'edit_profile'
                                            ? l10n.translate('editProfile')
                                            : (_activeSection == 'data'
                                                  ? l10n.translate(
                                                      'personalAccount',
                                                    )
                                                  : (_activeSection == 'orders'
                                                        ? l10n.translate(
                                                            'orders',
                                                          )
                                                        : l10n.translate(
                                                            'settings',
                                                          ))),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      if (_activeSection == 'data')
                                        GestureDetector(
                                          onTap: () => _showSupportOptions(
                                            context,
                                            l10n,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.headset_mic_outlined,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            if (_activeSection != 'edit_profile') ...[
                              // ── Tab Navigation ──────────────────────────────────────
                              _buildNavigationButtons(l10n),
                              const SizedBox(height: 32),

                              // Swipable Content Area
                              SizedBox(
                                height:
                                    constraints.maxHeight -
                                    250, // Estimate space
                                child: PageView(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _activeSection = _sections[index];
                                      _tabController.animateTo(index);
                                    });
                                  },
                                  children: [
                                    // Page 1: Personal Data Dashboard
                                    SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildArtagersProfileCard(auth, l10n),
                                          const SizedBox(height: 36),
                                          _buildSectionHeader(
                                            l10n.translate('activeOrders'),
                                            trailing: _buildSeeAllButton(l10n),
                                          ),
                                          const SizedBox(height: 16),
                                          _buildOrdersPreview(
                                            context,
                                            ordersProvider,
                                            l10n,
                                          ),
                                          const SizedBox(height: 36),
                                          _buildSectionHeader(
                                            l10n.translate('settings'),
                                          ),
                                          const SizedBox(height: 16),
                                          _buildSettingsPreview(payment, l10n),
                                        ],
                                      ),
                                    ),
                                    // Page 2: Full Orders List
                                    SingleChildScrollView(
                                      child: _buildFullOrdersList(
                                        ordersProvider,
                                        l10n,
                                      ),
                                    ),
                                    // Page 3: Full Settings
                                    SingleChildScrollView(
                                      child: _buildSettingsContent(
                                        payment,
                                        l10n,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              _buildEditProfileView(auth, l10n),
                            ],

                            const Expanded(child: SizedBox(height: 40)),

                            // Logout Button
                            if (_activeSection != 'edit_profile')
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    auth.logout();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        settings: const RouteSettings(
                                          name: 'LoginScreen',
                                        ),
                                        builder: (context) => const LoginScreen(
                                          isCheckoutFlow: false,
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF161616),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      l10n.translate('logout'),
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // ── Tab Navigation Builder ─────────────────────────────────────────────
  Widget _buildNavigationButtons(LocalizationProvider l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildNavTab('data', l10n.translate('personalData')),
          const SizedBox(width: 12),
          _buildNavTab('orders', l10n.translate('orders')),
          const SizedBox(width: 12),
          _buildNavTab('settings', l10n.translate('settings')),
        ],
      ),
    );
  }

  Widget _buildNavTab(String id, String label) {
    final index = _sections.indexOf(id);
    final isActive = _activeSection == id;
    return GestureDetector(
      onTap: () {
        setState(() => _activeSection = id);
        _tabController.animateTo(index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── Profile Card ───────────────────────────────────────────────────────
  Widget _buildArtagersProfileCard(
    AuthProvider auth,
    LocalizationProvider l10n,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _activeSection = 'edit_profile'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFF1A1A1A),
              backgroundImage: null,
              child: const Icon(Icons.person, color: Colors.white24, size: 40),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.userName ?? 'User Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    auth.phone ?? '+374 -- -- -- --',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileView(AuthProvider auth, LocalizationProvider l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF1A1A1A),
                backgroundImage: null,
                child: const Icon(
                  Icons.person,
                  color: Colors.white24,
                  size: 50,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickImage(auth),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildEditItem(
          l10n.translate('name'),
          auth.userName ?? '',
          (v) => auth.updateProfile(name: v),
          l10n,
        ),
        const SizedBox(height: 16),
        _buildEditItem(
          l10n.translate('phone'),
          auth.phone ?? '',
          (v) => auth.updateProfile(phone: v),
          l10n,
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => setState(() => _activeSection = 'data'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                l10n.translate('save'),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditItem(
    String label,
    String value,
    Function(String) onEdit,
    LocalizationProvider l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10100F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? l10n.translate('enter') : value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white38, size: 20),
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              _showEditField(auth, label, value, onEdit, l10n);
            },
          ),
        ],
      ),
    );
  }

  void _showEditField(
    AuthProvider auth,
    String field,
    String currentValue,
    Function(String) onSave,
    LocalizationProvider l10n,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${l10n.translate('editField')} $field',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '${l10n.translate('enterNew')} $field',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.translate('cancel'),
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: Text(
              l10n.translate('save'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing],
      ],
    );
  }

  Widget _buildSeeAllButton(LocalizationProvider l10n) {
    return GestureDetector(
      onTap: () => setState(() => _activeSection = 'orders'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          l10n.translate('seeAll'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ── Dashboard Previews ─────────────────────────────────────────────────
  Widget _buildOrdersPreview(
    BuildContext context,
    OrdersProvider provider,
    LocalizationProvider l10n,
  ) {
    if (provider.orders.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          l10n.translate('emptyCart'),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        ),
      );
    }
    return Column(
      children: [
        _buildPreviewOrderCard(
          context,
          provider,
          provider.orders.first,
          isTop: true,
          isBottom: provider.orders.length == 1,
        ),
        if (provider.orders.length > 1)
          _buildPreviewOrderCard(
            context,
            provider,
            provider.orders[1],
            isBottom: true,
          ),
      ],
    );
  }

  Widget _buildPreviewOrderCard(
    BuildContext context,
    OrdersProvider provider,
    dynamic order, {
    bool isTop = false,
    bool isBottom = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.only(
            topLeft: isTop ? const Radius.circular(24) : Radius.zero,
            topRight: isTop ? const Radius.circular(24) : Radius.zero,
            bottomLeft: isBottom ? const Radius.circular(24) : Radius.zero,
            bottomRight: isBottom ? const Radius.circular(24) : Radius.zero,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.address,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(order.id.length - 6)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  order.status,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPreview(
    PaymentProvider payment,
    LocalizationProvider l10n,
  ) {
    String currentPaymentLabel = l10n.translate('cash');
    if (payment.selectedMethodType == PaymentMethodType.card &&
        payment.selectedCard != null) {
      currentPaymentLabel = '•••• ${payment.selectedCard!.last4}';
    } else if (payment.selectedMethodType == PaymentMethodType.idram) {
      currentPaymentLabel = l10n.translate('idram');
    }

    return Column(
      children: [
        _buildLanguageButton(l10n),
        const SizedBox(height: 12),
        _buildListButton(
          l10n.translate('paymentMethods'),
          subtitle: currentPaymentLabel,
          onTap: () => _showPaymentSelection(context, payment, l10n),
        ),
      ],
    );
  }

  Widget _buildLanguageButton(LocalizationProvider l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.translate('language'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const LanguageSelector(color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildListButton(
    String title, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab Content Logic ──────────────────────────────────────────────────
  Widget _buildFullOrdersList(
    OrdersProvider ordersProvider,
    LocalizationProvider l10n,
  ) {
    if (ordersProvider.orders.isEmpty) {
      return _buildEmptyState(l10n.translate('emptyCart'));
    }
    return Column(
      children: ordersProvider.orders
          .map((o) => _buildDetailedOrderCard(o))
          .toList(),
    );
  }

  Widget _buildSettingsContent(
    PaymentProvider payment,
    LocalizationProvider l10n,
  ) {
    return _buildSettingsPreview(payment, l10n);
  }

  Widget _buildDetailedOrderCard(dynamic order) {
    return _buildPreviewOrderCard(
      context,
      Provider.of<OrdersProvider>(context, listen: false),
      order,
      isTop: true,
      isBottom: true,
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context, LocalizationProvider l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.translate('loginToSeeProfile'),
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'LoginScreen'),
                  builder: (context) =>
                      const LoginScreen(isCheckoutFlow: false),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text(l10n.translate('login')),
          ),
        ],
      ),
    );
  }
}
