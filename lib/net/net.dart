import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat/models/unified_data_format.dart';
import 'package:chat/net/json_decoder.dart';

typedef void SocketEventCallback(dynamic);

class Net {

  static Socket _socket;

  static var _events = new Map<String, List<SocketEventCallback>>();

  static Stream _broadcastStream;
  static StreamSubscription _stream;

  static const Port = 9966;

  static void boot() async {
    _socket = await connect();

    _broadcastStream =
        _socket.cast<List<int>>()
            .transform(utf8.decoder)
            .transform(jsonDecoder)
            .asBroadcastStream();

    _stream = _broadcastStream.listen((response) {
      if(! response.contains('pong')){
        print(response);
      }

      try{
        var format = UnifiedDataFormat.fromJson(jsonDecode(response));

        trigger(format.event, format.data);
      }catch(e){
        print(response);
      }
    }, onError: (e) async {
      print(e);
      trigger('_disconnect', null);
      _socket.close();
      _stream.cancel();
      boot();
    });

  }


  static Future<Socket> connect() async {
    String address = '10.0.2.2';

    if (Platform.isWindows){
      address = '127.0.0.1';
    }

    // address = 'chat.misakas.com';

    print("Connect to $address:$Port");

    return await Socket.connect(address, Port);
  }

  static void socketWriteObject(String event,Object object) async{
    var requestData = UnifiedDataFormat(event: event, data: object);
    var requestJson = jsonEncode(requestData);
    print("send: " + requestJson);

    try{
      _socket.writeln(requestJson);
    }catch(e){
      print(e);
      boot();
      return;
    }
    await _socket.flush();
  }

  static Socket socket(){
    return _socket;
  }

  static void on(String eventName, SocketEventCallback func){
    if (eventName == null || func == null) return;

    // _events[eventName] ??= new List<SocketEventCallback>();
    _events[eventName] ??= [];
    _events[eventName].add(func);
  }

  static void trigger(String event, dynamic data){
    var list = _events[event];

    if (list == null) return;

    //反向遍历，防止订阅者在回调中移除自身带来的下标错位
    for (var i = list.length - 1; i > -1; --i) {
      list[i](data);
    }
  }
}