import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_priority_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:protasks/core/themes/app_theme.dart';

class CurrentPriorityWidget extends StatelessWidget {
  const CurrentPriorityWidget({Key? key}) : super(key: key);

  Color findWidgetBackgroundColor({
    required BuildContext context,
    required TaskPriority taskPriority,
  }) {
    switch (taskPriority) {
      case TaskPriority.high:
        return Theme.of(context).highPriorityBannerColor;
      case TaskPriority.medium:
        return Theme.of(context).mediumPriorityBannerColor;
      case TaskPriority.low:
        return Theme.of(context).lowPriorityBannerColor;
      default:
        return Theme.of(context).errorColor;
    }
  }

  String findWidgetText({
    required BuildContext context,
    required TaskPriority taskPriority,
  }) {
    switch (taskPriority) {
      case TaskPriority.high:
        return "!!!";
      case TaskPriority.medium:
        return "!!";
      case TaskPriority.low:
        return "!";
      default:
        return "XXX";
    }
  }

  TaskPriority nextPriority({required TaskPriority currentPriority}) {
    switch (currentPriority) {
      case TaskPriority.high:
        return TaskPriority.low;
      case TaskPriority.medium:
        return TaskPriority.high;
      case TaskPriority.low:
        return TaskPriority.medium;
      default:
        return TaskPriority.low;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentPriorityCubit, CurrentPriority>(
      builder: (context, state) {
        return Material(
          color: findWidgetBackgroundColor(
            context: context,
            taskPriority: state.taskPriority,
          ),
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              context.read<CurrentPriorityCubit>().changePriority(
                    taskPriority:
                        nextPriority(currentPriority: state.taskPriority),
                    isForced: true,
                  );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${findWidgetText(
                      context: context,
                      taskPriority: state.taskPriority,
                    )}',
                    style: TextStyle(
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
