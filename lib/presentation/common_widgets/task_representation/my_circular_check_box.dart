import 'package:protasks/presentation/common_widgets_external/task_representation/circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MyCircularCheckBox extends StatelessWidget {
  final void Function(bool?)? onChanged;
  final bool? value;
  final bool autoFocus;
  final Color? checkColor;
  final MaterialStateProperty<Color?>? fillColor;
  final Color? focusColor;
  final FocusNode? focusNode;
  final Color? activeColor;
  final Color? hoverColor;
  final MaterialTapTargetSize? materialTapTargetSize;
  final MouseCursor? mouseCursor;
  final MaterialStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final bool tristate;
  final VisualDensity visualDensity;
  const MyCircularCheckBox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.autoFocus = false,
    this.checkColor,
    this.activeColor,
    this.focusNode,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.materialTapTargetSize,
    this.mouseCursor,
    this.overlayColor,
    this.splashRadius,
    this.tristate = false,
    this.visualDensity = VisualDensity.comfortable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Container();
    return CircularCheckBox(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? Theme.of(context).accentColor,
      autofocus: autoFocus,
      checkColor: checkColor,
      fillColor: fillColor,
      focusColor: focusColor,
      focusNode: focusNode,
      hoverColor: hoverColor,
      materialTapTargetSize: materialTapTargetSize,
      key: key,
      mouseCursor: mouseCursor,
      overlayColor: overlayColor,
      splashRadius: splashRadius,
      tristate: tristate,
      visualDensity: visualDensity,
    );
    // return Transform.scale(
    //   scale: 1.3,
    //   child: Checkbox(
    //     value: value,
    //     onChanged: onChanged,
    //     activeColor: activeColor ?? Theme.of(context).accentColor,
    //     autofocus: autoFocus,
    //     checkColor: checkColor,
    //     fillColor: fillColor,
    //     focusColor: focusColor,
    //     focusNode: focusNode,
    //     hoverColor: hoverColor,
    //     materialTapTargetSize: materialTapTargetSize,
    //     key: key,
    //     mouseCursor: mouseCursor,
    //     overlayColor: overlayColor,
    //     splashRadius: splashRadius,
    //     tristate: tristate,
    //     visualDensity: visualDensity,
    //     // shape: const CircleBorder(),
    //   ),
    // );
  }
}
