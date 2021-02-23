import 'package:chat/screen/chat_screen.dart';
import 'package:chat/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'global/localDB.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
//
// import 'package:flutter/material.dart';
// import 'package:flutter/animation.dart';
//
//
// class AnimatedLogo extends AnimatedWidget{
//   AnimatedLogo({Key key, Animation<double> animation})
//       : super(key: key, listenable: animation);
//
//   Widget build(BuildContext context){
//     final Animation<double> animation = listenable;
//     return new Center(
//       child: new Container(
//         margin: new EdgeInsets.symmetric(vertical: 10.0),
//         height: animation.value,
//         width: animation.value,
//         child: new FlutterLogo(),
//       ),
//     );
//   }
// }
//
// class LogoApp extends StatefulWidget {
//   _LogoAppState createState() => new _LogoAppState();
// }
//
// class _LogoAppState extends State<LogoApp> with SingleTickerProviderStateMixin {
//
//   Animation<double> animation;
//   AnimationController controller;
//
//
//   initState(){
//     super.initState();
//     controller = new AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );
//     animation = new Tween(begin: 0.0, end: 300.0).animate(controller)
//       ..addStatusListener((status) {
//         print(status);
//         if(status == AnimationStatus.completed){
//           controller.reverse();
//         }else if(status == AnimationStatus.dismissed){
//           controller.forward();
//         }
//       });
//
//     controller.forward();
//   }
//
//   Widget build(BuildContext context) {
//     return AnimatedLogo(animation: animation,);
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }
//
// void main() {
//   runApp(new LogoApp());
// }
