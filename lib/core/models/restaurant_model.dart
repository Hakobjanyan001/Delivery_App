import 'common_models.dart';

class RestaurantModel {
  final String id;
  final String? ownerId;
  final LocalizedString name;
  final LocalizedString description;
  final String? logo;
  final List<String> coverImages;
  final bool isActive;
  final WorkingHours workingHours;
  final DeliverySettings delivery;

  RestaurantModel({
    required this.id,
    this.ownerId,
    required this.name,
    required this.description,
    this.logo,
    this.coverImages = const [],
    this.isActive = true,
    required this.workingHours,
    required this.delivery,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['_id'] ?? '',
      ownerId: json['ownerId']?.toString(),
      name: LocalizedString.fromJson(json['name'] ?? {}),
      description: LocalizedString.fromJson(json['description'] ?? {}),
      logo: json['logo'],
      coverImages: List<String>.from(json['coverImages'] ?? []),
      isActive: json['isActive'] ?? true,
      workingHours: WorkingHours.fromJson(json['workingHours'] ?? {}),
      delivery: DeliverySettings.fromJson(json['delivery'] ?? {}),
    );
  }
}

class WorkingHours {
  final String open;
  final String close;

  WorkingHours({
    required this.open,
    required this.close,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      open: json['open'] ?? '00:00',
      close: json['close'] ?? '00:00',
    );
  }
}

class DeliverySettings {
  final double basePrice;
  final bool multiCourierEnabled;
  final double freeDeliveryFrom;

  DeliverySettings({
    required this.basePrice,
    required this.multiCourierEnabled,
    required this.freeDeliveryFrom,
  });

  factory DeliverySettings.fromJson(Map<String, dynamic> json) {
    return DeliverySettings(
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      multiCourierEnabled: json['multiCourierEnabled'] ?? false,
      freeDeliveryFrom: (json['freeDeliveryFrom'] ?? 0).toDouble(),
    );
  }
}
