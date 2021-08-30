import 'package:flutter/material.dart';
import 'package:protasks/core/themes/app_theme.dart';

class SampleTextPlaceholder extends StatelessWidget {
  const SampleTextPlaceholder({
    Key? key,
    required this.width,
    this.height = 24,
    this.color,
  }) : super(key: key);

  final double height;
  final double width;
  final Color? color;

  final Duration animationDuration = const Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: color ?? Theme.of(context).primaryTextColor.withOpacity(0.1),
      ),
    );
  }
}
