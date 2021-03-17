import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat/config.dart';
import 'package:chat/models/unified_data_format.dart';
import 'package:chat/net/json_decoder.dart';

typedef void SocketEventCallback(dynamic);

class Net {

  static Socket _socket;

  static var _events = new Map<String, List<SocketEventCallback>>();

  static String status;

  static int heartbeat = 5;
  static int _lastHeartbeatTime;
  static Timer heartbeatTask;

  static Stream _broadcastStream;

  static const Port = 9966;

  static void boot() async {
    // print(StackTrace.current);
    await connect().then((value) {
      print("Connect successfully");
      _socket = value;
      status = 'connect';

      trigger('_connect', null);
      _startHeartbeat();

      on('heartbeat', (dynamic) {
        _lastHeartbeatTime = DateTime.now().millisecondsSinceEpoch;
      });
    }).onError((error, stackTrace) {
      boot();
      return;
    });

    if (_socket == null || status != 'connect'){
      return;
    }
    _broadcastStream =
        _socket.cast<List<int>>()
            .transform(utf8.decoder)
            .transform(jsonDecoder)
            .asBroadcastStream();

    _broadcastStream.listen((response) {
      if(! response.contains('heartbeat')){
        print(response);
      }

      UnifiedDataFormat format;
      try{
        format = UnifiedDataFormat.fromJson(jsonDecode(response));
      }catch(e){
        print(response);
        return;
      }
      trigger(format.event, format.data);
    }, onError: (e) async {
      reboot();
    });

  }

  static void reboot() async {
    if (status == 'rebooting'){
      return;
    }
    status = 'rebooting';
    trigger('_disconnect', null);
    try{
      _socket?.close();
    }catch(e){
      // todo::正确处理socket关闭
    }
    boot();
  }

  static Future<Socket> connect() async {
    int port = Config.port;
    return Config.getAddress().then((add) {

      print("Connect to $add:$port");

      return Socket.connect(add, port,timeout: Duration(seconds: 5));
    });
  }

  static void socketWriteObject(String event,Object object) async{
    var requestData = UnifiedDataFormat(event: event, data: object);
    var requestJson = jsonEncode(requestData);

    if(event != 'heartbeat'){
      print("send: " + requestJson);
    }

    try{
      _socket.write(requestJson);
      await _socket.flush();
    }catch(e){
      reboot();
      // throw e;
    }
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

  static void _startHeartbeat(){
    heartbeatTask?.cancel();
    _lastHeartbeatTime = DateTime.now().millisecondsSinceEpoch;

    heartbeatTask = Timer.periodic(Duration(seconds: heartbeat), (timer) {
      if(status == 'disconnect'){
        timer.cancel();
        return;
      }
      if (DateTime.now().millisecondsSinceEpoch - _lastHeartbeatTime > heartbeat * 2000){
        reboot();
        return;
      }
      socketWriteObject('heartbeat', '（<ゝω・）Kira☆~');
    });
  }
}