import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:flutter/material.dart';

import 'package:protasks/core/constants/enums.dart';

class PriorityText extends StatefulWidget {
  final TaskPriority priority;
  final String textToShowIfPriorityUndefined;
  const PriorityText({
    Key? key,
    required this.priority,
    this.textToShowIfPriorityUndefined = 'Undefined',
  }) : super(key: key);
  @override
  _PriorityTextState createState() => _PriorityTextState();
}

class _PriorityTextState extends State<PriorityText> {
  String? generatedText;

  @override
  void initState() {
    generatedText =
        ExtraFunctions.priorityToText(taskPriority: widget.priority);
    if (generatedText == null) {
      generatedText = widget.textToShowIfPriorityUndefined;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      generatedText!,
      style: TextStyle(
        fontFamily: Strings.primaryFontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    );
  }
}
