import 'package:protasks/core/constants/strings.dart';
import 'package:flutter/material.dart';

class TaskDescription extends StatelessWidget {
  const TaskDescription({
    Key? key,
    required this.description,
    this.fontSize = 16,
  }) : super(key: key);

  final String description;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: Strings.secondaryFontFamily,
        fontSize: fontSize,
      ),
    );
  }
}
