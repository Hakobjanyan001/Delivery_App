import './address_model.dart';

class AppUser {
  final String id; // Mongo _id
  final String name;
  final String username;
  final String email;
  final String? phone;
  final bool emailVerified;
  final String? firebaseUid;
  final String role;
  final bool is18Plus;
  final String language;
  final List<Address> addresses;

  AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    this.emailVerified = false,
    this.firebaseUid,
    this.role = 'client',
    this.is18Plus = false,
    this.language = 'hy',
    this.addresses = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      emailVerified: json['emailVerified'] ?? false,
      firebaseUid: json['firebaseUid'],
      role: json['role'] ?? 'client',
      is18Plus: json['is18Plus'] ?? false,
      language: json['language'] ?? 'hy',
      addresses: (json['addresses'] as List? ?? [])
          .map((e) => Address.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'emailVerified': emailVerified,
      'firebaseUid': firebaseUid,
      'role': role,
      'is18Plus': is18Plus,
      'language': language,
      'addresses': addresses.map((e) => e.toJson()).toList(),
    };
  }
}
