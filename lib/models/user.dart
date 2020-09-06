import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
