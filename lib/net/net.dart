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

  static const Port = 65535;

  static void boot() async {
    _socket = await connect();

    // if(_broadcastStream == null) {
      _broadcastStream =
          _socket.cast<List<int>>()
              .transform(utf8.decoder)
              .transform(jsonDecoder)
              .asBroadcastStream();
    // }
    _stream = _broadcastStream.listen((response) {
      print(222222222);
      print(response);
    }, onError: (e) async {
      print(e);
      _socket.close();
      _stream.cancel();
      boot();
    });

    // _broadcastStream.listen((response) {
    //   print(1111111);
    //   print(response);
    // }, onError: (e) async {
    //   print(e);
    //   _socket.close();
    //   boot();
    // });


  }
  // static void boot() async {
  //   _socket = await connect();
  //
  //    _broadcastStream = _socket.cast<List<int>>().transform(utf8.decoder).transform(jsonDecoder).asBroadcastStream();
  //
  //   _broadcastStream.listen((response) {
  //     // print(response);
  //     // try{
  //     //   var format = UnifiedDataFormat.fromJson(jsonDecode(response));
  //     //
  //     //   trigger(format.event, format.data);
  //     // }catch(e){
  //     //   print(response);
  //     // }
  //   }, onError: (e) async {
  //     print(e);
  //     _socket.close();
  //     _socket.destroy();
  //     _socket = null;
  //     boot();
  //   });
  // }

  static Future<Socket> connect() async {
    String address = '10.0.2.2';

    if (Platform.isWindows){
      address = '127.0.0.1';
    }
    print("Connect to $address:65535");

    return await Socket.connect(address, Port);
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