// havelvaci araji ejy + shablon ejeri hmara vor chkrknvi nujn kody amen ekrani hma 

import 'package:flutter/material.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String backgroundImage;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final bool isLogoPage;

  const OnboardingPageWidget({
    super.key,
    required this.backgroundImage,
    required this.buttonText,
    required this.onButtonPressed,
    this.isLogoPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A), // Dark background color
      ),

      child: Stack(
        children: [
          if (isLogoPage)
            Center(
              child: Image.asset(
                'assets/images/masoor_branch.png',
                width: 280,
              ),
            ),



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
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    foregroundColor: Colors.black,
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