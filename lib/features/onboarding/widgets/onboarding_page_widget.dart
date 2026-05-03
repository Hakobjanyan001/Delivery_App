// havelvaci araji ejy + shablon ejeri hmara vor chkrknvi nujn kody amen ekrani hma 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String backgroundImage;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final bool isLogoPage;
  final List<Widget>? children;

  const OnboardingPageWidget({
    super.key,
    required this.backgroundImage,
    required this.buttonText,
    required this.onButtonPressed,
    this.isLogoPage = false,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,

      child: Stack(
        children: [
          if (backgroundImage.startsWith('assets/'))
            Positioned.fill(
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.cover,
              ),
            )
          else if (backgroundImage.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                backgroundImage,
                fit: BoxFit.cover,
              ),
            ),

          if (backgroundImage.isNotEmpty)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.65),
              ),
            ),

          if (isLogoPage) ...[
            Positioned(
              top: 145,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 248,
                  height: 250,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Branch and MASOOR Logo
                      Center(
                        child: Consumer<OnboardingProvider>(
                          builder: (context, onboarding, _) {
                            final logo = onboarding.partner?.logo;
                            if (logo != null && logo.isNotEmpty) {
                              return Image.network(
                                logo,
                                width: 248,
                                height: 165,
                                fit: BoxFit.contain,
                              );
                            }
                            return Image.asset(
                              'assets/images/masoor_branch.png',
                              width: 248,
                              height: 165,
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                      ),
                      // "Welcome to" text positioned above the word MASOOR
                      Positioned(
                        top: 100,
                        right: 20,
                        child: Text(
                          'Welcome to',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Segoe UI',
                          ),
                        ),

                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          if (children != null) ...children!,

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),

                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}