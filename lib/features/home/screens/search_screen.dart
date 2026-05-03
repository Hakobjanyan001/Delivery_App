import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_header.dart';
import '../providers/home_provider.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/restaurant_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _backHovered = false;

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
    final homeProvider = Provider.of<HomeProvider>(context);

    if (_controller.text != searchProvider.searchQuery && !searchProvider.isLoading) {
      _controller.text = searchProvider.searchQuery;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppTextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      hintText: l10n.translate('searchHint'),
                      onChanged: (value) => searchProvider.updateQuery(
                          value, homeProvider.restaurants, homeProvider.products),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      prefixIcon: MouseRegion(
                        onEnter: (_) => setState(() => _backHovered = true),
                        onExit: (_) => setState(() => _backHovered = false),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 52,
                            height: 48,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: _backHovered ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(80),
                            ),

                            child: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),

                          ),
                        ),
                      ),
                      suffixIcon: searchProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),

                              onPressed: () {
                                _controller.clear();
                                searchProvider.updateQuery(
                                    '', homeProvider.restaurants, homeProvider.products);
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (searchProvider.isLoading)
                    const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Colors.orange,
                    ),
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
                                    Icon(Icons.search,
                                        size: 60,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),

                                    const SizedBox(height: 16),
                                    Text(
                                      searchProvider.searchQuery.isEmpty
                                          ? 'Մուտքագրեք անունը...'
                                          : 'Ոչինչ չի գտնվել',
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
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
                              return SearchResultTile(
                                  item: searchProvider.searchResults[index]);
                            },
                          ),
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

class SearchResultTile extends StatelessWidget {
  final dynamic item;
  const SearchResultTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isRestaurant = item is RestaurantModel;
    final l10n = Provider.of<LocalizationProvider>(context, listen: false);
    final lang = l10n.currentLocale.languageCode;
    
    final imageUrl = isRestaurant ? (item as RestaurantModel).logo ?? '' : (item as ProductModel).mainImageUrl;
    final name = isRestaurant ? (item as RestaurantModel).name.getLocalized(lang) : (item as ProductModel).name.getLocalized(lang);
    final subtitle = isRestaurant ? 'Ռեստորան' : 'Ուտեստ • ${(item as ProductModel).displayPrice} ֏';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: imageUrl.isNotEmpty ? DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ) : null,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),

      ),
      title: Text(
        name,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
      ),

      subtitle: Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
      ),

      trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),

      onTap: () {
        // Այստեղ կարող եք ավելացնել անցումը դեպի մանրամասն էկրան
      },
    );
  }
}