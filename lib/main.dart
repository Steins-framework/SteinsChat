import 'package:chat/net/net.dart';
import 'package:chat/screen/chat_screen.dart';
import 'package:chat/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'global/localDB.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  net.connect();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}