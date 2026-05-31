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
              Positioned(
                bottom: 150, // Both texts raised higher up together
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Primary title
                    const Text(
                      'Crafted with heart.\nBaked with fire.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Body text in exactly 3 lines as requested
                    const Opacity(
                      opacity: 1.0,
                      child: Text(
                        'From golden khachapuri to slow-simmered\nclassics, our kitchen serves tradition on every\nplate.',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Segoe UI',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.5, // 24px line-height / 16px font-size
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
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
              Positioned(
                bottom: 150,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Primary title
                    const Text(
                      'Your table is waiting.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle text
                    const Opacity(
                      opacity: 1.0,
                      child: Text(
                        'Browse the menu, book a table, or order your\nfavorites to go.',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Segoe UI',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
