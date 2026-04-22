// onborardingi 2 ejery miacnoxy irar het 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/onboarding_page_widget.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [

          // ej 1: 
          OnboardingPageWidget(
            backgroundImage: 'assets/images/order_bg_1.png',
            isLogoPage: true,
            buttonText: 'Explore Masoor',
            onButtonPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            children: [
              // Tagline
              const Positioned(
                top: 333,
                left: 40,
                right: 40,
                child: Center(
                  child: Text(
                    'Where every dish tells a story,\nand every guest leaves with one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Segoe UI',
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ej 2: 
          OnboardingPageWidget(
            backgroundImage: 'assets/images/order_bg_2.jpg',
            buttonText: 'Next',
            onButtonPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            children: [
              // Primary title
              Positioned(
                bottom: 175,
                left: 20,
                right: 20,
                child: Text(
                  'Crafted with heart. Baked with\nfire.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 1.1,
                  ),
                ),
              ),
              // Secondary tagline
              Positioned(
                bottom: 105,
                left: 20,
                right: 30,
                child: Text(
                  'From golden khachapuri to slow-simmered\nclassics, our kitchen serves tradition on every\nplate.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          // ej 3: 
          OnboardingPageWidget(
            backgroundImage: 'assets/images/order_bg_3.png',
            buttonText: 'Start',
            onButtonPressed: () {
              context.read<OnboardingProvider>().setHasSeenOnboarding(true);
            },
            children: [
              // Primary title
              Positioned(
                bottom: 175,
                left: 20,
                right: 20,
                child: Text(
                  'Your table is waiting.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 1.1,
                  ),
                ),
              ),
              // Secondary tagline
              Positioned(
                bottom: 115,
                left: 20,
                right: 60, // Increase padding to match image wrap
                child: Text(
                  'Browse the menu, book a table, or order your favorites to go.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
