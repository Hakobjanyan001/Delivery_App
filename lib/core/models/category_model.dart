import 'common_models.dart';

class CategoryModel {
  final String id;
  final String? parentId;
  final LocalizedString name;
  final String? image;
  final int order;
  final List<CategoryModel> allChildren;

  CategoryModel({
    required this.id,
    this.parentId,
    required this.name,
    this.image,
    required this.order,
    this.allChildren = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      parentId: json['parentId'],
      name: LocalizedString.fromJson(json['name'] ?? {}),
      image: json['image'],
      order: json['order'] ?? 0,
      allChildren: (json['allChildren'] as List? ?? [])
          .map((child) => CategoryModel.fromJson(child))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'parentId': parentId,
      'name': name.toJson(),
      'image': image,
      'order': order,
      'allChildren': allChildren.map((e) => e.toJson()).toList(),
    };
  }
}
