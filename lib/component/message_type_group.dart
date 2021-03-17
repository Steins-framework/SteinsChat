import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MessageTypeGroup extends StatefulWidget {
  final TextEditingController controller;
  final Function  onEditingComplete;
  final Function  onLeave;

  MessageTypeGroup({
    key,
    this.controller,
    this.onLeave,
    this.onEditingComplete,
  }): super(key: key);

  @override
  _InputGroupState createState() => _InputGroupState();
}

class _InputGroupState extends State<MessageTypeGroup> with TickerProviderStateMixin {
  bool messageInputHasValue = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('1111');
    widget.controller.addListener(() {
      if (messageInputHasValue !=  widget.controller.text.isNotEmpty){
        messageInputHasValue =  widget.controller.text.isNotEmpty;
        if(mounted){
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          TextButton(
            child: Text(
              '离开',
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: widget.onLeave,
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              onEditingComplete: widget.onEditingComplete,
            ),),
          actives(context),
        ],
      ),
    );
  }

  Widget actives(BuildContext context){
    int animationTime = 200;

    return Row(
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: animationTime),
          transitionBuilder: (child, animation){
            return ScaleTransition(scale: animation, child: child,);
          },
          child: messageInputHasValue ?
          IconButton(
            key: UniqueKey(),
            icon: Icon(
              Icons.send,
              color: Color(0xff8600e0),
            ),
            onPressed: widget.onEditingComplete,
          ):
          Transform.rotate(
            angle: 0.5,
            child: IconButton(
              key: UniqueKey(),
              icon: Icon(
                Icons.attach_file,
              ),
              onPressed: widget.onEditingComplete,
            ),
          )
        ),
      ],
    );

  }
}
