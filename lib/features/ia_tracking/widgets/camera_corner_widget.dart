import 'package:flutter/material.dart';

class CameraCornerWidget extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  final Color color;

  const CameraCornerWidget({
    Key? key,
    required this.isTop,
    required this.isLeft,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: color, width: 4) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: color, width: 4) : BorderSide.none,
          left: isLeft ? BorderSide(color: color, width: 4) : BorderSide.none,
          right: !isLeft ? BorderSide(color: color, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}
