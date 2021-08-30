import 'package:flutter/material.dart';

class DetailMaker extends StatelessWidget {
  final Widget firstWidget;
  final Widget? secondWidget;

  const DetailMaker({
    Key? key,
    required this.firstWidget,
    this.secondWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: firstWidget,
            ),
          ),
          if (secondWidget != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: secondWidget,
              ),
            ),
        ],
      ),
    );
  }
}
