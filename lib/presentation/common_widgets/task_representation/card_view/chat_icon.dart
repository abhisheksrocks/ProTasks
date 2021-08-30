import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ChatIcon extends StatelessWidget {
  const ChatIcon({
    Key? key,
    required this.countToShow,
  }) : super(key: key);

  final int countToShow;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 2,
        ),
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: 16,
          color: Theme.of(context).taskAddOnColor,
        ),
        SizedBox(
          width: 2,
        ),
        Text(
          '$countToShow',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 10,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
