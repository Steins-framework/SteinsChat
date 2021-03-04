import 'package:chat/common/notification_bar.dart';
import 'package:chat/net/net.dart';
import 'package:chat/screen/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Net.boot();

  notificationBar.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,

      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }

  MyApp(){
    registerGlobalEvent();
  }

  void registerGlobalEvent(){
    Net.on('_disconnect', (dynamic) {
      final snackBar = SnackBar(
        content: Text('Wow...好像与服务器断开了连接'),
        action: SnackBarAction(
          label: '行吧',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(navigatorKey.currentState.overlay.context).showSnackBar(snackBar);
    });
  }
}