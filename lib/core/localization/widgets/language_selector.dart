import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization_provider.dart';

class LanguageSelector extends StatelessWidget {
  final Color? color;

  const LanguageSelector({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);

    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: PopupMenuButton<Locale>(
        initialValue: l10n.currentLocale,
        offset: const Offset(0, -140), // Opens above the button
        color: Theme.of(context).colorScheme.surface,
        elevation: 8,
        tooltip: '',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), width: 1),
        ),

        constraints: const BoxConstraints(minWidth: 76, maxWidth: 76),
        onSelected: (Locale locale) {
          l10n.setLocale(locale);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
          const PopupMenuItem<Locale>(
            value: Locale('hy'),
            height: 44,
            padding: EdgeInsets.zero,
            child: Center(child: Text('🇦🇲', style: TextStyle(fontSize: 24))),
          ),
          const PopupMenuItem<Locale>(
            value: Locale('en'),
            height: 44,
            padding: EdgeInsets.zero,
            child: Center(child: Text('🇺🇸', style: TextStyle(fontSize: 24))),
          ),
          const PopupMenuItem<Locale>(
            value: Locale('ru'),
            height: 44,
            padding: EdgeInsets.zero,
            child: Center(child: Text('🇷🇺', style: TextStyle(fontSize: 24))),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, color: color ?? Theme.of(context).colorScheme.onSurface, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.currentLocale.languageCode.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
