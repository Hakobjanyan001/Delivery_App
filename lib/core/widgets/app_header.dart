import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:masoor/features/onboarding/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Theme.of(context).appBarTheme.backgroundColor,

          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<OnboardingProvider>(
                    builder: (context, onboarding, _) {
                      final logo = onboarding.partner?.logo;
                      if (logo != null && logo.isNotEmpty) {
                        return Image.network(
                          logo,
                          width: 72,
                          height: 48,
                          fit: BoxFit.contain,
                        );
                      }
                      return Image.asset(
                        'assets/images/masoor_branch.png',
                        width: 72,
                        height: 48,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  Consumer<OnboardingProvider>(
                    builder: (context, onboarding, _) {
                      final phone = onboarding.partner?.phone ?? '+374 60 515515';
                      final telUri = 'tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}';
                      
                      return GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(telUri);
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(40),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_outlined, color: Theme.of(context).colorScheme.onSurface, size: 20),

                              const SizedBox(width: 8),
                              Text(
                                phone,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),

                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
