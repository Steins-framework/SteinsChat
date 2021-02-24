import 'dart:convert';
import 'dart:io';

import 'package:chat/models/unified_data_format.dart';

class net{
  static Socket socket;

  static void connect() async {
    String address = '10.0.2.2';

    if (Platform.isWindows){
      address = '127.0.0.1';
    }
    print("Connect to $address:65535");

    socket = await Socket.connect(address, 65535);
  }

  static void socketWriteObject(String event,Object object) async{
    var requestData = UnifiedDataFormat(event: event, data: object);
    var requestJson = jsonEncode(requestData);
    print("send: " + requestJson);

    socket.writeln(requestJson);
    await socket.flush();
  }
}