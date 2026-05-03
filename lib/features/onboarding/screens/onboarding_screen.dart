import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/localization_provider.dart';
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
    final onboardingProvider = context.watch<OnboardingProvider>();
    final localeProvider = context.watch<LocalizationProvider>();
    final lang = localeProvider.currentLocale.languageCode;
    final partner = onboardingProvider.partner;

    // Default slides if partner data is not available
    final List<Widget> defaultSlides = [
      OnboardingPageWidget(
        backgroundImage: 'assets/images/order_bg_1.png',
        isLogoPage: true,
        buttonText: localeProvider.translate('explore'),
        onButtonPressed: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        children: [
          Positioned(
            top: 355,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  localeProvider.translate('onboarding1'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
      OnboardingPageWidget(
        backgroundImage: 'assets/images/order_bg_2.jpg',
        buttonText: localeProvider.translate('next'),
        onButtonPressed: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
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
                Text(
                  localeProvider.translate('onboarding2'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      OnboardingPageWidget(
        backgroundImage: 'assets/images/order_bg_3.png',
        buttonText: localeProvider.translate('start'),
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
                Text(
                  localeProvider.translate('onboarding3'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    // Build dynamic slides if partner has onboarding data
    List<Widget> slides = defaultSlides;
    if (partner != null && partner.onboarding != null && partner.onboarding!.isNotEmpty) {
      slides = partner.onboarding!.asMap().entries.map((entry) {
        int idx = entry.key;
        var slide = entry.value;
        bool isLast = idx == partner.onboarding!.length - 1;

        return OnboardingPageWidget(
          backgroundImage: slide.image ?? '',
          isLogoPage: idx == 0,
          buttonText: isLast ? localeProvider.translate('start') : localeProvider.translate('next'),
          onButtonPressed: () {
            if (isLast) {
              context.read<OnboardingProvider>().setHasSeenOnboarding(true);
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
          children: [
            Positioned(
              bottom: 150,
              left: 20,
              right: 20,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    slide.text.get(lang),
                    textAlign: idx == 0 ? TextAlign.center : TextAlign.start,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: idx == 0 ? 16 : 24,
                      fontWeight: idx == 0 ? FontWeight.w600 : FontWeight.w900,
                      fontStyle: idx == 0 ? FontStyle.normal : FontStyle.italic,
                      fontFamily: 'Segoe UI',
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList();
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: slides,
      ),
    );
  }
}
