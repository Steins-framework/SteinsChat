import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(nullable: false)
class User {
  final String id;
  final int sex;
  final String name;
  final String avatar;
  final List<double> coordinate;
  final List<String> tags;

  User({
    this.id,
    this.sex,
    this.name,
    this.avatar,
    this.coordinate,
    this.tags,
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
    sex: json['sex'],
    name: json['name'],
    avatar: json['avatar'],
  );
}

Map<String, dynamic> _$UserToJson(User user){
  return <String, dynamic>{
    'id': user.id,
    'sex': user.sex,
    'name': user.name,
    'avatar': user.avatar,
  };
}