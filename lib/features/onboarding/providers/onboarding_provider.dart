// hishuma ogtatery tesela masoor-i canotutyan ejy , vor hajord baceluc el cuy  chta 

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/partner_model.dart';
import '../../../core/services/api_services.dart';
import '../../../core/utils/web_utils.dart';

class OnboardingProvider with ChangeNotifier {
    static const String _onboardingKey = 'has_seen_onboarding';

    bool _hasSeenOnboarding = false;
    bool get hasSeenOnboarding {
        if (kIsWeb) return true;
        if (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux) {
            return true;
        }
        return _hasSeenOnboarding;
    }

    PartnerModel? _partner;
    PartnerModel? get partner => _partner;

    bool _isLoading = false;
    bool get isLoading => _isLoading;

    OnboardingProvider() {
        loadHasSeenOnboarding();
        fetchPartnerDetails();
    }   

    Future<void> fetchPartnerDetails() async {
        _isLoading = true;
        notifyListeners();
        try {
            final data = await ApiManager().getPartnerDetails();
            _partner = PartnerModel.fromJson(data);
            
            // Update Web Favicon and Title
            if (kIsWeb && _partner != null) {
                if (_partner!.favicon != null) {
                    WebUtils.updateFavicon(_partner!.favicon!);
                }
                final name = _partner!.name.en ?? _partner!.name.hy ?? _partner!.name.ru ?? 'MASOOR';
                WebUtils.updateTitle(name);
            }
        } catch (e) {
            debugPrint('Error fetching partner details: $e');
        } finally {
            _isLoading = false;
            notifyListeners();
        }
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
