class AddressModel {
  final String id;
  final String title;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? entrance;
  final String? floor;
  final String? apartment;

  AddressModel({
    required this.id,
    required this.title,
    required this.address,
    this.latitude,
    this.longitude,
    this.entrance,
    this.floor,
    this.apartment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'entrance': entrance,
      'floor': floor,
      'apartment': apartment,
    };
  }
}
