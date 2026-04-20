class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isAnonymous;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.isAnonymous = false,
  });

  factory AppUser.mock() {
    return AppUser(
      uid: 'mock-uid-123',
      email: 'test@example.com',
      displayName: 'Test User',
      phoneNumber: '+374 99 999999',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'isAnonymous': isAnonymous,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }
}
