import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class PersonIcon extends StatelessWidget {
  const PersonIcon({
    Key? key,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 36,
      margin: const EdgeInsets.only(
        right: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ??
            Theme.of(context).primaryTextColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          // color: Colors.white,
          color: foregroundColor,
        ),
      ),
    );
  }
}
