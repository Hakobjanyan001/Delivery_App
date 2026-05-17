import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoor/features/auth/providers/auth_provider.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import 'package:masoor/core/theme/custom_theme_extension.dart';

class ProfileCard extends StatelessWidget {
  final VoidCallback onEdit;

  const ProfileCard({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = Provider.of<LocalizationProvider>(context);
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: customColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Selector<AuthProvider, String?>(
                    selector: (_, auth) => auth.userName,
                    builder: (context, name, _) {
                      return Text(
                        name?.isNotEmpty == true ? name! : l10n.translate('user'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Selector<AuthProvider, String?>(
                    selector: (_, auth) => auth.phone,
                    builder: (context, phone, _) {
                      return Text(
                        phone ?? '+374 -- -- -- --',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.translate('editShort'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
