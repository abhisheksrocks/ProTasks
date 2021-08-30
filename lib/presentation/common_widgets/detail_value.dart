import 'package:protasks/core/constants/strings.dart';
import 'package:flutter/material.dart';

// TODO: Move it to common widgets, used in Sync Screen and Detail TabView
class DetailValue extends StatelessWidget {
  final String stringToShow;
  final TextStyle? textStyle;
  final double? textScaleFactor;
  const DetailValue({
    Key? key,
    required this.stringToShow,
    this.textStyle,
    this.textScaleFactor,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      stringToShow,
      textScaleFactor: textScaleFactor,
      style: TextStyle(
        fontFamily: textStyle?.fontFamily ?? Strings.primaryFontFamily,
        fontWeight: textStyle?.fontWeight ?? FontWeight.w500,
        fontSize: textStyle?.fontSize ?? 16,
        color: textStyle?.color,
      ),
    );
  }
}
