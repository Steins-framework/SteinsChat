import 'package:chat/models/user.dart';
import 'package:chat/screen/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:uuid/uuid.dart';

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

  final TextEditingController nameController = TextEditingController();


  static const int MAN = 0;
  static const int FEMALE = 1;

  User currentUser = User(
      id: Uuid().v4(),
      name: Uuid().v4()
  );

  void _jumpToChat(BuildContext context){
    if (currentUser.sex == 4){
      return;
    }

    Navigator.of(context).push(new MaterialPageRoute(builder: (context){
      return ChatScreen();
    }, settings: RouteSettings(arguments: {
      'user': currentUser
    })));
  }

  void _choiceGender(int gender){
    setState(() {
      this.currentUser.sex = gender;
    });
  }

  Widget _genderPicker(int gender, ImageProvider image){
    return AnimatedContainer(
      duration: Duration(milliseconds: 90),
      decoration: BoxDecoration(
        gradient: currentUser.sex == gender ? LinearGradient(
          colors: [
            Color(0xFF7A00EE),
            Color(0xFF8B30F1),
            Color(0xFFBE20E7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(50.0),
      ),
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: (){
          _choiceGender(gender);
        },
        child: ColorFiltered(
          colorFilter: currentUser.sex == gender ? identity : greyscale,
          child: CircleAvatar(
            radius: 35.0,
            backgroundImage: image,
          ),
        ),
      ),
    );
  }

  Widget _agePicker(BuildContext context){
    return CupertinoActionSheet(
      title: const Text('Chose your age'),
      // message: const Text('Message'),
      actions: [
        CupertinoActionSheetAction(
          child: const Text('Under 18'),
          onPressed: (){
            Navigator.of(context).pop(0);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('18 to 23 years old'),
          onPressed: (){
            Navigator.of(context).pop(1);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Over 23 years old'),
          onPressed: (){
            Navigator.of(context).pop(2);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel', style: TextStyle(color: Colors.red),),
        onPressed: (){
          Navigator.of(context).pop();
        },
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
                onPressed: () async {
                  await showCupertinoModalPopup(context: context, builder: _agePicker).then((value) {
                    if(value == null) return;

                    currentUser.age = value;
                    _jumpToChat(context);
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
