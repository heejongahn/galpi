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

  Map<String, dynamic> toMap() {
    final map = new Map<String, dynamic>.from({});

    map['id'] = id;
    map['email'] = email;
    map['phoneNumber'] = phoneNumber;
    map['displayName'] = displayName;
    map['profileImageUrl'] = profileImageUrl;

    return map;
  }
}
