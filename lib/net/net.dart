import 'dart:convert';
import 'dart:io';

import 'package:chat/models/unified_data_format.dart';

typedef void SocketEventCallback(dynamic);

class Net {

  static Socket _socket;

  static var _events = new Map<String, List<SocketEventCallback>>();

  static void boot(){
    connect();

    _socket.cast<List<int>>().transform(utf8.decoder).listen((response) {
      if (response.trim() == ''){
        return;
      }

      print(response);

      try{
        var format = UnifiedDataFormat.fromJson(jsonDecode(response.trim()));

        trigger(format.event, format.data);
      }catch(e, stack){
        print(response);
      }
    }, onError: (e){
      print(e);
    });
  }

  static void connect() async {
    String address = '10.0.2.2';

    if (Platform.isWindows){
      address = '127.0.0.1';
    }
    print("Connect to $address:65535");

    _socket = await Socket.connect(address, 65535);
  }

  static void socketWriteObject(String event,Object object) async{
    var requestData = UnifiedDataFormat(event: event, data: object);
    var requestJson = jsonEncode(requestData);
    print("send: " + requestJson);

    _socket.writeln(requestJson);
    await _socket.flush();
  }

  static Socket socket(){
    return _socket;
  }

  static void on(String eventName, SocketEventCallback func){
    if (eventName == null || func == null) return;

    _events[eventName] ??= new List<SocketEventCallback>();
    _events[eventName].add(func);
  }

  static void trigger(String event, dynamic data){
    var list = _events[event];

    if (list == null) return;

    //反向遍历，防止订阅者在回调中移除自身带来的下标错位
    for (var i = list.length - 1; i > -1; --i) {
      if(list[i](data)){
        break;
      }
    }
  }
}