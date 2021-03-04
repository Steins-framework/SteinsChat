import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var notificationBar = NotificationBar();

class NotificationBar{
  FlutterLocalNotificationsPlugin notificationsPlugin;

  AndroidNotificationDetails androidDetails;

  SelectNotificationCallback selectNotificationCallback;

  NotificationDetails platformDetails;

  void init() async{
    notificationsPlugin = new FlutterLocalNotificationsPlugin();

    var initSetting = new InitializationSettings(
      android: new AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    notificationsPlugin.initialize(initSetting,onSelectNotification:(String payload) async {
      if(selectNotificationCallback != null){
        selectNotificationCallback(payload);
      }
    });


    androidDetails = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION', priority: Priority.high,importance: Importance.max
    );

    platformDetails = new NotificationDetails(android: androidDetails);
  }

  void show(int id, String title, String body, {String payload}) async {
    await notificationsPlugin.show(id, title, body, platformDetails, payload: payload);
  }

}