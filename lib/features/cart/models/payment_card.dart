class PaymentCard {
  final String id;
  final String last4;
  final String brand;
  final String expiryDate; // MM/YY

  PaymentCard({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'last4': last4,
        'brand': brand,
        'expiryDate': expiryDate,
      };

  factory PaymentCard.fromJson(Map<String, dynamic> json) => PaymentCard(
        id: json['id'],
        last4: json['last4'],
        brand: json['brand'],
        expiryDate: json['expiryDate'],
      );
}
