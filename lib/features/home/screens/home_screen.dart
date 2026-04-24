import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/banner_model.dart';
import '../../../core/localization/localization_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../widgets/food_detail_dialog.dart';
import '../providers/home_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/search_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/profile_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  late PageController _productBannerController;
  Timer? _bannerTimer;
  int _currentBannerPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _productBannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _productBannerController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchHomeData().then((_) {
        _startBannerTimer();
      });
    });
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      if (homeProvider.products.isNotEmpty) {
        _currentBannerPage = (_currentBannerPage + 1) % homeProvider.products.length;
        if (_productBannerController.hasClients) {
          _productBannerController.animateToPage(
            _currentBannerPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  void _requireAuthOrExecute(VoidCallback action) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: 'LoginScreen'),
          builder: (context) => const LoginScreen(isCheckoutFlow: false),
        ),
      );
    } else {
      action();
    }
  }

  void _openFoodDetail(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: 'FoodDetail'),
      builder: (_) => FoodDetailDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;
    final homeProvider = Provider.of<HomeProvider>(context);
    final search = Provider.of<SearchProvider>(context);

    if (_searchController.text != search.searchQuery) {
      _searchController.text = search.searchQuery;
    }

    if (homeProvider.isLoading && homeProvider.products.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (homeProvider.error != null && homeProvider.products.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Սխալ: ${homeProvider.error}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => homeProvider.fetchHomeData(),
                child: const Text('Կրկին փորձել'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredProducts = homeProvider.getProductsByCategory(
      selectedCategoryId,
    );

    final displayProducts = search.searchQuery.isNotEmpty
        ? homeProvider.products
              .where(
                (p) => p.name
                    .getLocalized(lang)
                    .toLowerCase()
                    .contains(search.searchQuery.toLowerCase()),
              )
              .toList()
        : filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              toolbarHeight: 70,
              leadingWidth: 101,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Image.asset(
                  'assets/images/masoor_branch.png',
                  width: 72,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
              actions: [
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse('tel:+37460515515');
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.phone_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '+374 60 515515',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: () => homeProvider.fetchHomeData(),
        color: Colors.white,
        backgroundColor: Colors.black,
        child: CustomScrollView(
          slivers: [
            if (search.searchQuery.isEmpty && homeProvider.products.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildProductBanner(homeProvider.products, lang),
              ),
            // Sticky Search Bar
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: Colors.black,
              surfaceTintColor: Colors.black,
              automaticallyImplyLeading: false,
              toolbarHeight: 80,
              title: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Icon(Icons.search, color: Colors.white54, size: 20),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => search.updateQuery(value),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: l10n.translate('searchHint'),
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                    if (search.searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white54,
                          size: 20,
                        ),
                        onPressed: () {
                          search.clearSearch();
                          _searchController.clear();
                        },
                      ),
                  ],
                ),
              ),
            ),

            if (search.searchQuery.isEmpty && homeProvider.banners.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildBannersCarousel(homeProvider.banners, lang),
              ),

            if (search.searchQuery.isEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // Sticky Categories Header
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: Colors.black,
                surfaceTintColor: Colors.black,
                automaticallyImplyLeading: false,
                toolbarHeight: 60,
                title: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: homeProvider.categories.length + 1,
                    itemBuilder: (context, index) {
                      final bool isAll = index == 0;
                      final category = isAll
                          ? null
                          : homeProvider.categories[index - 1];
                      final categoryId = isAll ? 'all' : category!.id;
                      final name = isAll
                          ? l10n.translate('catAll')
                          : category!.name.getLocalized(lang);
                      final isSelected =
                          (selectedCategoryId == null && isAll) ||
                          (selectedCategoryId == categoryId);

                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedCategoryId = categoryId),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],

            displayProducts.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.translate('noResults'),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount;
                        final width = constraints.crossAxisExtent;
                        if (width > 1100) {
                          crossAxisCount = 4;
                        } else if (width > 750)
                          crossAxisCount = 3;
                        else if (width > 520)
                          crossAxisCount = 2;
                        else
                          crossAxisCount = 2;

                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: width > 520 ? 440 : 280,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return _buildFoodCard(
                              displayProducts[index],
                              lang,
                              l10n,
                            );
                          }, childCount: displayProducts.length),
                        );
                      },
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(
    ProductModel product,
    String lang,
    LocalizationProvider l10n,
  ) {
    return GestureDetector(
      onTap: () => _openFoodDetail(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: AspectRatio(
                aspectRatio: 1.6,
                child: product.mainImageUrl.isNotEmpty
                    ? Image.network(
                        product.mainImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _fallbackImage(),
                      )
                    : _fallbackImage(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.getLocalized(lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (product.attributes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          product.attributes
                              .map((a) => a.name.getLocalized(lang))
                              .join(', '),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            final quantity = cart.getItemQuantity(product.id);
                            final portionText =
                                '1 ${l10n.translate('portion')}';
                            return Text(
                              quantity > 0
                                  ? '$portionText x$quantity'
                                  : portionText,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                        Text(
                          '${product.displayPrice.toStringAsFixed(0)}֏',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () => _openFoodDetail(context, product),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          l10n.translate('add'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
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
    child: const Icon(Icons.fastfood, color: Colors.white24, size: 40),
  );

  Widget _buildProductBanner(List<ProductModel> products, String lang) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: PageView.builder(
        controller: _productBannerController,
        onPageChanged: (index) => _currentBannerPage = index,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => _openFoodDetail(context, product),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF1A1A1A),
                image: product.mainImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.mainImageUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.3),
                          BlendMode.darken,
                        ),
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name.getLocalized(lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.displayPrice.toStringAsFixed(0)}֏',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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

  Widget _buildBannersCarousel(List<BannerModel> banners, String lang) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: const Color(0xFF1A1A1A),
              image: banner.image != null
                  ? DecorationImage(
                      image: NetworkImage(banner.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 54,
                  left: 32,
                  right: 32,
                  child: Text(
                    banner.title.getLocalized(lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 32,
                  right: 32,
                  child: Text(
                    banner.description.getLocalized(lang),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
