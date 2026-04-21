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
            backgroundImage: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
            isLogoPage: true,
            buttonText: 'Explore Masoor',
            onButtonPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),

          // ej 2: 
          OnboardingPageWidget(
            backgroundImage: 'https://images.unsplash.com/photo-1543353071-873f17a7a088?w=800&q=80',
            buttonText: 'Next',
            onButtonPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),

          // ej 3: 
          OnboardingPageWidget(
            backgroundImage: 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=800&q=80', 
            buttonText: 'Start',
            onButtonPressed: () {
              context.read<OnboardingProvider>().setHasSeenOnboarding(true);
            },
          ),

        ],
      ),
    );
  }
}
