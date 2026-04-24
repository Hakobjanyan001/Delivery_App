import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/models/food_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context);

    if (_controller.text != searchProvider.searchQuery && !searchProvider.isLoading) {
      _controller.text = searchProvider.searchQuery;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Logo
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/masoor_branch.png',
                  width: 72,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: (value) => searchProvider.updateQuery(value),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: l10n.translate('searchHint') ?? 'Փնտրել...',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (searchProvider.searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () {
                          _controller.clear();
                          searchProvider.updateQuery('');
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Loading indicator
            if (searchProvider.isLoading)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Colors.orange,
              ),

            // Results list
            Expanded(
              child: searchProvider.searchResults.isEmpty && !searchProvider.isLoading
                ? GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 60, color: Colors.white.withValues(alpha: 0.1)),
                            const SizedBox(height: 16),
                            Text(
                              searchProvider.searchQuery.isEmpty 
                                ? 'Մուտքագրեք անունը...' 
                                : 'Ոչինչ չի գտնվել',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: searchProvider.searchResults.length,
                    itemBuilder: (context, index) {
                      final item = searchProvider.searchResults[index];
                      return SearchResultTile(item: item);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final dynamic item;
  const SearchResultTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isRestaurant = item is Restaurant;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(item.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        item.name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        isRestaurant ? 'Ռեստորան' : 'Ուտեստ • ${item.price} ֏',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: () {
        // Այստեղ կարող եք ավելացնել անցումը դեպի մանրամասն էկրան
      },
    );
  }
}