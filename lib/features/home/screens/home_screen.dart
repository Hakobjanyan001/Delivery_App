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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchHomeData();
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
    _requireAuthOrExecute(() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        routeSettings: const RouteSettings(name: 'FoodDetail'),
        builder: (_) => FoodDetailDialog(product: product),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;
    final homeProvider = Provider.of<HomeProvider>(context);
    final search = Provider.of<SearchProvider>(context);

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

    final displayProducts = search.isSearchActive
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
      appBar: search.isSearchActive
          ? PreferredSize(
              preferredSize: Size.zero,
              child: const SizedBox.shrink(),
            )
          : AppBar(
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
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.phone_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '+374 60 515515',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0, left: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      if (!authProvider.isAuthenticated) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: 'LoginScreen'),
                            builder: (context) =>
                                const LoginScreen(isCheckoutFlow: false),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(
                              name: 'ProfileScreen',
                            ),
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 24,
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
            if (search.isSearchActive)
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            if (!search.isSearchActive && homeProvider.banners.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildBannersCarousel(homeProvider.banners, lang),
              ),

            if (!search.isSearchActive) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    l10n.translate('categoriesTitle'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          crossAxisCount = 1;

                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 18,
                                mainAxisExtent: width > 520 ? 440 : 460,
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
                aspectRatio: 1.2,
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.getLocalized(lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
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
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        final quantity = cart.getItemQuantity(product.id);
                        if (quantity == 0) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () => _requireAuthOrExecute(
                                () => cart.addItem(product),
                              ),
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
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _requireAuthOrExecute(
                                () => cart.removeOneItemByProductId(product.id),
                              ),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _requireAuthOrExecute(
                                () => cart.addItem(product),
                              ),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
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
    child: const Icon(Icons.fastfood, color: Colors.white24, size: 40),
  );

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
