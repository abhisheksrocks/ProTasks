import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:flutter/material.dart';

class ReminderWidget extends StatefulWidget {
  final DateTime taskTime;
  final Duration remindTimer;
  final bool isOverdue;
  final bool withBrackets;
  final double fontSize;
  final String? stringToDisplayIfNoReminder;
  ReminderWidget({
    Key? key,
    required this.taskTime,
    required this.remindTimer,
    required this.isOverdue,
    this.inWords = true,
    this.withBrackets = true,
    this.fontSize = 12,
    this.stringToDisplayIfNoReminder,
  }) : super(key: key);

  final bool inWords;

  @override
  _ReminderWidgetState createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
  String? remindString;

  @override
  void initState() {
    remindString = widget.inWords
        ? ExtraFunctions.findRemindTimeInWords(
            taskTime: widget.taskTime,
            taskRemindTimer: widget.remindTimer,
          )
        : ExtraFunctions.findDateFormattedRemindTime(
            taskTime: widget.taskTime,
            taskRemindDuration: widget.remindTimer,
          );
    if (remindString == null) {
      remindString = widget.stringToDisplayIfNoReminder;
    }
    if (remindString != null) {
      //Because [stringToDisplayIfNoReminder] can be null
      if (widget.withBrackets) {
        remindString = "($remindString)";
      }
    } else {
      remindString = '';
    }
    // if (widget.withBrackets && remindString != '') {
    //   remindString = "($remindString)";
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      remindString!,
      maxLines: 2,
      style: TextStyle(
        fontFamily: Strings.primaryFontFamily,
        fontWeight: FontWeight.w500,
        color: widget.isOverdue ? Theme.of(context).overdueBannerColor : null,
        fontSize: widget.fontSize,
      ),
    );
  }
}
