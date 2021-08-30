import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/presentation/common_widgets/banners/_banner_template.dart';
import 'package:flutter/material.dart';

class MediumPriorityBanner extends StatelessWidget {
  final List<Task> listOfTasks;
  const MediumPriorityBanner({
    Key? key,
    required this.listOfTasks,
  }) : super(key: key);

  int get mediumPriorityTasks {
    return listOfTasks
        .where((element) =>
            (element.taskPriority == TaskPriority.medium
            // ||  element.taskPriority == TaskPriority.globalMedium
            ) &&
            element.isCompleted == false)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return BannerTemplate(
      // key: key,
      firstBoxColor: const Color(0xFF40B45C),
      // firstBoxColor: const Color(0xffffaf50),
      textColor: const Color(0xFFFFFFFF),
      statusName: 'Medium Priority',
      statusValue: this.mediumPriorityTasks,
    );
  }
}
