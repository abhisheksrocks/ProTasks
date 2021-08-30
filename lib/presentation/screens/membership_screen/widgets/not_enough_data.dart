import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:flutter/material.dart';

class NotEnoughData extends StatelessWidget {
  const NotEnoughData({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Opacity(
              opacity: 0.2,
              child: LayoutBuilder(
                builder: (context, constraints) => Icon(
                  Icons.bubble_chart,
                  size: constraints.maxHeight < constraints.maxWidth
                      ? constraints.maxHeight
                      : constraints.maxWidth,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  "Not enough data to show",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Strings.primaryFontFamily,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
