import 'dart:convert';
import 'dart:io';

import 'package:chat/models/unified_data_format.dart';

class Net{
  static Socket _socket;

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
}