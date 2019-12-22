class User {
  final String id;
  final String email;
  final String phoneNumber;
  final String displayName;

  User({
    this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
  });

  static fromPayload(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      displayName: json['displayName'],
    );
  }
}
