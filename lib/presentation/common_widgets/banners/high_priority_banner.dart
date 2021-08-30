import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/presentation/common_widgets/banners/_banner_template.dart';
import 'package:flutter/material.dart';

class HighPriorityBanner extends StatelessWidget {
  final List<Task> listOfTasks;
  const HighPriorityBanner({
    Key? key,
    required this.listOfTasks,
  }) : super(key: key);

  int get highPriorityTasks {
    return listOfTasks
        .where((task) =>
            (task.taskPriority == TaskPriority.high
            // || task.taskPriority == TaskPriority.globalHigh
            ) &&
            task.isCompleted == false)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return BannerTemplate(
      firstBoxColor: const Color(0xFFAB47BC),
      textColor: const Color(0xFFFFFFFF),
      statusName: 'High Priority',
      statusValue: this.highPriorityTasks,
    );
  }
}
