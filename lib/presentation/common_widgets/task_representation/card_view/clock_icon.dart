import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ClockIcon extends StatelessWidget {
  const ClockIcon({
    Key? key,
    required this.isBy,
    required this.isOverdue,
  }) : super(key: key);

  final bool isBy;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    return Icon(
      isBy ? Icons.access_alarm : Icons.access_time,
      color: isOverdue
          ? Theme.of(context).overdueBannerColor
          : Theme.of(context).taskAddOnColor,
      size: 16,
    );
  }
}
