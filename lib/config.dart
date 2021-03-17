import 'dart:io';

import 'package:device_info/device_info.dart';

class Config{
  static int port = 9966;

  static Future<String> getAddress() async {
    // chat.misakas.com

    if (Platform.isWindows){
      return '127.0.0.1';
    }
    var device = DeviceInfoPlugin();

    var info = await device.androidInfo;

    if(info.model == 'sdk_gphone_x86_arm'){
      return '10.0.2.2';
    }

    return '192.168.3.117';
  }
}