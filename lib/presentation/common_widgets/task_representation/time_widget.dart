import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:flutter/material.dart';

class TimeWidget extends StatelessWidget {
  final DateTime taskTime;
  final bool isOverdue;
  final bool isBy;
  final bool minimal;
  const TimeWidget({
    Key? key,
    required this.taskTime,
    required this.isOverdue,
    required this.isBy,
    this.fontSize = 12,
    this.minimal = true,
  }) : super(key: key);

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      minimal
          ? ExtraFunctions.findRelativeDateWithTime(
              dateAndTime: taskTime,
              isBy: isBy,
            )!
          : ExtraFunctions.findAbsoluteDateAndTime(
              time: taskTime,
              isBy: isBy,
            )!,
      maxLines: 2,
      style: TextStyle(
        fontFamily: Strings.primaryFontFamily,
        fontWeight: FontWeight.w500,
        color: isOverdue ? Theme.of(context).overdueBannerColor : null,
        fontSize: fontSize,
      ),
    );
  }
}
