import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../core/models/food_model.dart';
import '../../../core/localization/localization_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../widgets/food_detail_dialog.dart';
import '../../../core/theme/app_theme.dart';
// import '../widgets/promo_video_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/search_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

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

  // ======================================
  // Restaurant List
  // ======================================

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
    Restaurant(
      id: '3',
      name: 'Ջազ Սուշի',
      nameEn: 'Jazz Sushi',
      nameRu: 'Джаз Суши',
      description: 'Թարմ սուշի և ասիական խոհանոց',
      descriptionEn: 'Fresh sushi and Asian cuisine',
      descriptionRu: 'Свежие суши и азиатская кухня',
      workingHours: '12:00 - 00:00',
      delivery: '40-60 րոպե',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80',
      category: 'Sushi',
      price: 1500,
    ),
  ];

  // ======================================
  // Food Items per category
  // ======================================
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
      FoodItem(
        id: 'sh_2',
        name: 'Տավարի Շաուրմա (Մեծ)',
        nameEn: 'Beef Shawarma (Large)',
        nameRu: 'Шаурма с говядиной (Большая)',
        order: '2',
        description: 'Հյութալի տավարի միս և թարմ բանջարեղեն:',
        descriptionEn: 'Juicy beef and fresh vegetables.',
        descriptionRu: 'Сочная говядина и свежие овощи.',
        price: 1400,
        category: 'Shaurma',
        prepTime: 15,
        imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500&q=80',
        availableOptions: ['Կծու', 'Պանիրով', 'Կրկնակի միս'],
      ),
    ],
    'Barbecue': [
      FoodItem(
        id: 'bbq_1',
        name: 'Խոզի Խորոված (Չալաղաջ)',
        nameEn: 'Pork Barbecue (Chalagach)',
        nameRu: 'Шашлык из свинины (Чалагач)',
        order: '1',
        description: 'Ավանդական հայկական խորոված՝ կրակի վրա:',
        descriptionEn: 'Traditional Armenian BBQ on fire.',
        descriptionRu: 'Традиционный армянский шашлык на огне.',
        price: 3500,
        category: 'Barbecue',
        prepTime: 30,
        unit: 'կտոր',
        imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80',
        availableOptions: ['Սոխով', 'Առանց սոխի', 'Կծու աջիկա'],
      ),
      FoodItem(
        id: 'bbq_2',
        name: 'Տավարի Քյաբաբ',
        nameEn: 'Beef Kebab',
        nameRu: 'Люля-кебаб из говядины',
        order: '2',
        description: 'Տավարի աղացած միս և հարուստ համեմունքներ:',
        descriptionEn: 'Ground beef with rich spices.',
        descriptionRu: 'Говяжий фарш с богатыми специями.',
        price: 900,
        category: 'Barbecue',
        prepTime: 20,
        imageUrl: 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=500&q=80',
        availableOptions: ['Լավաշով', 'Պանիրով'],
      ),
    ],
    'KFC': [
      FoodItem(
        id: 'kfc_1',
        name: 'Sanders Bucket',
        nameEn: 'Sanders Bucket',
        nameRu: 'Баскет Сандерс',
        order: '1',
        description: '11 տապակած հավի կտորներ:',
        descriptionEn: '11 pieces of fried chicken.',
        descriptionRu: '11 кусочков жареной курицы.',
        price: 5500,
        category: 'KFC',
        prepTime: 10,
        imageUrl: 'https://images.unsplash.com/photo-1513639776629-7b61b0ac49cb?w=500&q=80',
        availableOptions: ['Կծու', 'Original'],
      ),
      FoodItem(
        id: 'kfc_2',
        name: 'Zinger Burger',
        nameEn: 'Zinger Burger',
        nameRu: 'Зингер Бургер',
        order: '2',
        description: 'Կծու հավի ֆիլե և թարմ լատուկ:',
        descriptionEn: 'Spicy chicken fillet and fresh lettuce.',
        descriptionRu: 'Острое куриное филе и свежий латук.',
        price: 1300,
        category: 'KFC',
        prepTime: 10,
        imageUrl: 'https://images.unsplash.com/photo-1513185158878-8d8c182b013f?w=500&q=80',
        availableOptions: ['Կրկնակի պանիր', 'Կծու'],
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
        availableOptions: ['Կծու', 'Կրկնակի պանիր', 'Առանց ձիթապտղի'],
        restaurantId: '1',
        features: ['Հանրահայտ', 'Իտալական'],
      ),
      FoodItem(
        id: 'pizza_2',
        name: 'Pepperoni',
        nameEn: 'Pepperoni',
        nameRu: 'Пепперони',
        order: '2',
        description: 'Պեպպերոնի երշիկ և առատ պանիր:',
        descriptionEn: 'Pepperoni sausage and plenty of cheese.',
        descriptionRu: 'Колбаса пепперони и много сыра.',
        price: 2200,
        category: 'Pizza',
        prepTime: 20,
        imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500&q=80',
        sizes: ['Փոքր', 'Մեծ'],
        sizePrices: [2200, 3500],
        slicePrice: 300,
        availableOptions: ['Կծու', 'Կրկնակի pepperoni', 'Բարակ խմոր'],
        restaurantId: '1',
        features: ['Կծու', 'Միս'],
      ),
      FoodItem(
        id: 'pizza_3',
        name: '4 Cheese',
        nameEn: '4 Cheese',
        nameRu: '4 Сыра',
        order: '3',
        description: 'Մոցարելլա, պարմեզան, դոր-բլյու և չեդդեր:',
        descriptionEn: 'Mozzarella, parmesan, dor-blue, and cheddar.',
        descriptionRu: 'Моцарелла, пармезан, дор-блю и чеддер.',
        price: 2500,
        category: 'Pizza',
        prepTime: 20,
        imageUrl: 'https://images.unsplash.com/photo-1548600916-dc8492f8e845?w=500&q=80',
        sizes: ['Փոքր', 'Մեծ'],
        sizePrices: [2500, 4000],
        slicePrice: 350,
        availableOptions: ['Կծու', 'Առանց mozzarella'],
      ),
    ],
    'Burger': [
      FoodItem(
        id: 'burger_1',
        name: 'Դասական Բուրգեր',
        nameEn: 'Classic Burger',
        nameRu: 'Классический бургер',
        order: '1',
        description: 'Տավարի միս, թթու վարունգ և սոուս:',
        descriptionEn: 'Beef patty, pickles, and sauce.',
        descriptionRu: 'Говяжья котлета, огурцы и соус.',
        price: 1200,
        category: 'Burger',
        prepTime: 15,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
        sizes: ['Փոքր', 'Մեծ'],
        availableOptions: ['Կծու', 'Կրկնակի կոտլետ', 'Առանց կոճապղպեղ', 'Կրկնակի պանիր'],
        restaurantId: '2',
        features: ['Դասական', 'Հյութալի'],
      ),
      FoodItem(
        id: 'burger_2',
        name: 'BBQ Բուրգեր',
        nameEn: 'BBQ Burger',
        nameRu: 'BBQ Бургер',
        order: '2',
        description: 'Հատուկ BBQ սոուս և տապակած սոխ:',
        descriptionEn: 'Special BBQ sauce and fried onions.',
        descriptionRu: 'Специальный соус барбекю и жареный лук.',
        price: 1600,
        category: 'Burger',
        prepTime: 15,
        imageUrl: 'https://images.unsplash.com/photo-1596662951482-0bc71f5e0ea0?w=500&q=80',
        sizes: ['Փոքր', 'Մեծ'],
        availableOptions: ['Կծու', 'Կրկնակի BBQ sauce'],
      ),
    ],
    'Sushi': [
      FoodItem(
        id: 'sushi_1',
        name: 'Սաղմոնի Ռոլլ',
        nameEn: 'Salmon Roll',
        nameRu: 'Ролл с лососем',
        order: '1',
        description: 'Թարմ սաղմոն և քացախով բրինձ:',
        descriptionEn: 'Fresh salmon and vinegared rice.',
        descriptionRu: 'Свежий лосось и рис с уксусом.',
        price: 3200,
        category: 'Sushi',
        prepTime: 25,
        imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=500&q=80',
        sizes: ['6 հատ', '12 հատ'],
        availableOptions: ['Կծու', 'Կրկնակի salmon', 'Wasabi-ով'],
        restaurantId: '3',
        features: ['Թարմ', 'Պրեմիում'],
      ),
    ],
    'FastFood': [
      FoodItem(
        id: 'ff_1',
        name: 'Ֆրի',
        nameEn: 'French Fries',
        nameRu: 'Картофель фри',
        order: '1',
        description: 'Ոսկեգույն և խրթխրթան կարտոֆիլ:',
        descriptionEn: 'Golden and crispy potatoes.',
        descriptionRu: 'Золотистый и хрустящий картофель.',
        price: 600,
        category: 'FastFood',
        prepTime: 10,
        imageUrl: 'https://images.unsplash.com/photo-1630384066272-1177f6f53d8d?w=500&q=80',
        availableOptions: ['Կետչուպով', 'Մայոնեզով', 'Պանրի սոուսով'],
      ),
    ],
    'HotMeals': [
      FoodItem(
        id: 'hm_1',
        name: 'Դոլմա',
        nameEn: 'Dolma',
        nameRu: 'Долма',
        order: '1',
        description: 'Ավանդական հայկական դոլմա:',
        descriptionEn: 'Traditional Armenian Dolma.',
        descriptionRu: 'Традиционная армянская долма.',
        price: 2500,
        category: 'HotMeals',
        prepTime: 25,
        imageUrl: 'https://images.unsplash.com/photo-1534080564583-6be75777b70a?w=500&q=80',
      ),
    ],
    'Dessert': [
      FoodItem(
        id: 'dessert_1',
        name: 'Շոկոլադե Լավա Քեյք',
        nameEn: 'Chocolate Lava Cake',
        nameRu: 'Шоколадный торт Лава',
        order: '1',
        description: 'Տաք շոկոլադե միջուկով դեսերտ:',
        descriptionEn: 'Dessert with a warm chocolate center.',
        descriptionRu: 'Десерт с теплой шоколадной начинкой.',
        price: 800,
        category: 'Dessert',
        prepTime: 15,
        imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500&q=80',
        sizes: ['1 հատ', '2 հատ'],
        availableOptions: ['Ice cream-ով', 'Վanilla sauce-ով'],
      ),
    ],
  };

  String? _mapToInternal(String key) {
    switch (key) {
      case 'catShaurma': return 'Shaurma';
      case 'catBarbecue': return 'Barbecue';
      case 'catKFC': return 'KFC';
      case 'catPizza': return 'Pizza';
      case 'catBurger': return 'Burger';
      case 'catSushi': return 'Sushi';
      case 'catFastFood': return 'FastFood';
      case 'catHotMeals': return 'HotMeals';
      case 'catCombo': return 'Combo';
      case 'catItalian': return 'Italian';
      case 'catKorean': return 'Korean';
      case 'catSandwiches': return 'Sandwiches';
      case 'catDessert': return 'Dessert';
      default: return null;
    }
  }

  List<FoodItem> _getFilteredFoodItems(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    final query = searchProvider.searchQuery.toLowerCase().trim();
    
    final List<FoodItem> allItems = _foodByCategory.values.expand((list) => list).toList();
    
    List<FoodItem> results;
    if (selectedCategoryKey == 'catAll') {
      results = allItems;
    } else {
      final category = _mapToInternal(selectedCategoryKey);
      results = _foodByCategory[category] ?? [];
    }

    if (query.isNotEmpty) {
      return allItems.where((f) {
        return f.name.toLowerCase().contains(query) ||
               f.nameEn.toLowerCase().contains(query) ||
               f.nameRu.toLowerCase().contains(query);
      }).toList();
    }
    
    return results;
  }


  void _requireAuthOrExecute(VoidCallback action) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
      Navigator.push(
        context,
        MaterialPageRoute(
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 101, // Force rebuild
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Image.asset(
            'assets/images/masoor_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        title: GestureDetector(
          onTap: () async {
            final Uri url = Uri.parse('tel:+37460515515');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
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
                Text(
                  '+374 60 515515',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),



        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: 'CartScreen'),
                      builder: (context) => const CartScreen(),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Consumer<CartProvider>(
                    builder: (context, cart, child) => cart.items.isEmpty
                        ? const SizedBox.shrink()
                        : Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE41E26),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${cart.totalItemCount}',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        key: const ValueKey('home_scroll_v2'), // Force full rebuild of all closures inside Slivers on reload
        slivers: [
          // Search Bar removed


          // Promo Video Section
          // const SliverToBoxAdapter(
          //   child: PromoVideoWidget(height: 380),
          // ),


          // Categories Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(l10n.translate('categoriesTitle'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Categories List
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
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        l10n.translate(key),
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
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

          // Food Grid Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                l10n.translate(selectedCategoryKey),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // ---- FOOD ITEMS GRID ----
          _getFilteredFoodItems(context).isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(l10n.translate('noResults'),
                            style: TextStyle(color: Colors.grey[600], fontSize: 16)),
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
                      if (width > 1100) {
                        crossAxisCount = 4;
                      } else if (width > 750) {
                        crossAxisCount = 3;
                      } else if (width > 520) {
                        crossAxisCount = 2;
                      } else {
                        crossAxisCount = 1;
                      }
                      
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: width > 520 ? 330 : 380,
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
  }

  Widget _buildFoodCard(FoodItem food, String lang) {
    return GestureDetector(
      onTap: () => _openFoodDetail(context, food),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111), // Slightly lighter than background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - Circular/Highly Rounded
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(food.id.contains('1') ? 100 : 30), // Mix of circle and rounded
                  child: Image.network(
                    food.imageUrl,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        width: 150,
                        color: const Color(0xFF1A1A1A),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      width: 150,
                      color: const Color(0xFF1A1A1A),
                      child: const Icon(Icons.fastfood, color: Colors.white24, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            
            // Info Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Name Row
                  Text(
                    food.localizedName(lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Portion and Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1 ${lang == 'en' ? 'portion' : (lang == 'ru' ? 'порция' : 'բաժին')}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${food.price.toStringAsFixed(0)}֏',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Dynamic Add Button / Quantity Selector
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      final quantity = cart.getItemQuantity(food.id);
                      
                      if (quantity == 0) {
                        return SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () => _requireAuthOrExecute(() => cart.addItem(food)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              lang == 'en' ? 'Add' : (lang == 'ru' ? 'Добавить' : 'Ավելացնել'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }
                      
                      return Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => _requireAuthOrExecute(() => cart.removeOneItemByFoodId(food.id)),
                              icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _requireAuthOrExecute(() => cart.addItem(food)),
                              icon: const Icon(Icons.add, color: Colors.white, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
