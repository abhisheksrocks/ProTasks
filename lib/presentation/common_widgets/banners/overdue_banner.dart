import 'package:protasks/data/models/task.dart';
import 'package:protasks/presentation/common_widgets/banners/_banner_template.dart';
import 'package:flutter/material.dart';

class OverdueBanner extends StatelessWidget {
  final List<Task> listOfTasks;
  OverdueBanner({
    Key? key,
    required this.listOfTasks,
  }) : super(key: key);

  int get overdues {
    DateTime _dateTimeNow = DateTime.now();
    return listOfTasks
        .where((element) =>
            element.time.isBefore(_dateTimeNow) && !element.isCompleted)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return BannerTemplate(
      // key: key,
      firstBoxColor: const Color(0xFFFF5252),
      textColor: const Color(0xFFFFFFFF),
      statusName: 'Overdues',
      statusValue: overdues,
    );
  }
}
