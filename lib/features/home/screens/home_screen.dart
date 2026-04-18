import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:provider/provider.dart';
import '../../../core/models/food_model.dart';
import '../../../core/localization/localization_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/screens/cart_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/profile_screen.dart';
import '../../support/widgets/support_hub_sheet.dart';
import '../widgets/food_detail_dialog.dart';
import '../../../core/localization/widgets/language_selector.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategoryKey = 'catAll';
  String searchQuery = '';

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
      ),
      FoodItem(
        id: 'pizza_2',
        name: 'Pepperoni',
        nameEn: 'Pepperoni',
        nameRu: 'Пепперони',
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
      ),
      FoodItem(
        id: 'pizza_3',
        name: '4 Cheese',
        nameEn: '4 Cheese',
        nameRu: '4 Сыра',
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
        description: 'Տավարի միս, թթու վարունգ և սոուս:',
        descriptionEn: 'Beef patty, pickles, and sauce.',
        descriptionRu: 'Говяжья котлета, огурцы и соус.',
        price: 1200,
        category: 'Burger',
        prepTime: 15,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
        sizes: ['Փոքր', 'Մեծ'],
        availableOptions: ['Կծու', 'Կրկնակի կոտլետ', 'Առանց կոճապղպեղ', 'Կրկնակի պանիր'],
      ),
      FoodItem(
        id: 'burger_2',
        name: 'BBQ Բուրգեր',
        nameEn: 'BBQ Burger',
        nameRu: 'BBQ Бургер',
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
        description: 'Թարմ սաղմոն և քացախով բրինձ:',
        descriptionEn: 'Fresh salmon and vinegared rice.',
        descriptionRu: 'Свежий лосось и рис с уксусом.',
        price: 3200,
        category: 'Sushi',
        prepTime: 25,
        imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=500&q=80',
        sizes: ['6 հատ', '12 հատ'],
        availableOptions: ['Կծու', 'Կրկնակի salmon', 'Wasabi-ով'],
      ),
    ],
    'FastFood': [
      FoodItem(
        id: 'ff_1',
        name: 'Ֆրի',
        nameEn: 'French Fries',
        nameRu: 'Картофель фри',
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

  List<Restaurant> get filteredRestaurants {
    return allRestaurants.where((res) {
      final query = searchQuery.toLowerCase();
      return res.name.toLowerCase().contains(query) ||
             res.nameEn.toLowerCase().contains(query) ||
             res.nameRu.toLowerCase().contains(query);
    }).toList();
  }

  List<FoodItem> get filteredFoodItems {
    final query = searchQuery.toLowerCase();
    final List<FoodItem> allItems = _foodByCategory.values.expand((list) => list).toList();
    
    List<FoodItem> results;
    if (selectedCategoryKey == 'catAll') {
      results = allItems;
    } else {
      final category = _mapToInternal(selectedCategoryKey);
      results = _foodByCategory[category] ?? [];
    }

    return results.where((f) {
      return f.name.toLowerCase().contains(query) ||
             f.nameEn.toLowerCase().contains(query) ||
             f.nameRu.toLowerCase().contains(query);
    }).toList();
  }


  void _openFoodDetail(BuildContext context, FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodDetailDialog(food: food),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final lang = l10n.currentLocale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Consumer<AuthProvider>(
          builder: (context, auth, _) => Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'ProfileScreen'),
                  builder: (context) => const ProfileScreen(),
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.inputFill,
                backgroundImage: auth.profileImagePath != null
                    ? (kIsWeb
                        ? NetworkImage(auth.profileImagePath!) as ImageProvider
                        : FileImage(io.File(auth.profileImagePath!)) as ImageProvider)
                    : null,
                child: auth.profileImagePath == null
                    ? const Icon(Icons.person, color: AppColors.primary, size: 20)
                    : null,
              ),
            ),
          ),
        ),
        title: Image.asset(
          'assets/images/masoor_logo.png',
          height: 35,
          fit: BoxFit.contain,
        ),
        actions: [
          const LanguageSelector(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'CartScreen'),
                    builder: (context) => const CartScreen(),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) => cart.items.isEmpty
                      ? Container()
                      : CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            '${cart.totalItemCount}',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: TextField(
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: l10n.translate('searchHint'),
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    filled: false,
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),

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
                        color: isSelected ? AppColors.primary : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(
                        l10n.translate(key),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
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
          filteredFoodItems.isEmpty
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
                            return _buildFoodCard(filteredFoodItems[index], lang);
                          },
                          childCount: filteredFoodItems.length,
                        ),
                      );
                    },
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const SupportHubSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.support_agent, color: Colors.white),
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food, String lang) {
    return GestureDetector(
      onTap: () => _openFoodDetail(context, food),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                food.imageUrl,
                height: 140, // Reduced height to fit info better
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 140,
                    color: AppColors.inputFill,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: AppColors.inputFill,
                  child: const Icon(Icons.fastfood, color: AppColors.textSecondary, size: 50),
                ),
              ),
            ),
            
            // Info Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          food.localizedName(lang),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${food.price.toStringAsFixed(0)} ֏',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Row 2: Description
                  Text(
                    food.localizedDescription(lang),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Row 3: Prep Time and Unit
                  Row(
                    children: [
                      // Prep Time
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${food.prepTime} ${lang == 'en' ? 'min' : (lang == 'ru' ? 'мин' : 'րոպե')}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Unit
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '/ ${food.unit}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quantity Selector
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      CartItem? cartItem;
                      try {
                        cartItem = cart.items.firstWhere(
                          (item) => item.foodItem.id == food.id,
                        );
                      } catch (_) {
                        cartItem = null;
                      }
                      
                      final int quantity = cartItem?.quantity ?? 0;

                      return Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: quantity > 0
                                  ? () => cart.removeOneItemByFoodId(food.id)
                                  : null,
                              icon: Icon(
                                Icons.remove,
                                size: 18,
                                color: quantity > 0 ? AppColors.primary : AppColors.textSecondary,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => cart.addItem(
                                food, 
                                selectedSize: quantity == 0 ? food.sizes.first : cartItem!.selectedSize,
                              ),
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: AppColors.primary,
                              ),
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
