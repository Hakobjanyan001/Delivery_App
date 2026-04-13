import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization_provider.dart';

class LanguageSelector extends StatelessWidget {
  final Color? color;

  const LanguageSelector({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);

    return PopupMenuButton<Locale>(
      icon: Icon(Icons.language, color: color ?? Colors.blue),
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
    );
  }
}
