import 'dart:async';
import 'dart:io';
import 'package:chat/component/message_clipper.dart';
import 'package:chat/models/message.dart';
import 'package:chat/models/user.dart';
import 'package:chat/net/net.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController messageController = TextEditingController();
  ScrollController chatListController = ScrollController();
  GlobalKey _inputGroupKey = GlobalKey();
  List<Message> chatHistory = [];
  Timer messageStatusTimer;
  String chatStatus;
  User currentUser;
  User other;

  Widget _buildMessageList(BuildContext context){
    return Expanded(
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Color(0xfff5f5f5),
          child: ListView.builder(
              padding: EdgeInsets.only(bottom: 15),
              itemCount: chatHistory.length,
              controller: chatListController,
              itemBuilder: (BuildContext context, int index){
                return _buildMessage(context, chatHistory[index]);
              }
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, Message message, ){
    var isMe = message.sender.id == currentUser.id;

    var column = Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: isMe ? const EdgeInsets.fromLTRB(40.0, 10.0, 10.0,0) : const EdgeInsets.fromLTRB(10, 10, 40, 0),
          child: ClipPath(
            clipper: MessageClipper(),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              color: isMe? null: Color(0xffebecf1),
              decoration: isMe ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7A00EE),
                    Color(0xFFA921CD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ) : null,
              child: Text(
                message.text + message.status.toString(),
                style: TextStyle(
                    color: isMe ? Colors.white : Colors.black
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if(message.status == 2){
      column.children.add(Icon(Icons.error_outline));
    }

    return column;
  }

  Widget _buildInputGroup(BuildContext context){
    if (other == null){
      return Container(
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
        margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
        child: SizedBox(
          width: double.infinity,
          child: TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                  Platform.isWindows ? EdgeInsets.only(top: 20.0, bottom: 20.0) : EdgeInsets.only(top: 8.0, bottom: 8.0)
              ),
            ),
            child: Text(
              "Let's chat",
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            onPressed: (){
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
            child: Text(chatStatus == 'chat' ? '离开' : '确认？', style: TextStyle(color: Colors.grey),),
            onPressed: (){
              leave((x){});
            },
          ),
          Expanded(child: TextField(
            controller: messageController,
            textInputAction: TextInputAction.send,
            onEditingComplete: (){
              sendMessage(context);
            },
          )),
          IconButton(icon: Icon(Icons.send), onPressed: (){
            sendMessage(context);
          })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // title: Text(other == null ? "He's gone" : 'Chat with ' + other.name),
        title: Text(other == null ? "He's gone" : 'Start chat'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          iconSize: 15.0,
          color: Colors.white,
          onPressed: (){
            if (other != null){
              leave((sure){
                print(sure);
                if (sure){
                  Navigator.of(context).pop();
                }
              });
            }else{
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(icon: Icon(Icons.phone ), onPressed: (){})
        ],
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
          _buildMessageList(context),
          _buildInputGroup(context)
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    registerEvents();

    Future.delayed(Duration.zero,(){
      registerUser();
    });
  }

  /// 开始匹配
  void goMatching(){
    if (currentUser == null){
      registerUser();
    }

    if (Net.socket() == null){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.only(top: 26.0),
                  child: Text("连接服务器失败"),
                )
              ],
            ),
          );
        },
      );
    }
    showDialog(
      context: context,
      barrierDismissible: Platform.isWindows,
      builder: (context){
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(top: 26.0),
                child: Text("正在匹配，请稍后..."),
              )
            ],
          ),
        );
      },
    );

    this.chatStatus = 'matching';

    Net.socketWriteObject('matching', null);
  }

  void sendMessage(BuildContext context){
    if (messageController.text.trim() == ''){
      return ;
    }
    var message = Message(
      sender: currentUser,
      receiver: other,
      time: '5:30 PM',
      text: messageController.text,
      key: Uuid().v4()
    );

    Net.socketWriteObject('message', message);

    _addMessageToChatList(message);

    messageController.text = '';
  }


  void registerEvents() async {
    Net.on('message', (dynamic data){
      var message = Message.fromJson(data);

      if (message.sender.id != currentUser.id){
        _addMessageToChatList(message);
      }
    });

    Net.on('matched', (dynamic data){
      var user = User.fromJson(data);
      if (this.chatStatus == 'matching'){
        Navigator.of(context).pop(true);
      }
      this.chatStatus = 'chat';
      setState(() {
        other = user;
        chatHistory.clear();
      });

      messageStatusTimer = Timer.periodic(Duration(seconds: 10), (timer) {
        print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
        if (chatHistory.isEmpty){
          return;
        }
        bool change = false;
        for (var i = 0; i < chatHistory.length; i++){
          if (chatHistory[i].sender.id != currentUser.id){
            continue;
          }
          if (chatHistory[i].status == 0){
            change = true;
            chatHistory[i].status = 2;
          }
        }

        if(change){
          setState(() {

          });
        }
      });

    });

    Net.on('leave', (dynamic data){
      this.chatStatus = 'chat';
      this.messageStatusTimer?.cancel();
      setState(() {
        other = null;
      });
    });

    Net.on('_disconnect', (dynamic data) {
      if (this.chatStatus == 'matching'){
        Navigator.of(context).pop(true);
      }
    });
  }

  void leave(Function(bool) func) async {
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('You sure to leave?'),
        content: Text(''),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              if(func != null){
                func(false);
              }
            },
            child: Text('CANCEL', style: TextStyle(color: Color(0xFF6200EE)),),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              messageStatusTimer?.cancel();
              Net.socketWriteObject('leave', null);
              setState(() {
                other = null;
              });

              if(func != null){
                func(false);
              }
            },
            child: Text('CONFIRM', style: TextStyle(color: Color(0xFF6200EE)),),
          ),
        ],
      );
    });
  }

  void registerUser() async {
    var id = Uuid();
    var arguments = ModalRoute.of(context).settings.arguments as Map<String, int>;

    currentUser = User(
        id: id.v4(),
        sex: arguments['sex'],
        name: id.v4()
    );

    Net.socketWriteObject('register', currentUser);
  }


  void _addMessageToChatList(Message message){
    setState(() {
      chatHistory.add(message);
    });

    var jumpTo = _inputGroupKey.currentContext.size.height + chatListController.position.maxScrollExtent - 2 ;

    chatListController.animateTo(jumpTo, duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

}
