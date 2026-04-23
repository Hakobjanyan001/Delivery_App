class LocalizedString {
  final String en;
  final String ru;
  final String hy;

  LocalizedString({
    required this.en,
    required this.ru,
    required this.hy,
  });

  factory LocalizedString.fromJson(Map<String, dynamic> json) {
    return LocalizedString(
      en: json['en'] ?? '',
      ru: json['ru'] ?? '',
      hy: json['hy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ru': ru,
      'hy': hy,
    };
  }

  String getLocalized(String langCode) {
    switch (langCode) {
      case 'en': return en.isNotEmpty ? en : (hy.isNotEmpty ? hy : ru);
      case 'ru': return ru.isNotEmpty ? ru : (hy.isNotEmpty ? hy : en);
      case 'hy': return hy.isNotEmpty ? hy : (en.isNotEmpty ? en : ru);
      default: return hy;
    }
  }
}
