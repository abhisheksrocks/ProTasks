import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class RecursiveIcon extends StatelessWidget {
  const RecursiveIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.refresh,
      size: 16,
      color: Theme.of(context).taskAddOnColor,
    );
  }
}
