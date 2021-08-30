import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/presentation/common_widgets/banners/_banner_template.dart';
import 'package:flutter/material.dart';

class LowPriorityBanner extends StatelessWidget {
  final List<Task> listOfTasks;
  const LowPriorityBanner({
    Key? key,
    required this.listOfTasks,
  }) : super(key: key);

  int get lowPriorityTasks {
    return listOfTasks
        .where((task) =>
            (task.taskPriority == TaskPriority.low
            // ||
            //     task.taskPriority == TaskPriority.globalLow
            ) &&
            task.isCompleted == false)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return BannerTemplate(
      firstBoxColor: const Color(0xFF777B84),
      textColor: const Color(0xFFFFFFFF),
      statusName: 'Low Priority',
      statusValue: this.lowPriorityTasks,
    );
  }
}
