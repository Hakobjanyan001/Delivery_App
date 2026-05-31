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
        color: const Color(0xFF1F1F1F),
        elevation: 8,
        tooltip: '',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
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
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, color: color ?? Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.currentLocale.languageCode.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
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
