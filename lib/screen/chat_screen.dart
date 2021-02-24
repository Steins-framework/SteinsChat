import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:chat/component/message_clipper.dart';
import 'package:chat/models/message.dart';
import 'package:chat/models/unified_data_format.dart';
import 'package:chat/models/user.dart';
import 'package:chat/net/net.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController messageController = TextEditingController();
  ScrollController chatListController = ScrollController();
  GlobalKey _inputGroupKey = GlobalKey();
  List<Message> chatHistory = [];
  Socket _socket;
  User other;
  User currentUser;

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

    return Column(
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
                message.text,
                style: TextStyle(
                    color: isMe ? Colors.white : Colors.black
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
          IconButton(icon: Icon(Icons.more_horiz), onPressed: (){

          }),
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
        title: Text(other == null ? "He's gone" : 'Chat with ' + other.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          iconSize: 15.0,
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
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
      registerUser(currentUser);
    });
  }

  /// 开始匹配
  void goMatching(){
    net.socketWriteObject('matching', null);
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
    );

    net.socketWriteObject('message', message);

    _addMessageToChatList(message);

    messageController.text = '';
  }


  void registerEvents() async {
    UnifiedDataFormat.on('message', (dynamic data){
      var message = Message.fromJson(data);

      _addMessageToChatList(message);
    });

    UnifiedDataFormat.on('matched', (dynamic data){
      var message = Message.fromJson(data);

      _addMessageToChatList(message);
    });

    net.socket.cast<List<int>>().transform(utf8.decoder).listen((response) {
      if (response.trim() == ''){
        return;
      }

      try{
        var unifiedDataFormat = UnifiedDataFormat.fromJson(jsonDecode(response.trim()));

        unifiedDataFormat.trigger();
      }catch(e, stack){
        print(response);
      }
    }, onError: (e){
      print(e);
    });
  }

  void registerUser(User user) async {
    var randomId = Random(DateTime.now().millisecondsSinceEpoch).nextInt(1000);
    var arguments = ModalRoute.of(context).settings.arguments as Map<String, int>;

    currentUser = User(
        id: randomId,
        sex: arguments['sex'],
        name: 'Ricardo'
    );

    net.socketWriteObject('register', user);
  }


  void _addMessageToChatList(Message message){
    setState(() {
      chatHistory.add(message);
    });

    var jumpTo = _inputGroupKey.currentContext.size.height + chatListController.position.maxScrollExtent - 2 ;

    chatListController.animateTo(jumpTo, duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

}
