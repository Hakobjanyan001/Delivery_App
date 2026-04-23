class Address {
  final String? label;
  final String? address;
  final double? lat;
  final double? lng;

  Address({
    this.label,
    this.address,
    this.lat,
    this.lng,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      label: json['label'],
      address: json['address'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }
}