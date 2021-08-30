import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWithDay extends StatelessWidget {
  /// Representation:-
  ///
  /// Today, 28 Apr 2021______________________[WEDNESDAY]
  DateWithDay({
    Key? key,
    required this.dateTime,
  }) : super(key: key);

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AutoSizeText(
            '${ExtraFunctions.headerDate(dateTime)}',
            textAlign: TextAlign.start,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            // color: Theme.of(context).accentColor,
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '${DateFormat("EEEE").format(dateTime).toUpperCase()}',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
