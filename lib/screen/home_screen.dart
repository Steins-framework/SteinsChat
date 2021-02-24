import 'package:chat/screen/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  static const ColorFilter identity = ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static const ColorFilter greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ]);


  static const int MAN = 0;
  static const int FEMALE = 1;

  int gender = 4;

  void _jumpToChat(BuildContext context){
    if (gender == 4){
      return;
    }

    Navigator.of(context).push(new MaterialPageRoute(builder: (context){
      return ChatScreen();
    }, settings: RouteSettings(arguments: {
      'sex': gender
    })));
  }

  void _choiceGender(int gender){
    print(gender);
    setState(() {
      this.gender = gender;
    });
  }

  Decoration _buildDecoration(){
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF7A00EE),
          Color(0xFF8B30F1),
          Color(0xFFBE20E7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Widget _genderPicker(int gender, ImageProvider image){
    return ClipOval(
      child: Container(
        // color: this.gender == gender ? Colors.amberAccent : null,
        decoration: this.gender == gender ? _buildDecoration() : null,
        padding: EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap: (){
            _choiceGender(gender);
          },
          child: ColorFiltered(
            colorFilter: this.gender == gender ? identity : greyscale,
            child: CircleAvatar(
              radius: 35.0,
              // backgroundImage: AssetImage('assets/images/male-selected.png'),
              backgroundImage: image,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _genderPicker(MAN, AssetImage('assets/images/male-selected.png')),
                _genderPicker(FEMALE, AssetImage('assets/images/female-selected.png')),
              ],
            ),
            SizedBox.fromSize(size: Size(0.0, 40.0)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7A00EE), Color(0xFFA921CD)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    Platform.isWindows ? EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 18.0) : EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
                  ),
                ),
                child: Text(
                  "Let's chat",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
                onPressed: (){
                  _jumpToChat(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
