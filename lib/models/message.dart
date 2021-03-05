import 'package:json_annotation/json_annotation.dart';
import 'package:chat/models/user.dart';

@JsonSerializable(nullable: false)
class Message {
  final User sender;
  final User receiver;
  final int time; // Would usually be type DateTime or Firebase Timestamp in production apps
  final String text;
  final String key;
  int status;

  Message({
    this.sender,
    this.receiver,
    this.time,
    this.text,
    this.key,
    this.status = 0,
  });

  factory Message.fromJson(Map<String, dynamic> json){
    return _$MessageFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$MessageToJson(this);
  }
}

Message _$MessageFromJson(Map<String, dynamic> json){
  return Message(
    key: json['key'],
    text: json['text'],
    time: json['time'],
    sender: User.fromJson(json['sender']),
  );
}

Map<String, dynamic> _$MessageToJson(Message message){
  return <String, dynamic>{
    'key': message.key,
    'text': message.text,
    'time': message.time,
    'sender': message.sender.toJson(),
    'receiver': message.receiver.toJson(),
  };
}