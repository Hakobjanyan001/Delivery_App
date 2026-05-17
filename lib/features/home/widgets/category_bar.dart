import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/category_model.dart';
import '../../../core/localization/localization_provider.dart';

class CategoryBar extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String lang;
  final ScrollController scrollController;
  final void Function(String?) onSelected;

  const CategoryBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.lang,
    required this.scrollController,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _CategoryBarDelegate(
        categories: categories,
        selectedCategoryId: selectedCategoryId,
        lang: lang,
        scrollController: scrollController,
        onSelected: onSelected,
      ),
    );
  }
}

class _CategoryBarDelegate extends SliverPersistentHeaderDelegate {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String lang;
  final ScrollController scrollController;
  final void Function(String?) onSelected;

  const _CategoryBarDelegate({
    required this.categories,
    required this.selectedCategoryId,
    required this.lang,
    required this.scrollController,
    required this.onSelected,
  });

  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: categories.length + 1,
            itemBuilder: (context, i) {
              final isAll = i == 0;
              final isSelected = isAll
                  ? selectedCategoryId == null
                  : selectedCategoryId == categories[i - 1].id;
              final label = isAll
                  ? Provider.of<LocalizationProvider>(context, listen: false).translate('catAll')
                  : categories[i - 1].name.getLocalized(lang);
              return GestureDetector(
                onTap: () => onSelected(isAll ? null : categories[i - 1].id),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                    border: isSelected
                        ? null
                        : Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).colorScheme.surface, offset: const Offset(0, 4), blurRadius: 0),
                    ],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryBarDelegate old) =>
      old.selectedCategoryId != selectedCategoryId ||
      old.categories.length != categories.length;
}
