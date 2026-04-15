import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:provider/provider.dart';
import '../../../core/models/food_model.dart';
import '../../../core/localization/localization_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/profile_screen.dart';
import '../../support/widgets/support_hub_sheet.dart';
import '../widgets/food_detail_dialog.dart';
import '../../../core/localization/widgets/language_selector.dart';

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
  // Restaurant List (shown when catAll)
  // ======================================
  final List<Restaurant> allRestaurants = [
    Restaurant(id: '1', name: 'Tashir Pizza', rating: 4.5,
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80',
        category: 'Pizza', price: 700),
    Restaurant(id: '2', name: 'Burger House', rating: 4.2,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
        category: 'Burger', price: 900),
    Restaurant(id: '3', name: 'Jazz Sushi', rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80',
        category: 'Sushi', price: 1500),
  ];

  // ======================================
  // Food Items per category
  // ======================================
  final Map<String, List<FoodItem>> _foodByCategory = {
    'Shaurma': [
      FoodItem(id: 'sh_1', name: 'Հավի Շաուրմա (Մեծ)', price: 1100, category: 'Shaurma',
          imageUrl: 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500&q=80',
          availableOptions: ['Կծու', 'Առանց սոխի', 'Լրացուցիչ մայոնեզ']),
      FoodItem(id: 'sh_2', name: 'Տավարի Շաուրմա (Մեծ)', price: 1400, category: 'Shaurma',
          imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500&q=80',
          availableOptions: ['Կծու', 'Պանիրով', 'Կրկնակի միս']),
    ],
    'Barbecue': [
      FoodItem(id: 'bbq_1', name: 'Խոզի Խորոված (Չալաղաջ)', price: 3500, category: 'Barbecue',
          imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80',
          availableOptions: ['Սոխով', 'Առանց սոխի', 'Կծու աջիկա']),
      FoodItem(id: 'bbq_2', name: 'Տավարի Քյաբաբ', price: 900, category: 'Barbecue',
          imageUrl: 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=500&q=80',
          availableOptions: ['Լավաշով', 'Պանիրով']),
    ],
    'KFC': [
      FoodItem(id: 'kfc_1', name: 'Sanders Bucket', price: 5500, category: 'KFC',
          imageUrl: 'https://images.unsplash.com/photo-1513639776629-7b61b0ac49cb?w=500&q=80',
          availableOptions: ['Կծու', 'Original']),
      FoodItem(id: 'kfc_2', name: 'Zinger Burger', price: 1300, category: 'KFC',
          imageUrl: 'https://images.unsplash.com/photo-1513185158878-8d8c182b013f?w=500&q=80',
          availableOptions: ['Կրկնակի պանիր', 'Կծու']),
    ],
    'Pizza': [
      FoodItem(
        id: 'pizza_1',
        name: 'Մարգարիտա',
        price: 1800,
        category: 'Pizza',
        imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&q=80',
        sizes: ['Փոքր', 'Մեծ'],
        sizePrices: [1800, 3000],
        slicePrice: 250,
        availableOptions: ['Կծու', 'Կրկնակի պանիր', 'Առանց ձիթապտղի'],
      ),
      FoodItem(
        id: 'pizza_2',
        name: 'Pepperoni',
        price: 2200,
        category: 'Pizza',
        imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500&q=80',
        sizes: ['Փոքր', 'Մեծ'],
        sizePrices: [2200, 3500],
        slicePrice: 300,
        availableOptions: ['Կծու', 'Կրկնակի pepperoni', 'Բարակ խմոր'],
      ),
      FoodItem(
        id: 'pizza_3',
        name: '4 Cheese',
        price: 2500,
        category: 'Pizza',
        imageUrl: 'https://images.unsplash.com/photo-1548600916-dc8492f8e845?w=500&q=80',
        sizes: ['Փոքր', 'Մեծ'],
        sizePrices: [2500, 4000],
        slicePrice: 350,
        availableOptions: ['Կծու', 'Առանց mozzarella'],
      ),
      FoodItem(
        id: 'pizza_4',
        name: 'Veggie',
        price: 1600,
        category: 'Pizza',
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&q=80',
        sizes: ['Փոքր', 'Մեծ'],
        sizePrices: [1600, 2800],
        slicePrice: 200,
        availableOptions: ['Կծու', 'Kրկնակի բանջարեղեն', 'Առանց սնկի'],
      ),
    ],
    'Burger': [
      FoodItem(id: 'burger_1', name: 'Classic Burger', price: 1200, category: 'Burger',
          imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
          sizes: ['Փոքր', 'Մեծ'],
          availableOptions: ['Կծու', 'Կրկնակի կոտլետ', 'Առանց կոճապղպեղ', 'Կրկնակի պանիր']),
      FoodItem(id: 'burger_2', name: 'Cheese Burger', price: 1400, category: 'Burger',
          imageUrl: 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=500&q=80',
          sizes: ['Փոքր', 'Մեծ'],
          availableOptions: ['Կծու', 'Կրկնակի պանիր', 'Առանց թթու վարունգ']),
      FoodItem(id: 'burger_3', name: 'BBQ Burger', price: 1600, category: 'Burger',
          imageUrl: 'https://images.unsplash.com/photo-1596662951482-0bc71f5e0ea0?w=500&q=80',
          sizes: ['Փոքր', 'Մեծ'],
          availableOptions: ['Կծու', 'Կրկնակի BBQ sauce']),
      FoodItem(id: 'burger_4', name: 'Chicken Burger', price: 1100, category: 'Burger',
          imageUrl: 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=500&q=80',
          sizes: ['Փոքր', 'Մեծ'],
          availableOptions: ['Կծու', 'Crispy', 'Grilled']),
    ],
    'Sushi': [
      FoodItem(id: 'sushi_1', name: 'Salmon Roll', price: 3200, category: 'Sushi',
          imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=500&q=80',
          sizes: ['6 հատ', '12 հատ'],
          availableOptions: ['Կծու', 'Կրկնակի salmon', 'Wasabi-ով']),
      FoodItem(id: 'sushi_2', name: 'Rainbow Roll', price: 4500, category: 'Sushi',
          imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80',
          sizes: ['6 հատ', '12 հատ'],
          availableOptions: ['Կծու', 'Wasabi-ով', 'Cucumber ավելացնել']),
      FoodItem(id: 'sushi_3', name: 'Dragon Roll', price: 5000, category: 'Sushi',
          imageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=500&q=80',
          sizes: ['6 հատ', '12 հատ'],
          availableOptions: ['Կծու', 'Avocado-ով']),
    ],
    'FastFood': [
      FoodItem(id: 'ff_1', name: 'French Fries', price: 600, category: 'FastFood',
          imageUrl: 'https://images.unsplash.com/photo-1630384066272-1177f6f53d8d?w=500&q=80',
          availableOptions: ['Կետչուպով', 'Մայոնեզով', 'Պանրի սոուսով']),
    ],
    'Combo': [
      FoodItem(id: 'combo_1', name: 'Family Combo Deal', price: 8500, category: 'Combo',
          imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80',
          availableOptions: ['Pepsi', 'Coca-Cola', 'Fanta']),
    ],
    'Italian': [
      FoodItem(id: 'ital_1', name: 'Lasagna alla Bolognese', price: 2800, category: 'Italian',
          imageUrl: 'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=500&q=80',
          availableOptions: ['Լրացուցիչ պանիր', 'Կծու']),
      FoodItem(id: 'ital_2', name: 'Spaghetti Carbonara', price: 2400, category: 'Italian',
          imageUrl: 'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=500&q=80'),
    ],
    'Korean': [
      FoodItem(id: 'kor_1', name: 'Bibimbap', price: 3200, category: 'Korean',
          imageUrl: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500&q=80',
          availableOptions: ['Կծու', 'Ձվով']),
    ],
    'Sandwiches': [
      FoodItem(id: 'sw_1', name: 'Sub Club Sandwich', price: 1200, category: 'Sandwiches',
          imageUrl: 'https://images.unsplash.com/photo-1554433607-66b5efe9d304?w=500&q=80',
          availableOptions: ['Տավարի մսով', 'Հավի մսով']),
    ],
    'HotMeals': [
      FoodItem(id: 'hm_1', name: 'Beef Stroganoff', price: 2500, category: 'HotMeals',
          imageUrl: 'https://images.unsplash.com/photo-1534080564583-6be75777b70a?w=500&q=80'),
    ],
    'Dessert': [
      FoodItem(id: 'dessert_1', name: 'Chocolate Lava Cake', price: 800, category: 'Dessert',
          imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500&q=80',
          sizes: ['1 հատ', '2 հատ'],
          availableOptions: ['Ice cream-ով', 'Վanilla sauce-ով']),
      FoodItem(id: 'dessert_2', name: 'Tiramisu', price: 900, category: 'Dessert',
          imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=500&q=80',
          sizes: ['1 հատ'],
          availableOptions: ['Կրկնակի cocoa', 'Raspberry-ով']),
      FoodItem(id: 'dessert_3', name: 'Cheesecake', price: 850, category: 'Dessert',
          imageUrl: 'https://images.unsplash.com/photo-1524351199678-941a58a3df50?w=500&q=80',
          sizes: ['1 հատ'],
          availableOptions: ['Strawberry-ով', 'Blueberry-ով', 'Caramel sauce-ով']),
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
      return res.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  List<FoodItem> get filteredFoodItems {
    final List<FoodItem> allItems = _foodByCategory.values.expand((list) => list).toList();
    if (selectedCategoryKey == 'catAll') {
      return allItems.where((f) => f.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    final category = _mapToInternal(selectedCategoryKey);
    final items = _foodByCategory[category] ?? [];
    return items.where((f) => f.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Consumer<AuthProvider>(
          builder: (context, auth, _) => Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue[100],
                backgroundImage: auth.profileImagePath != null
                    ? (kIsWeb
                        ? NetworkImage(auth.profileImagePath!) as ImageProvider
                        : FileImage(io.File(auth.profileImagePath!)) as ImageProvider)
                    : null,
                child: auth.profileImagePath == null
                    ? Icon(Icons.person, color: Colors.blue[900], size: 20)
                    : null,
              ),
            ),
          ),
        ),
        title: Text(
          l10n.translate('appName'),
          style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          const LanguageSelector(),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.blue[900]),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: l10n.translate('searchHint'),
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.blue[900]),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(l10n.translate('categoriesTitle'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            SizedBox(
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
                        color: isSelected ? Colors.blue[900] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.translate(key),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.blue[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ---- FOOD ITEMS GRID ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                l10n.translate(selectedCategoryKey),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            
            filteredFoodItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(l10n.translate('noResults'),
                            style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ]),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount;
                      double childAspectRatio;
                      final width = constraints.maxWidth;
                      if (width > 1100) {
                        crossAxisCount = 4;
                        childAspectRatio = 0.78;
                      } else if (width > 750) {
                        crossAxisCount = 3;
                        childAspectRatio = 0.80;
                      } else if (width > 520) {
                        crossAxisCount = 2;
                        childAspectRatio = 0.82;
                      } else {
                        crossAxisCount = 1;
                        childAspectRatio = 1.8;
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredFoodItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          return _buildFoodCard(filteredFoodItems[index]);
                        },
                      );
                    },
                  ),

            const SizedBox(height: 80),
          ],
        ),
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
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.support_agent, color: Colors.white),
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food) {
    return GestureDetector(
      onTap: () => _openFoodDetail(context, food),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                food.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Icon(Icons.fastfood, color: Colors.grey[400], size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text('${food.price.toStringAsFixed(0)} ֏',
                            style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _openFoodDetail(context, food),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Ավելացնել', style: TextStyle(fontSize: 14)),
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
