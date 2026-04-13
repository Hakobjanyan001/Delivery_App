import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/food_model.dart';
import '../../../core/localization/localization_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategoryKey = 'catAll';
  String searchQuery = '';

  final List<String> categoryKeys = ['catAll', 'catPizza', 'catBurger', 'catSushi', 'catPasta', 'catDessert'];

  final List<Restaurant> allRestaurants = [
    Restaurant(
      id: '1',
      name: 'Tashir Pizza ',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80',
      category: 'Pizza',
      price: 1200,
    ),
    Restaurant(
      id: '2',
      name: 'Burger',
      rating: 4.2,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
      category: 'Burger',
      price: 740,
    ),
    Restaurant(
      id: '3',
      name: 'Jazz Sushi',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80',
      category: 'Sushi',
      price: 9700,
    ),
  ];

  // Map Category Keys back to internal English identifiers for filtering
  String? _mapToInternal(String key) {
    switch (key) {
      case 'catPizza': return 'Pizza';
      case 'catBurger': return 'Burger';
      case 'catSushi': return 'Sushi';
      case 'catPasta': return 'Pasta';
      case 'catDessert': return 'Dessert';
      default: return null;
    }
  }

  List<Restaurant> get filteredRestaurants {
    final internalCategory = _mapToInternal(selectedCategoryKey);
    
    return allRestaurants.where((res) {
      bool matchesCategory = internalCategory == null || res.category == internalCategory;
      bool matchesSearch = res.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.translate('appName'),
          style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language, color: Colors.blue),
            onSelected: (Locale locale) {
              l10n.setLocale(locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(
                value: Locale('hy'),
                child: Text('🇦🇲 Հայերեն'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('en'),
                child: Text('🇺🇸 English'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('ru'),
                child: Text('🇷🇺 Русский'),
              ),
            ],
          ),
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
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
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
              child: Text(
                l10n.translate('categoriesTitle'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
                    onTap: () {
                      setState(() {
                        selectedCategoryKey = key;
                      });
                    },
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

            // Restaurant Title
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                l10n.translate('popularRestaurants'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Vertical Restaurant List
            filteredRestaurants.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            l10n.translate('noResults'),
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      return RestaurantCard(restaurant: filteredRestaurants[index]);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
