import 'package:protasks/data/models/task.dart';
import 'package:protasks/presentation/common_widgets/banners/_banner_template.dart';
import 'package:flutter/material.dart';

class TaskBanner extends StatelessWidget {
  final List<Task> listOfTasks;
  TaskBanner({
    Key? key,
    required this.listOfTasks,
  }) : super(key: key);

  int get allIncompleteTasks {
    return listOfTasks.where((element) => !element.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    return BannerTemplate(
      firstBoxColor: const Color(0xFFDDDDDD),
      textColor: const Color(0xFF000000),
      statusName: 'Tasks',
      statusValue: allIncompleteTasks,
    );
  }
}
