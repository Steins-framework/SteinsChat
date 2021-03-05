import 'package:chat/models/message.dart';
import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  Message message;
  bool isSelf;

  Bubble({
    this.message,
    this.isSelf
  }):
    assert(message != null),
    assert(isSelf != null);

  @override
  Widget build(BuildContext context) {
    var text = Text(
      message.text,
      style: TextStyle(
        color: isSelf ? Colors.white : Colors.black,
      ),
    );

    return Column(
      crossAxisAlignment: isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        isSelf && message.status != 0 ? Stack(
          children: [
            _bubble(isSelf, text),
            Positioned(
              left: 15,
              top: 30,
              child: Container(
                padding: EdgeInsets.fromLTRB(3,2,3,2),
                decoration: BoxDecoration(
                  color: Color(0xffeeeeee),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: Icon(
                  <int,IconData>{
                    0: Icons.done,
                    1:Icons.done,
                    2: Icons.done_all_outlined,
                    3: Icons.error_outline
                  }[message.status],
                  color: Color(0xff6d6d72),
                  size: 15,
                ),
              ),
            ),
          ],
        ) : _bubble(isSelf, text),
      ],
    );
  }

  Widget _bubble(bool isSelf, Widget child){
    return Container(  // 气泡
      padding: const EdgeInsets.all(10.0),
      margin: isSelf ? const EdgeInsets.fromLTRB(40.0, 10.0, 10.0,0) : const EdgeInsets.fromLTRB(10, 10, 40, 0),
      decoration: BoxDecoration(
        color: isSelf? null: Color(0xffebecf1),
        gradient: isSelf ? LinearGradient(
          colors: [
            Color(0xFF7A00EE),
            Color(0xFFA921CD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: child,
    );
  }

}