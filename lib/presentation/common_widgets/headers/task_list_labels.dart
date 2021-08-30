import 'package:protasks/data/models/task.dart';
import 'package:protasks/presentation/common_widgets/banners/high_priority_banner.dart';
import 'package:protasks/presentation/common_widgets/banners/low_priority_banner.dart';
import 'package:protasks/presentation/common_widgets/banners/medium_priority_banner.dart';
import 'package:protasks/presentation/common_widgets/banners/overdue_banner.dart';
import 'package:protasks/presentation/common_widgets/banners/task_banner.dart';
import 'package:flutter/material.dart';

class TaskListLabels extends StatelessWidget {
  /// Representation:-
  ///
  /// [Tasks|5] [Overdues|0] [High Priority|2] [Medium Priority|1] [Low Priority|2]
  const TaskListLabels({
    Key? key,
    required List<Task> taskList,
    this.spacing = 4,
    this.runSpacing = 4,
  })  : _taskList = taskList,
        super(key: key);

  final double spacing;
  final double runSpacing;
  final List<Task> _taskList;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        TaskBanner(
          listOfTasks: _taskList,
        ),
        OverdueBanner(
          listOfTasks: _taskList,
        ),
        HighPriorityBanner(
          listOfTasks: _taskList,
        ),
        MediumPriorityBanner(
          listOfTasks: _taskList,
        ),
        LowPriorityBanner(
          listOfTasks: _taskList,
        ),
      ],
    );
  }
}
