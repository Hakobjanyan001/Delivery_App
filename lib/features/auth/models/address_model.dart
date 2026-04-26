class Address {
  final String? id;
  final String? label;
  final String? address;
  final double? lat;
  final double? lng;

  Address({
    this.id,
    this.label,
    this.address,
    this.lat,
    this.lng,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] ?? json['id'],
      label: json['label'],
      address: json['address'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'label': label,
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }
}