import 'package:protasks/core/constants/strings.dart';
import 'package:flutter/material.dart';

class AttachmentActionButton extends StatelessWidget {
  const AttachmentActionButton({
    Key? key,
    required this.iconToShow,
    required this.buttonText,
    required this.sideLength,
    this.onTap,
  }) : super(key: key);

  final double sideLength;
  final Function()? onTap;
  final String buttonText;
  final Icon iconToShow;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(4),
      color: Theme.of(context).primaryColor,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: sideLength,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Column(
                children: [
                  const Spacer(
                    flex: 2,
                  ),
                  Icon(
                    iconToShow.icon,
                    size: iconToShow.size ?? sideLength * 0.6,
                    color: iconToShow.color ?? Colors.white,
                  ),
                  const Spacer(),
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.white38,
                      fontFamily: Strings.primaryFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
