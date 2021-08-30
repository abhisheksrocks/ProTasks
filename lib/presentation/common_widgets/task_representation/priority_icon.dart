import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class PriorityIcon extends StatefulWidget {
  const PriorityIcon({
    Key? key,
    required this.priority,
    this.fontSize = 12,
  }) : super(key: key);
  final TaskPriority priority;
  final double fontSize;

  @override
  _PriorityIconState createState() => _PriorityIconState();
}

class _PriorityIconState extends State<PriorityIcon> {
  late Color backgroundColor;
  late Color foregroundColor;
  late String exclamationText;
  bool makeCircle = true;

  Color findBackgroundColor(BuildContext context) {
    switch (widget.priority) {
      case TaskPriority.low:
        // return Color(0xFF777B84).withOpacity(0.3);
        return Theme.of(context).lowPriorityBannerColor.withOpacity(0.3);

      case TaskPriority.medium:
        // return Color(0xFF40B45C).withOpacity(0.3);
        return Theme.of(context).mediumPriorityBannerColor.withOpacity(0.3);
      case TaskPriority.high:
        // return Color(0xFFFF3860);
        return Theme.of(context).highPriorityBannerColor;
      default:
        makeCircle = false;
        // return Color(0xFF777B84).withOpacity(0.3); //case 1
        return Theme.of(context).lowPriorityBannerColor.withOpacity(0.3);
    }
  }

  Color findForegroundColor(BuildContext context) {
    switch (widget.priority) {
      case TaskPriority.low:
        // return Color(0xFF777B84);
        return Theme.of(context).lowPriorityBannerColor;
      case TaskPriority.medium:
        // return Color(0xFF40B45C);
        return Theme.of(context).mediumPriorityBannerColor;
      case TaskPriority.high:
        return Colors.white;
      default:
        return Theme.of(context).lowPriorityBannerColor;
      // return Color(0xFF777B84); //case 1
    }
  }

  String findText() {
    switch (widget.priority) {
      case TaskPriority.low:
        return '!';
      case TaskPriority.medium:
        return '!!';
      case TaskPriority.high:
        return '!!!';
      default:
        return '!';
    }
    // for (int i = 0; i < priority; i++) {
    //   textToReturn = textToReturn + '!';
    // }
    // return textToReturn;

    // return '!' * widget.priority;
    // return priority * '!'; // !This won't work
  }

  Text textWidget() {
    return Text(
      exclamationText,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.w500,
        fontSize: widget.fontSize,
      ),
    );
  }

  // * FLUTTER DOESN'T ALLOW initState() BECAUSE OF USAGE OF Theme.of(context) which can change
  @override
  void didChangeDependencies() {
    backgroundColor = findBackgroundColor(context);
    foregroundColor = findForegroundColor(context);
    exclamationText = findText();
    super.didChangeDependencies();
  }

  // @override
  // void initState() {
  //   backgroundColor = findBackgroundColor(context);
  //   foregroundColor = findForegroundColor(context);
  //   exclamationText = findText();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(makeCircle ? 20 : 3),
        color: backgroundColor,
      ),
      constraints: BoxConstraints(
        maxHeight: widget.fontSize * 1.33, //remove const if making dynamic
        // maxWidth: widget.fontSize * 1.33, //remove const if making dynamic
      ),
      // alignment: Alignment.center,
      child: makeCircle
          ? AspectRatio(
              aspectRatio: 1,
              child: Center(child: textWidget()),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              child: textWidget(),
            ),
    );
  }
}
