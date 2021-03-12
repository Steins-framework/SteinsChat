import 'dart:async';
import 'dart:io';
import 'package:chat/common/app_permission.dart';
import 'package:chat/common/notification_bar.dart';
import 'package:chat/component/bubble.dart';
import 'package:chat/models/message.dart';
import 'package:chat/models/single_room.dart';
import 'package:chat/models/user.dart';
import 'package:chat/net/net.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  TextEditingController messageController = TextEditingController();
  ScrollController chatListController = ScrollController();
  GlobalKey _inputGroupKey = GlobalKey();
  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;
  List<Message> chatHistory = [];
  Timer messageStatusTimer;
  int maximumMessageDelay = 10; // In seconds
  String chatStatus;
  User currentUser;
  SingleRoom room;

  Widget _buildMessageList(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Color(0xfff5f5f5),
          child: ListView.builder(
              padding: EdgeInsets.only(bottom: 15),
              itemCount: chatHistory.length,
              controller: chatListController,
              itemBuilder: (BuildContext context, int index) {
                // return _buildMessage(context, chatHistory[index]);
                return Bubble(
                  message: chatHistory[index],
                  isSelf: chatHistory[index].sender.id == currentUser.id,
                );
              }),
        ),
      ),
    );
  }

  Widget _buildInputGroup(BuildContext context) {
    if (this.room == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7A00EE), Color(0xFFA921CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
        child: SizedBox(
          width: double.infinity,
          child: TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(Platform.isWindows
                  ? EdgeInsets.only(top: 20.0, bottom: 20.0)
                  : EdgeInsets.only(top: 8.0, bottom: 8.0)),
            ),
            child: Text(
              "Let's chat",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              goMatching();
            },
          ),
        ),
      );
    }
    return Container(
      // color: Color(0xffe0e0e0),
      child: Row(
        key: _inputGroupKey,
        children: [
          TextButton(
            child: Text(
              chatStatus == 'chat' ? '离开' : '确认？',
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () {
              leave();
            },
          ),
          Expanded(
              child: TextField(
            controller: messageController,
            textInputAction: TextInputAction.send,
            onEditingComplete: () {
              sendMessage(context);
            },
          )),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                sendMessage(context);
              })
        ],
      ),
    );
  }

  Widget _buildOtherUserCard(BuildContext context) {
    if (room == null) {
      return Container();
    }
    var sizeBox = SizedBox.fromSize(
      size: Size(5, 5),
    );
    User other = room.other();

    var column = Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.fiber_manual_record_rounded,
              color: Color(0xff8c16dd),
            ),
            sizeBox,
            Text('对方信息：'),
            Text(
              other.sex == 1 ? '女' : '男',
            ),
            sizeBox,
            Text(
              other.age != null ? ['18岁以下', '18至23岁', '23以及上'][other.age] : '',
            ),
          ],
        ),
      ],
    );

    if (other.tags.length != 0) {
      var row = Row(
        children: [
          Icon(
            Icons.fiber_manual_record_rounded,
            color: Color(0xff8c16dd),
          ),
          SizedBox.fromSize(
            size: Size(5, 5),
          ),
          Text('标签：'),
        ],
      );
      for (var i = 0; i < other.tags.length; i++) {
        row.children.add(Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Text(other.tags[i]),
        ));
      }
      column.children.add(row);
    }

    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 7,
            blurRadius: 20,
            // offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: column,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (chatStatus == 'chat') {
          leave((confirm) {
            if (confirm) {
              Navigator.of(context).pop();
            }
          });
        }
        return chatStatus != 'chat';
      },
      child: Scaffold(
        appBar: AppBar(
          // title: Text(other == null ? "He's gone" : 'Chat with ' + other.name),
          title: Text(this.room == null ? "对方离开了" : '开始聊天'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 15.0,
            color: Colors.white,
            onPressed: () {
              if (this.room != null) {
                leave((confirm) {
                  if (confirm) {
                    Navigator.of(context).pop();
                  }
                });
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [IconButton(icon: Icon(Icons.phone), onPressed: () {})],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7A00EE),
                  Color(0xFFA921CD),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            _buildOtherUserCard(context),
            _buildMessageList(context),
            _buildInputGroup(context)
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    registerEvents();
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, () {
      registerUser();
      requestPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void goMatching() {
    if (currentUser == null) {
      registerUser();
    }

    showDialog(
      context: context,
      barrierDismissible: Platform.isWindows,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(top: 26.0),
                child: Text("正在匹配..."),
              )
            ],
          ),
        );
      },
    );

    this.chatStatus = 'matching';

    Net.socketWriteObject('matching', null);
  }

  void sendMessage(BuildContext context) {
    if (messageController.text.trim() == '') {
      return;
    }
    var message = Message(
        sender: currentUser,
        receiver: room.other(),
        time: DateTime.now().millisecondsSinceEpoch,
        text: messageController.text,
        key: Uuid().v4());

    Net.socketWriteObject('message', message);

    _addMessageToChatList(message);

    messageController.text = '';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appLifecycleState = state;
  }

  void registerEvents() async {
    Net.on('_connect', (dynamic) {
      registerUser();
    });

    Net.on('message', (dynamic data) {
      var message = Message.fromJson(data);

      if (message.sender.id != currentUser.id) {
        _addMessageToChatList(message);

        if (appLifecycleState == AppLifecycleState.paused) {
          notificationBar.show(1, '收到了一条新信息', message.text);
        }
        // Net.socketWriteObject('read', message);
      } else {
        for (int i = chatHistory.length - 1; i > -1; i--) {
          var m = chatHistory[i];
          if (m.key == message.key) {
            setState(() {
              // TODO: implement didChangeAppLifecycleState
              m.status = 1;
            });
            return;
          }
        }
      }
    });

    Net.on('matched', (dynamic data) async {
      var room = SingleRoom.fromJson(data);

      room.of(currentUser);

      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 300);
      }

      startMessageStatusTimer();

      if (this.chatStatus == 'matching') {
        Navigator.of(context).pop(true);
      }

      this.chatStatus = 'chat';
      if (mounted) {
        setState(() {
          this.room = room;
          chatHistory.clear();
        });
      }
    });

    Net.on('leave', (dynamic data) {
      if (this.chatStatus != 'chat') {
        return;
      }
      this.chatStatus = 'wait';
      this.messageStatusTimer?.cancel();
      if (mounted) {
        setState(() {
          this.room = null;
        });
      }
    });

    Net.on('_disconnect', (dynamic data) {
      if (this.chatStatus == 'matching' && mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  void leave([Function(bool) func]) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('确认离开吗?'),
            content: Text(''),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  if (func != null) {
                    func(false);
                  }
                },
                child: Text(
                  '取消',
                  style: TextStyle(color: Color(0xFF6200EE)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  messageStatusTimer?.cancel();
                  Net.socketWriteObject('leave', null);
                  setState(() {
                    this.room = null;
                  });

                  if (func != null) {
                    func(true);
                  }
                },
                child: Text(
                  '确认',
                  style: TextStyle(color: Color(0xFF6200EE)),
                ),
              ),
            ],
          );
        });
  }

  void registerUser() async {
    var arguments =
        ModalRoute.of(context).settings.arguments as Map<String, User>;

    if (currentUser == null) {
      currentUser = arguments['user'];
    }
    Net.socketWriteObject('register', currentUser);
  }

  void _addMessageToChatList(Message message) {
    if (mounted) {
      setState(() {
        chatHistory.add(message);
      });
    }

    var jumpTo = _inputGroupKey.currentContext.size.height +
        chatListController.position.maxScrollExtent -
        2;

    chatListController.animateTo(jumpTo,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  void startMessageStatusTimer() {
    messageStatusTimer =
        Timer.periodic(Duration(seconds: maximumMessageDelay), (timer) {
      if (chatStatus != 'chat') {
        messageStatusTimer?.cancel();
        return;
      }

      int unixTime = DateTime.now().millisecondsSinceEpoch;
      bool changed = false;

      for (int i = chatHistory.length - 1; i > -1; i--) {
        var message = chatHistory[i];
        if (message.sender.id != currentUser.id) {
          return;
        }
        if (message.status == 0 &&
            unixTime - message.time > maximumMessageDelay * 1000) {
          message.status = 3;
          changed = true;
        }
      }

      if (changed) {
        setState(() {
          //
        });
      }
    });
  }

  void requestPermission() async {
    Permission.notification.status.then((value) => print(value));

    if (await Permission.notification.isDenied ||
        await Permission.notification.isUndetermined) {
      Permission.notification.request().then((value) {
        print('授权结果');
        print(value);
      });
      // AppPermission.request('notification').then((value) {
      //   if(value == PermissionStatus.undetermined){
      //   }
      //   print('授权结果');
      // print(value);
      // });
    }
  }
}
