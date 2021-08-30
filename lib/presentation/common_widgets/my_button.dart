import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  MyButton({
    Key? key,
    this.icon,
    this.label,
    this.onTap,
    this.isToggleOn = true,
    this.isError = false,
  }) : super(key: key);

  final Icon? icon;
  final Widget? label;
  final void Function()? onTap;
  final bool isToggleOn;
  final bool isError;

  Widget? widgetToShow(BuildContext context) {
    if (label == null) {
      return null;
    }
    if (label is Text) {
      Brightness currentBrightness = Theme.of(context).brightness;
      if (currentBrightness == Brightness.dark) {
        return label;
      }
      return Text(
        (label as Text).data!,
        style: (label as Text).style!.copyWith(
            color: ((!isToggleOn && onTap != null)
                ? Theme.of(context).accentColor
                : Colors.white)),
      );
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
        color: isError
            ? Theme.of(context).errorColor
            : !isToggleOn && onTap != null
                ? Colors.transparent
                : Theme.of(context).accentColor,
        shape: !isToggleOn && onTap != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: Theme.of(context).accentColor,
                ),
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (0.75 * 0.5 * ((icon?.size) ?? 16)),
              vertical: (0.75 * 0.5 * ((icon?.size) ?? 16)),
            ),
            child: IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) icon!,
                  if (icon != null && label != null)
                    SizedBox(
                      width: (icon!.size ?? 16) * 0.25,
                    ),
                  if (label != null) Expanded(child: widgetToShow(context)!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
