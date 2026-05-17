import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoor/features/auth/providers/auth_provider.dart';
import 'package:masoor/core/localization/localization_provider.dart';
import 'package:masoor/core/theme/custom_theme_extension.dart';

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final l10n = Provider.of<LocalizationProvider>(context);
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return GestureDetector(
      onTap: auth.logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: customColors.logoutBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: customColors.logoutBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: customColors.logoutText, size: 18),
            const SizedBox(width: 10),
            Text(
              l10n.translate('logout'),
              style: TextStyle(
                color: customColors.logoutText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
