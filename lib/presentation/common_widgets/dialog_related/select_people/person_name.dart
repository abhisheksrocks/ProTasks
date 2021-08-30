import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:flutter/material.dart';

class PersonName extends StatelessWidget {
  const PersonName({
    Key? key,
    required this.stringToShow,
  }) : super(key: key);

  final String stringToShow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AutoSizeText(
            stringToShow,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: Strings.secondaryFontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
