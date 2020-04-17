class User {
  final String id;
  final String email;
  final String phoneNumber;
  final String displayName;
  final String profileImageUrl;

  User({
    this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.profileImageUrl,
  });

  static fromPayload(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      displayName: json['displayName'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}
