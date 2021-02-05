import 'package:flutter/cupertino.dart';

class MessageClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    double radius = 10;

    return Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width-radius, 0)
      ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius))
      ..lineTo(size.width, size.height - radius)
      ..arcToPoint(Offset(size.width - radius, size.height),radius: Radius.circular(radius))
      ..lineTo(radius, size.height)
      // ..arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius), clockwise: false)
      ..arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius))
      ..lineTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }

}