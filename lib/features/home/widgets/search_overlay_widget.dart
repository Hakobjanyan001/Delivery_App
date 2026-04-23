import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/localization/localization_provider.dart';

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
    // Request focus on the next frame to allow animation to start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(SearchOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSearchActive && !oldWidget.isSearchActive) {
      // Request focus when search becomes active
      // Increased delay to ensure animation has progressed (matching AnimatedOpacity/Positioned)
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && widget.isSearchActive) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      });
    } else if (!widget.isSearchActive && oldWidget.isSearchActive) {
      // Unfocus when search becomes inactive
      _focusNode.unfocus();
    }
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

    // Sync controller with query if updated externally
    if (_controller.text != searchProvider.searchQuery) {
      _controller.text = searchProvider.searchQuery;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onClose,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (value) => searchProvider.updateQuery(value),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: l10n.translate('searchHint'),
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          if (searchProvider.searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
              onPressed: () {
                _controller.clear();
                searchProvider.updateQuery('');
              },
            ),
        ],
      ),
    );
  }
}
