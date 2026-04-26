import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/banner_model.dart';
import '../../../core/models/category_model.dart';
import '../../../core/localization/localization_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../widgets/food_detail_dialog.dart';
import '../providers/home_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'search_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategoryId;
  late PageController _bannersController;
  Timer? _bannerTimer;
  static const int _infiniteFactor = 10000;
  int _currentBannerPage = 0;
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bannersController = PageController(initialPage: _infiniteFactor ~/ 2);
    _currentBannerPage = _infiniteFactor ~/ 2;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchHomeData().then((_) => _startBannerTimer());
      Provider.of<CartProvider>(context, listen: false).loadCart();
    });
  }

  @override
  void dispose() {
    _bannersController.dispose();
    _categoryScrollController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      final hp = Provider.of<HomeProvider>(context, listen: false);
      if (hp.banners.isNotEmpty && _bannersController.hasClients) {
        _bannersController.animateToPage(
          _currentBannerPage + 1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  Widget _buildSearchBar(BuildContext context, LocalizationProvider l10n) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          settings: const RouteSettings(name: 'SearchScreen'),
          pageBuilder: (context, a1, a2) => const SearchScreen(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(80),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.white.withValues(alpha: 0.3), size: 20),
            const SizedBox(width: 12),
            Text(
              l10n.translate('searchHint') ?? 'Փնտրել...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFoodDetail(BuildContext ctx, ProductModel product) {
    showFoodDetail(ctx, product);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;
    final hp = Provider.of<HomeProvider>(context);

    if (hp.isLoading && hp.products.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (hp.error != null && hp.products.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Սխալ: ${hp.error}', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: hp.fetchHomeData,
                child: const Text('Կրկին փորձել'),
              ),
            ],
          ),
        ),
      );
    }

    final displayProducts = (_selectedCategoryId == null || _selectedCategoryId == 'all')
        ? hp.products
        : hp.products.where((p) => p.categoryId == _selectedCategoryId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF030302),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: hp.fetchHomeData,
              color: Colors.white,
              backgroundColor: Colors.black,
              child: CustomScrollView(
                slivers: [
                  // Search bar
                  SliverToBoxAdapter(child: _buildSearchBar(context, l10n)),

                  // Banner carousel
                  if (hp.banners.isNotEmpty)
                    SliverToBoxAdapter(child: _buildBanner(context, hp.banners, lang)),

                  // Sticky category chips
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CategoryBarDelegate(
                      categories: hp.categories,
                      selectedCategoryId: _selectedCategoryId,
                      lang: lang,
                      scrollController: _categoryScrollController,
                      onSelected: (id) => setState(() => _selectedCategoryId = id),
                    ),
                  ),

                  // Product grid
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: displayProducts.isEmpty
                        ? const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text('Ապրանքներ չկան', style: TextStyle(color: Colors.white54)),
                            ),
                          )
                        : Builder(builder: (ctx) {
                            final w = MediaQuery.of(ctx).size.width;
                            final cols = w >= 900 ? 5 : 2;
                            final extent = w >= 900 ? 310.0 : 290.0;
                            return SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                mainAxisExtent: extent,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => _buildProductCard(ctx, displayProducts[i], lang, l10n),
                                childCount: displayProducts.length,
                              ),
                            );
                          }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner ─────────────────────────────────────────────────────────────────

  Widget _buildBanner(BuildContext ctx, List<BannerModel> banners, String lang) {
    final isDesktop = MediaQuery.of(ctx).size.width >= 900;
    final bannerHeight = isDesktop ? 464.0 : 232.0;
    final textTop = isDesktop ? 108.0 : 54.0;
    final descTop = isDesktop ? 146.0 : 73.0;
    return SizedBox(
      height: bannerHeight,
      child: PageView.builder(
        controller: _bannersController,
        onPageChanged: (i) => _currentBannerPage = i,
        itemCount: _infiniteFactor,
        itemBuilder: (ctx, i) {
          final banner = banners[i % banners.length];
          final hasLink = banner.link != null && banner.link!.isNotEmpty;

          return GestureDetector(
            onTap: () async {
              if (hasLink) {
                final url = Uri.parse(banner.link!);
                if (await canLaunchUrl(url)) await launchUrl(url);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1A1A1A),
                image: banner.image != null
                    ? DecorationImage(image: NetworkImage(banner.image!), fit: BoxFit.cover)
                    : null,
              ),
              child: Stack(
                children: [
                  // Left-to-right gradient for text readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Title
                  Positioned(
                    top: textTop,
                    left: 32,
                    right: 32,
                    child: Text(
                      banner.title.getLocalized(lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  // Description / price
                  Positioned(
                    top: descTop,
                    left: 32,
                    right: 32,
                    child: Text(
                      banner.description.getLocalized(lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Product card ───────────────────────────────────────────────────────────

  Widget _buildProductCard(BuildContext ctx, ProductModel product, String lang, LocalizationProvider l10n) {
    final isDesktop = MediaQuery.of(ctx).size.width >= 900;
    return GestureDetector(
      onTap: () => _openFoodDetail(ctx, product),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF10100F),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: isDesktop ? 160 : 170,
              width: double.infinity,
              child: product.mainImageUrl.isNotEmpty
                  ? Image.network(
                      product.mainImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, err, stack) => _fallbackImage(),
                    )
                  : _fallbackImage(),
            ),

            // Card body: padding 12, gap 8
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title — 12px bold
                    Text(
                      product.name.getLocalized(lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Portion + price row — 12px
                    Consumer<CartProvider>(
                      builder: (_, cart, child) {
                        final qty = cart.getItemQuantity(product.id);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              qty > 0 ? '$qty x' : '1 ${l10n.translate('portion')}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              '${product.displayPrice.toStringAsFixed(0)}֏',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Add / quantity buttons
                    Consumer<CartProvider>(
                      builder: (_, cart, child) {
                        final qty = cart.getItemQuantity(product.id);
                        if (qty > 0) {
                          return _QuantityRow(
                            quantity: qty,
                            onDecrement: () => cart.removeOneItemByProductId(product.id),
                            onIncrement: () => cart.addItem(product),
                          );
                        }
                        return _AddButton(
                          label: l10n.translate('add'),
                          onTap: () => _openFoodDetail(ctx, product),
                        );
                      },
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

  Widget _fallbackImage() => Container(
    color: const Color(0xFF1A1A1A),
    child: const Center(child: Icon(Icons.fastfood, color: Colors.white24, size: 40)),
  );
}


// ── Add button ─────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Quantity row ────────────────────────────────────────────────────────────

class _QuantityRow extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityRow({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Minus — outlined, flex
        Expanded(child: _PillBtn(label: '-', filled: false, onTap: onDecrement)),
        const SizedBox(width: 8),
        // Quantity — outlined, fixed 40px
        _PillBtn(label: '$quantity', filled: false, onTap: null, fixedWidth: 40),
        const SizedBox(width: 8),
        // Plus — white filled, flex
        Expanded(child: _PillBtn(label: '+', filled: true, onTap: onIncrement)),
      ],
    );
  }
}

class _PillBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback? onTap;
  final double? fixedWidth;

  const _PillBtn({
    required this.label,
    required this.filled,
    required this.onTap,
    this.fixedWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fixedWidth,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: filled ? null : Border.all(color: Colors.white.withValues(alpha: 0.7)),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Category bar (sticky) ──────────────────────────────────────────────────

class _CategoryBarDelegate extends SliverPersistentHeaderDelegate {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String lang;
  final ScrollController scrollController;
  final void Function(String?) onSelected;

  const _CategoryBarDelegate({
    required this.categories,
    required this.selectedCategoryId,
    required this.lang,
    required this.scrollController,
    required this.onSelected,
  });

  // Height: 16 top padding + 36 chip height + 16 bottom padding = 68
  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: const Color(0xFF030302).withValues(alpha: 0.9),
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: categories.length + 1,
            itemBuilder: (context, i) {
              final isAll = i == 0;
              final isSelected = isAll
                  ? selectedCategoryId == null
                  : selectedCategoryId == categories[i - 1].id;
              final label = isAll
                  ? Provider.of<LocalizationProvider>(context, listen: false).translate('catAll')
                  : categories[i - 1].name.getLocalized(lang);
              return GestureDetector(
                onTap: () => onSelected(isAll ? null : categories[i - 1].id),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                    border: isSelected
                        ? null
                        : Border.all(color: Colors.white.withValues(alpha: 0.7)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(0, 4), blurRadius: 0),
                    ],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryBarDelegate old) =>
      old.selectedCategoryId != selectedCategoryId ||
      old.categories.length != categories.length;
}
