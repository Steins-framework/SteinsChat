import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(nullable: false)
class User {
  final int id;
  final String name;
  final String avatar;

  User({
    this.id,
    this.name,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json){
    return _$UserFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$UserToJson(this);
  }
}


User _$UserFromJson(Map<String, dynamic> json){
  return User(
    id: json['id'],
    name: json['name'],
    avatar: json['avatar'],
  );
}

Map<String, dynamic> _$UserToJson(User user){
  return <String, dynamic>{
    'id': user.id,
    'name': user.name,
    'avatar': user.avatar,
  };
}