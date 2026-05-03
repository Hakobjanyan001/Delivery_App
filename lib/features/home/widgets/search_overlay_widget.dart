import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/localization/localization_provider.dart';
import '../providers/home_provider.dart';

class SearchOverlayWidget extends StatefulWidget {
  final VoidCallback onClose;
  final bool isSearchActive;
  const SearchOverlayWidget({
    super.key, 
    required this.onClose,
    required this.isSearchActive,
  });

  @override
  State<SearchOverlayWidget> createState() => _SearchOverlayWidgetState();
}

class _SearchOverlayWidgetState extends State<SearchOverlayWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.isSearchActive) {
      _triggerFocus();
    }
  }

  void _triggerFocus() {
    // Attempt 1: Immediate post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
    
    // Attempt 2: After a short delay (for animation transition)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && widget.isSearchActive) {
        _focusNode.requestFocus();
      }
    });

    // Attempt 3: After animation completes
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && widget.isSearchActive) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(SearchOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
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

    // Sync controller with query if updated externally
    if (_controller.text != searchProvider.searchQuery) {
      _controller.text = searchProvider.searchQuery;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: widget.onClose,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              onChanged: (value) => searchProvider.updateQuery(value, homeProvider.restaurants, homeProvider.products),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
              decoration: InputDecoration(
                hintText: l10n.translate('searchHint'),
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                suffixIcon: searchProvider.searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), size: 20),
                      onPressed: () {
                        _controller.clear();
                        searchProvider.updateQuery('', homeProvider.restaurants, homeProvider.products);
                      },
                    )
                  : null,
              ),
            ),
          ),
        ],
      ),
    ));

  }
}
