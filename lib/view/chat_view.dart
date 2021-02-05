import 'dart:io';

import 'package:chat/component/message_clipper.dart';
import 'package:chat/data/chat_content.dart';
import 'package:chat/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {

  TextEditingController messageController = TextEditingController();
  ScrollController chatListController = ScrollController();
  GlobalKey _inputGroupKey = GlobalKey();
  Socket _socket;

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
              itemCount: messages.length,
              controller: chatListController,
              itemBuilder: (BuildContext context, int index){
                return _buildMessage(context, messages[index]);
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

  void sendMessage(BuildContext context){
    if (messageController.text.trim() == ''){
      return ;
    }
    setState(() {
      messages.add(Message(
        sender: currentUser,
        time: '5:30 PM',
        text: messageController.text,
        isLiked: true,
        unread: true,
      ));
    });
    send(messageController.text);

    messageController.text = '';

    var jumpTo = _inputGroupKey.currentContext.size.height + chatListController.position.maxScrollExtent - 2 ;

    chatListController.animateTo(jumpTo, duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  void connect() async {
    print("Connect to 10.0.2.2:65535");
    _socket = await Socket.connect('10.0.2.2', 65535);
  }
  void send(String text) async {
    print("send: " + text);
    _socket.writeln(text);
    await _socket.flush();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ricardo'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          iconSize: 15.0,
          color: Colors.white,
          onPressed: (){},
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
}
