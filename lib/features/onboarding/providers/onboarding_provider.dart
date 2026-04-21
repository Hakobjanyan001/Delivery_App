// hishuma ogtatery tesela masoor-i canotutyan ejy , vor hajord baceluc el cuy  chta 

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
    static const String _onboardingKey = 'has_seen_onboarding';

    bool _hasSeenOnboarding = false;
    bool get hasSeenOnboarding => _hasSeenOnboarding;

    OnboardingProvider() {
        loadHasSeenOnboarding();
    }   

    Future<void> loadHasSeenOnboarding() async {
        final prefs = await SharedPreferences.getInstance();
        _hasSeenOnboarding = prefs.getBool(_onboardingKey) ?? false;
        notifyListeners();
    }

    Future<void> setHasSeenOnboarding(bool value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_onboardingKey, value);
        _hasSeenOnboarding = value;
        notifyListeners();
    }
}
