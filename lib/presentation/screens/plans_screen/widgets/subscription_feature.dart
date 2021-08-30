import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SubscriptionFeature extends StatelessWidget {
  const SubscriptionFeature({
    Key? key,
    required this.title,
    this.isAdvantage = true,
    this.textStyle,
  }) : super(key: key);

  final String title;
  final bool isAdvantage;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isAdvantage
            ? Icon(
                Icons.check,
                color: Colors.green,
              )
            : Icon(
                Icons.error,
                color: Colors.red[400],
              ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: AutoSizeText(
            title,
            style: TextStyle(
              fontSize: textStyle?.fontSize ?? 20,
              fontWeight: textStyle?.fontWeight ?? FontWeight.w400,
              color: textStyle?.color,
            ),
          ),
        ),
      ],
    );
  }
}
