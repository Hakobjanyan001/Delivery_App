import 'common_models.dart';

class BannerModel {
  final String id;
  final LocalizedString title;
  final LocalizedString description;
  final String? image;
  final String? link;
  final String? restaurantId;
  final int order;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.link,
    this.restaurantId,
    required this.order,
    this.isActive = true,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] ?? '',
      title: LocalizedString.fromJson(json['title'] ?? {}),
      description: LocalizedString.fromJson(json['description'] ?? {}),
      image: json['image'],
      link: json['link'],
      restaurantId: json['restaurantId'],
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title.toJson(),
      'description': description.toJson(),
      'image': image,
      'link': link,
      'restaurantId': restaurantId,
      'order': order,
      'isActive': isActive,
    };
  }
}
