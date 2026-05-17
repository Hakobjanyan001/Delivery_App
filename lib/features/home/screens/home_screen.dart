import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/restaurant_model.dart';
import '../../../core/models/common_models.dart';
import '../../../core/localization/localization_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../widgets/food_detail_dialog.dart';
import '../widgets/restaurant_section.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_banner.dart';
import '../widgets/product_card.dart';
import '../widgets/category_bar.dart';
import '../providers/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategoryId;
  String? _selectedRestaurantId;
  late PageController _bannersController;
  Timer? _bannerTimer;
  static const int _infiniteFactor = 10000;
  int _currentBannerPage = _infiniteFactor ~/ 2;
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bannersController = PageController(initialPage: _infiniteFactor ~/ 2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchHomeData().then((_) => _startBannerTimer());
      Provider.of<CartProvider>(context, listen: false).loadCart();
    });
  }

  @override
  void dispose() {
    _bannersController.dispose();
    _categoryScrollController.dispose();
    _mainScrollController.dispose();
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

  void _openFoodDetail(BuildContext ctx, ProductModel product) {
    showFoodDetail(ctx, product);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;
    final hp = Provider.of<HomeProvider>(context);

    // Check if currently selected restaurant closed while viewing
    if (_selectedRestaurantId != null) {
      final selectedRest = hp.restaurants.firstWhere(
        (r) => r.id == _selectedRestaurantId,
        orElse: () => RestaurantModel(
          id: '', 
          name: LocalizedString(hy: '', en: '', ru: ''), 
          description: LocalizedString(hy: '', en: '', ru: ''),
          workingHours: WorkingHours(open: '00:00', close: '00:00'),
          delivery: DeliverySettings(basePrice: 0, multiCourierEnabled: false, freeDeliveryFrom: 0),
          isActive: false,
        ),
      );

      if (selectedRest.id.isNotEmpty && !selectedRest.isOpen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_selectedRestaurantId != null) {
            setState(() {
              _selectedRestaurantId = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.translate('weAreClosedNow')),
                duration: const Duration(seconds: 4),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }
    }

    if (hp.isLoading && hp.products.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface)),
      );
    }

    if (hp.error != null && hp.products.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Սխալ: ${hp.error}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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

    final displayProducts = hp.products.where((p) {
      final matchesCategory = (_selectedCategoryId == null || _selectedCategoryId == 'all' || p.categoryId == _selectedCategoryId);
      final matchesRestaurant = (_selectedRestaurantId == null || p.restaurantId == _selectedRestaurantId);
      
      // Also check if the restaurant is open
      final restaurant = hp.restaurants.firstWhere(
        (r) => r.id == p.restaurantId,
        orElse: () => RestaurantModel(
          id: '', 
          name: LocalizedString(hy: '', en: '', ru: ''), 
          description: LocalizedString(hy: '', en: '', ru: ''),
          workingHours: WorkingHours(open: '00:00', close: '00:00'),
          delivery: DeliverySettings(basePrice: 0, multiCourierEnabled: false, freeDeliveryFrom: 0),
          isActive: false,
        ),
      );
      
      return matchesCategory && matchesRestaurant && restaurant.isOpen;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: hp.fetchHomeData,
              color: Theme.of(context).colorScheme.onSurface,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: CustomScrollView(
                controller: _mainScrollController,
                slivers: [
                  // Search bar
                  SliverToBoxAdapter(child: HomeSearchBar(l10n: l10n)),

                  // Banner carousel
                  if (hp.banners.isNotEmpty)
                    SliverToBoxAdapter(
                      child: HomeBanner(
                        banners: hp.banners,
                        lang: lang,
                        controller: _bannersController,
                        onPageChanged: (i) => _currentBannerPage = i,
                        infiniteFactor: _infiniteFactor,
                      ),
                    ),

                  // Restaurants section
                  if (hp.restaurants.isNotEmpty)
                    SliverToBoxAdapter(
                      child: RestaurantSection(
                        restaurants: hp.restaurants,
                        lang: lang,
                        selectedRestaurantId: _selectedRestaurantId,
                        onRestaurantSelected: (id) {
                          setState(() {
                            if (_selectedRestaurantId == id) {
                              _selectedRestaurantId = null;
                            } else {
                              _selectedRestaurantId = id;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _mainScrollController.animateTo(
                                  350, 
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              });
                            }
                          });
                        },
                      ),
                    ),

                  // Sticky category chips
                  CategoryBar(
                    categories: hp.categories,
                    selectedCategoryId: _selectedCategoryId,
                    lang: lang,
                    scrollController: _categoryScrollController,
                    onSelected: (id) => setState(() => _selectedCategoryId = id),
                  ),

                  // Product grid
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: displayProducts.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                                child: Text('Ապրանքներ չկան', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
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
                                (ctx, i) => ProductCard(
                                  product: displayProducts[i],
                                  lang: lang,
                                  l10n: l10n,
                                  onTap: () => _openFoodDetail(context, displayProducts[i]),
                                ),
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
}
