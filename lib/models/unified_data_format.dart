import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(nullable: false)
class UnifiedDataFormat {
  final String event;
  final dynamic data;

  static final Map<String, void Function(dynamic)> _events = {};

  UnifiedDataFormat({
    this.event,
    this.data
  });

  factory UnifiedDataFormat.fromJson(Map<String, dynamic> json){
    return _$UnifiedDataFormatFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$UnifiedDataFormatToJson(this);
  }

  static void on(String event, void Function(dynamic) func){
     _events[event] = func;
  }

  void trigger(){
    if (_events.keys.contains(event)) {
      _events[event](data);
    }
  }
}

UnifiedDataFormat _$UnifiedDataFormatFromJson(Map<String, dynamic> json){
  return UnifiedDataFormat(
    event: json['event'],
    data: json['data'],
  );
}

Map<String, dynamic> _$UnifiedDataFormatToJson(UnifiedDataFormat format){
  return <String, dynamic>{
    'event': format.event,
    'data': format.data != null ? format.data.toJson() : null,
  };
}