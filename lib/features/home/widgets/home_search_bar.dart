import 'package:flutter/material.dart';
import '../../../core/localization/localization_provider.dart';
import '../screens/search_screen.dart';

class HomeSearchBar extends StatelessWidget {
  final LocalizationProvider l10n;

  const HomeSearchBar({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          settings: const RouteSettings(name: 'SearchScreen'),
          pageBuilder: (context, a1, a2) => const SearchScreen(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(80),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.translate('searchHint') ?? 'Փնտրել...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
