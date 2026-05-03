class PartnerModel {
  final String id;
  final LocalizedString name;
  final LocalizedString description;
  final String? logo;
  final String? favicon;
  final String? phone;
  final List<OnboardingSlide>? onboarding;

  PartnerModel({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    this.favicon,
    this.phone,
    this.onboarding,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['_id'],
      name: LocalizedString.fromJson(json['name'] ?? {}),
      description: LocalizedString.fromJson(json['description'] ?? {}),
      logo: json['logo'],
      favicon: json['favicon'],
      phone: json['phone'],
      onboarding: json['onboarding'] != null
          ? (json['onboarding'] as List).map((i) => OnboardingSlide.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'description': description.toJson(),
      'logo': logo,
      'favicon': favicon,
      'phone': phone,
      'onboarding': onboarding?.map((i) => i.toJson()).toList(),
    };
  }
}

class OnboardingSlide {
  final String? image;
  final LocalizedString text;

  OnboardingSlide({this.image, required this.text});

  factory OnboardingSlide.fromJson(Map<String, dynamic> json) {
    return OnboardingSlide(
      image: json['image'],
      text: LocalizedString.fromJson(json['text']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'text': text.toJson(),
    };
  }
}

class LocalizedString {
  final String? en;
  final String? ru;
  final String? hy;

  LocalizedString({this.en, this.ru, this.hy});

  factory LocalizedString.fromJson(Map<String, dynamic> json) {
    return LocalizedString(
      en: json['en'],
      ru: json['ru'],
      hy: json['hy'],
    );
  }

  String get(String lang) {
    switch (lang) {
      case 'ru':
        return ru ?? en ?? hy ?? '';
      case 'hy':
        return hy ?? en ?? ru ?? '';
      default:
        return en ?? ru ?? hy ?? '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ru': ru,
      'hy': hy,
    };
  }
}
