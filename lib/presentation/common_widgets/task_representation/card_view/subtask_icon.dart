import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class SubtaskIcon extends StatelessWidget {
  const SubtaskIcon({
    Key? key,
    required this.subtaskCount,
  }) : super(key: key);

  final int subtaskCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.trending_down,
          size: 16,
          color: Theme.of(context).taskAddOnColor,
        ),
        SizedBox(
          width: 2,
        ),
        Text(
          '$subtaskCount',
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
