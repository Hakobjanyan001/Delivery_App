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
            buttonText: 'Explore',
            onButtonPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            children: [
              // Tagline
              const Positioned(
                top: 355,
                left: 0,
                right: 0,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Where every dish tells a story, and every guest leaves with one.',
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
              const Positioned(
                bottom: 175,
                left: 20,
                right: 20,
                child: Text(
                  'Crafted with heart. Baked with fire.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 1.1,
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
              const Positioned(
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
            ],
          ),
        ],
      ),
    );
  }
}
