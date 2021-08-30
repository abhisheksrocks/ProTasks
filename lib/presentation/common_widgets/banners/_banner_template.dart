import 'package:flutter/material.dart';

class BannerTemplate extends StatefulWidget {
  final String statusName;
  final int statusValue;
  final Color firstBoxColor;
  final Color textColor;

  BannerTemplate({
    Key? key,
    required this.statusName,
    required this.statusValue,
    required this.firstBoxColor,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  _BannerTemplateState createState() => _BannerTemplateState();
}

class _BannerTemplateState extends State<BannerTemplate> {
  late Color darkenedColor;
  Container defaultContainer({
    required Color color,
    required String text,
  }) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      child: Text(
        '$text',
        style: TextStyle(
          color: widget.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget noValueContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 3,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          // color: Color(0xFF3B3D42),
          color: const Color(0xFFB5B5B5),
          // color: Colors.white,
          width: 1,
        ),
      ),
      child: Text(
        'No ${widget.statusName}',
        style: TextStyle(
          color: const Color(0xFFB5B5B5),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  void initState() {
    HSLColor _hslcolor = HSLColor.fromColor(widget.firstBoxColor);
    if (widget.textColor == Colors.white) {
      darkenedColor = _hslcolor
          .withLightness((_hslcolor.lightness - 0.1).clamp(0.0, 1.0))
          .toColor();
    } else {
      darkenedColor = _hslcolor
          .withLightness((_hslcolor.lightness - 0.2).clamp(0.0, 1.0))
          .toColor();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.statusValue == 0) {
      return noValueContainer();
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            defaultContainer(
              color: widget.firstBoxColor,
              text: widget.statusName,
            ),
            defaultContainer(
              color: darkenedColor,
              text: widget.statusValue.toString(),
            )
          ],
        ),
      );
    }
  }
}
