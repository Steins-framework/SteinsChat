import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(nullable: false)
class User {
  final String id;
  final String name;
  final String avatar;
  int age;
  int sex;
  List<double> coordinate;
  List<String> tags = [];

  User({
    this.id,
    this.sex,
    this.age,
    this.name,
    this.avatar,
    this.coordinate,
    this.tags,
  }){
    if (this.tags == null) this.tags = [];
    if (this.coordinate == null) this.coordinate = [];
  }

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
    age: json['age'],
    name: json['name'],
    avatar: json['avatar'],
    coordinate: json['coordinate'] == null ? [] : json['coordinate'].cast<double>(),
    tags: json['tags'] == null ? [] : json['tags'].cast<String>(),
  );
}

Map<String, dynamic> _$UserToJson(User user){
  return <String, dynamic>{
    'id': user.id,
    'sex': user.sex,
    'age': user.age,
    'name': user.name,
    'avatar': user.avatar,
    'coordinate': user.coordinate,
    'tags': user.tags,
  };
}