class User {
  final String id;
  final String email;
  final String phoneNumber;
  final String displayName;
  final String introduction;
  final String profileImageUrl;

  User({
    this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.introduction,
    this.profileImageUrl,
  });

  static User fromPayload(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      displayName: json['displayName'] as String,
      introduction: json['introduction'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, String>{};

    map['id'] = id;
    map['email'] = email;
    map['phoneNumber'] = phoneNumber;
    map['displayName'] = displayName;
    map['introduction'] = introduction;
    map['profileImageUrl'] = profileImageUrl;

    return map;
  }
}
