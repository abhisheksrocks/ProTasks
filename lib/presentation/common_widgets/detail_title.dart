import 'package:flutter/material.dart';

import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';

// TODO: Move it to common widgets, used in Sync Screen and Detail TabView
class DetailTitle extends StatelessWidget {
  final String title;
  const DetailTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: Strings.secondaryFontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: Theme.of(context).taskAddOnColor,
      ),
    );
  }
}
