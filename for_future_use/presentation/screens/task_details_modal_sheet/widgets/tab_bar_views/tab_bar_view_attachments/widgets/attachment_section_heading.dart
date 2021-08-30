import 'package:protasks/core/constants/strings.dart';
import 'package:flutter/material.dart';

class AttachmentSectionHeading extends StatelessWidget {
  const AttachmentSectionHeading({
    Key? key,
    required this.padding,
    required this.sectionTitle,
    this.actionWidget,
  }) : super(key: key);

  final EdgeInsets padding;
  final String sectionTitle;
  final Widget? actionWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            sectionTitle,
            style: TextStyle(
              fontFamily: Strings.primaryFontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (actionWidget != null) actionWidget!,
        ],
      ),
    );
  }
}
