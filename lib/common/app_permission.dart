import 'package:chat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermission{
  static Map<String, String> _description = {
    'camera': '本权限将用于聊天时拍照，视频等功能。使用时将保证图像用户可见',
    'notification': '本权限用于收到对方信息时提醒，权限保证仅在匹配到用户时使用',
  };

  static Map<String, Permission> _function = {
    'camera': Permission.camera,
    'notification': Permission.notification,
  };

  static Map<String, String> _translation = {
    'camera': '相机',
    'notification': '通知栏'
  };

  static Future<PermissionStatus> request(String permission) async {
    if (! _description.containsKey(permission)){
      throw Exception('权限不存在');
    }

    bool allow = await showDialog(context: navigatorKey.currentContext, builder: (context){
      return CupertinoAlertDialog(
        title: Text('应用想要申请 ' + _translation[permission] + ' 权限'),
        content: Text(_description[permission]),
        actions: [
          CupertinoDialogAction(
            child: Text('授权'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: Text('取消', style: TextStyle(color: Colors.red),),
            onPressed: (){
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    });

    return allow ? _function[permission].request() : PermissionStatus.denied;
  }
}