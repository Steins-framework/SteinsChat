import 'package:chat/models/user.dart';

class SingleRoom{
  final User u1;
  final User u2;
  final String topic;
  final int status;

  User current;

  SingleRoom({this.u1,
    this.u2,
    this.topic,
    this.status
  });

  void of(User user){
    current = user;
  }

  User other(){
    return u1.id == current.id ? u2 : u1;
  }
  
  factory SingleRoom.fromJson(Map<String, dynamic> json){
    return _$SingleRoomFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$SingleRoomToJson(this);
  }
}

SingleRoom _$SingleRoomFromJson(Map<String, dynamic> json){
  return SingleRoom(
    u1: User.fromJson(json['u1']),
    u2: User.fromJson(json['u2']),
    topic: json['time'],
    status: json['status'],
  );
}

Map<String, dynamic> _$SingleRoomToJson(SingleRoom singleRoom){
  return <String, dynamic>{
    'u1': singleRoom.u1.toJson(),
    'u2': singleRoom.u2.toJson(),
    'topic': singleRoom.topic,
    'status': singleRoom.status,
  };
}