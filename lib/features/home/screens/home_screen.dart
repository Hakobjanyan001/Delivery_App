import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/food_model.dart';
import '../../../core/localization/localization_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../widgets/food_detail_dialog.dart';
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
  String selectedCategoryKey = 'catAll';

  final List<String> categoryKeys = [
    'catAll', 'catShaurma', 'catBarbecue', 'catKFC', 'catPizza', 'catBurger', 
    'catSushi', 'catFastFood', 'catHotMeals', 'catCombo', 'catItalian', 
    'catKorean', 'catSandwiches', 'catDessert'
  ];

  final List<Restaurant> allRestaurants = [
    Restaurant(
      id: '1',
      name: 'Տաշիր Պիցցա',
      nameEn: 'Tashir Pizza',
      nameRu: 'Ташир Пицца',
      description: 'Համեղ պիցցաներ և իտալական խոհանոց',
      descriptionEn: 'Tasty pizzas and Italian cuisine',
      descriptionRu: 'Вкусная пицца и итальянская кухня',
      workingHours: '10:00 - 22:00',
      delivery: '30-45 րոպե',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80',
      category: 'Pizza',
      price: 700,
    ),
    Restaurant(
      id: '2',
      name: 'Բուրգեր Հաուս',
      nameEn: 'Burger House',
      nameRu: 'Бургер Хаус',
      description: 'Լավագույն բուրգերները քաղաքում',
      descriptionEn: 'The best burgers in town',
      descriptionRu: 'Лучшие бургеры в городе',
      workingHours: '11:00 - 23:00',
      delivery: '25-40 րոպե',
      rating: 4.2,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
      category: 'Burger',
      price: 900,
    ),
  ];

  final Map<String, List<FoodItem>> _foodByCategory = {
    'Shaurma': [
      FoodItem(
        id: 'sh_1',
        name: 'Հավի Շաուրմա (Մեծ)',
        nameEn: 'Chicken Shawarma (Large)',
        nameRu: 'Шаурма с курицей (Большая)',
        order: '1',
        description: 'Թարմ հավի միս, լավաշ և հատուկ սոուս:',
        descriptionEn: 'Fresh chicken, lavash, and special sauce.',
        descriptionRu: 'Свежая курица, лаваш и специальный соус.',
        price: 1100,
        category: 'Shaurma',
        prepTime: 15,
        imageUrl: 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500&q=80',
        availableOptions: ['Կծու', 'Առանց սոխի', 'Լրացուցիչ մայոնեզ'],
      ),
    ],
    'Pizza': [
      FoodItem(
        id: 'pizza_1',
        name: 'Մարգարիտա',
        nameEn: 'Margherita',
        nameRu: 'Маргарита',
        order: '1',
        description: 'Մոցարելլա պանիր, լոլիկի սոուս և ռեհան:',
        descriptionEn: 'Mozzarella cheese, tomato sauce, and basil.',
        descriptionRu: 'Сыр моцарелла, томатный соус и базилик.',
        price: 1800,
        category: 'Pizza',
        prepTime: 20,
        imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&q=80',
        sizes: ['Փոքր', 'Մեծ'],
        sizePrices: [1800, 3000],
        slicePrice: 250,
        availableOptions: ['Կծու', 'Կրկնակի պանիր'],
      ),
    ],
  };

  String? _mapToInternal(String key) {
    switch (key) {
      case 'catShaurma': return 'Shaurma';
      case 'catPizza': return 'Pizza';
      case 'catBurger': return 'Burger';
      case 'catSushi': return 'Sushi';
      case 'catDessert': return 'Dessert';
      default: return null;
    }
  }

  List<FoodItem> _getFilteredFoodItems(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    final query = searchProvider.searchQuery.toLowerCase().trim();
    final List<FoodItem> allItems = _foodByCategory.values.expand((list) => list).toList();
    
    if (query.isNotEmpty) {
      return allItems.where((f) {
        return f.name.toLowerCase().contains(query) ||
               f.nameEn.toLowerCase().contains(query) ||
               f.nameRu.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedCategoryKey == 'catAll') {
      return allItems;
    }
    final category = _mapToInternal(selectedCategoryKey);
    return _foodByCategory[category] ?? [];
  }

  void _requireAuthOrExecute(VoidCallback action) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
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

  void _openFoodDetail(BuildContext context, FoodItem food) {
    _requireAuthOrExecute(() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        routeSettings: const RouteSettings(name: 'FoodDetail'),
        builder: (_) => FoodDetailDialog(food: food),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;

    return Consumer<SearchProvider>(
      builder: (context, search, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: search.isSearchActive 
            ? PreferredSize(preferredSize: Size.zero, child: const SizedBox.shrink())
            : AppBar(
                backgroundColor: Colors.black,
                elevation: 0,
                toolbarHeight: 70,
                centerTitle: false,
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
                title: null,
                actions: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse('tel:+37460515515');
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.phone_outlined, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('+374 60 515515', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0, left: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
                          Navigator.push(context, MaterialPageRoute(settings: const RouteSettings(name: 'LoginScreen'), builder: (context) => const LoginScreen(isCheckoutFlow: false)));
                        } else {
                          Navigator.push(context, MaterialPageRoute(settings: const RouteSettings(name: 'ProfileScreen'), builder: (context) => const ProfileScreen()));
                        }
                      },
                      child: Container(
                        width: 45, height: 45,
                        decoration: BoxDecoration(color: const Color(0xFF161616), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                        child: const Icon(Icons.person_outline, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
          body: CustomScrollView(
            key: const ValueKey('home_scroll_v2'),
            slivers: [
              if (search.isSearchActive) const SliverToBoxAdapter(child: SizedBox(height: 120)),
              if (!search.isSearchActive) SliverToBoxAdapter(child: _buildPromoBanner()),
              if (!search.isSearchActive) const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(l10n.translate('categoriesTitle'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categoryKeys.length,
                    itemBuilder: (context, index) {
                      final key = categoryKeys[index];
                      final isSelected = selectedCategoryKey == key;
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategoryKey = key),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Text(l10n.translate(key), style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontSize: 14)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(l10n.translate(selectedCategoryKey), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              _getFilteredFoodItems(context).isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(l10n.translate('noResults'), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ]),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount;
                          final width = constraints.crossAxisExtent;
                          if (width > 1100) crossAxisCount = 4;
                          else if (width > 750) crossAxisCount = 3;
                          else if (width > 520) crossAxisCount = 2;
                          else crossAxisCount = 1;

                          return SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16, mainAxisSpacing: 18,
                              mainAxisExtent: width > 520 ? 440 : 460,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final currentFilteredItems = _getFilteredFoodItems(context);
                                return _buildFoodCard(currentFilteredItems[index], lang);
                              },
                              childCount: _getFilteredFoodItems(context).length,
                            ),
                          );
                        },
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFoodCard(FoodItem food, String lang) {
    return GestureDetector(
      onTap: () => _openFoodDetail(context, food),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Image.network(
                  food.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1A1A1A), child: const Icon(Icons.fastfood, color: Colors.white24, size: 40)),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food.localizedName(lang), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            final quantity = cart.getItemQuantity(food.id);
                            final portionText = '1 ${lang == 'en' ? 'portion' : (lang == 'ru' ? 'порция' : 'բաժին')}';
                            return Text(
                              quantity > 0 ? '$portionText x$quantity' : portionText,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                            );
                          },
                        ),
                        Text('${food.price.toStringAsFixed(0)}֏', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                      ],
                    ),
                    const Spacer(),
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        final quantity = cart.getItemQuantity(food.id);
                        if (quantity == 0) {
                          return SizedBox(
                            width: double.infinity, height: 50,
                            child: OutlinedButton(
                              onPressed: () => _requireAuthOrExecute(() => cart.addItem(food)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white, width: 1), shape: const StadiumBorder()),
                              child: Text(lang == 'en' ? 'Add' : (lang == 'ru' ? 'Добавить' : 'Ավելացնել'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                            ),
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _requireAuthOrExecute(() => cart.removeOneItemByFoodId(food.id)),
                              child: Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3))), child: const Icon(Icons.remove, color: Colors.white, size: 24)),
                            ),
                            Text('$quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                            GestureDetector(
                              onTap: () => _requireAuthOrExecute(() => cart.addItem(food)),
                              child: Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.black, size: 24)),
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

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(16), height: 200, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), image: const DecorationImage(image: AssetImage('assets/images/promo_banner.png'), fit: BoxFit.cover)),
      child: Stack(
        children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent]))),
          Positioned(top: 54, left: 32, child: const Text('Կեսար հավով', style: TextStyle(color: Colors.white, fontSize: 14.28, fontWeight: FontWeight.w700))),
          Positioned(top: 73, left: 32, child: const Text('2,000֏', style: TextStyle(color: Colors.white, fontSize: 39.84, fontWeight: FontWeight.w700, height: 1.4))),
          Positioned(top: 127, left: 32, child: Text('2,300֏', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 18.57, fontWeight: FontWeight.w700, decoration: TextDecoration.lineThrough))),
        ],
      ),
    );
  }
}
