import 'package:protasks/data/data_providers/chats_dao.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:flutter/material.dart';

import '../my_circular_check_box.dart';
import '../priority_icon.dart';
import '../reminder_widget.dart';
import '../task_description.dart';
import '../task_group_icon.dart';
import '../time_widget.dart';
import 'clock_icon.dart';
import 'chat_icon.dart';
import 'recursive_icon.dart';
import 'subtask_icon.dart';

class TaskCardView extends StatelessWidget {
  const TaskCardView({
    Key? key,
    required this.currentTask,
    this.dataRefreshingFunction,
    this.showGroupWidget = true,
    this.opacityOnCompleted = true,
    this.showDelete = true,
  }) : super(key: key);

  final Task currentTask;
  final Function? dataRefreshingFunction;
  final bool showGroupWidget;
  final bool opacityOnCompleted;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Opacity(
          opacity: (currentTask.isCompleted && opacityOnCompleted) ? 0.6 : 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AbsorbPointer(
                    absorbing: currentTask.isDeleted,
                    child: MyCircularCheckBox(
                      key: ValueKey("${currentTask.id}CircularCheckBox"),
                      value: currentTask.isCompleted,
                      onChanged: (value) async {
                        await TasksDao().changeIsCompletedNew(
                          taskId: currentTask.id,
                        );
                      },
                    ),
                  ),
                  if (currentTask.isDeleted)
                    Icon(
                      Icons.delete,
                      color: Theme.of(context).errorColor.withOpacity(0.8),
                    ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 16,
                      ),
                      child: TaskDescription(
                        key: ValueKey("${currentTask.id}TaskDescription"),
                        description: currentTask.description,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    dataRefreshingFunction == null
                        ? Builder(
                            builder: (context) {
                              // currentTask.isOverdue can be an expensive task if executed multiple number of times
                              // therefore, made a builder to save the output.
                              bool isOverdue = currentTask.isOverdue;
                              return wrapWidgetMaker(isOverdue);
                            },
                          )
                        : FutureBuilder<bool?>(
                            future: ExtraFunctions.updateAtThisDateTime(
                                dateTime: currentTask.time),
                            // initialData: null,
                            builder: (context, snapshot) {
                              bool isOverdue = currentTask.isOverdue;

                              // **** NOT SURE FOLLOWING IS THE CORRECT EXPLAINATION *******
                              // * It looks like when the futureBuilder is being removed from
                              // * the widget tree, if the [future] is still not completed, it quickly
                              // * finishes that. In our case, that leads to refreshData twice.
                              // * Specifying snapshot.connectionState == ConnectionState.done
                              // * doesn't let the if function to finish, thereby not letting the state
                              // * update twice.

                              // *************************   OR   *******************************

                              // **** NOT SURE FOLLOWING IS THE CORRECT EXPLAINATION *******
                              // * It looks like when the STATE is refreshed
                              // * if the [future] is still not completed, it recalls the
                              // * [future]. In our case, that leads to refreshData twice.
                              // * Specifying snapshot.connectionState == ConnectionState.done
                              // * doesn't let the if function to finish, thereby not letting the state
                              // * update twice.

                              if (snapshot.data != null &&
                                  snapshot.connectionState ==
                                      ConnectionState.done) {
                                print(
                                    "Task ${currentTask.description} by FutureBuilder");
                                // _taskSubTaskCubit.refreshData();
                                dataRefreshingFunction!();
                              }

                              return wrapWidgetMaker(isOverdue);
                            },
                          ),
                    const SizedBox(
                      height: 4,
                    ),
                    StreamBuilder(
                      stream: ExtraFunctions.minimalTaskRepresentation(
                        currentTask.id,
                      ),

                      // * [initialData] COPIED FROM TasksDao.minimalTaskRepresentation()
                      // * YOU CAN ALSO USE IT TO SEE HOW ELEMENTS WILL BE STORED
                      // initialData: {
                      //   'subtaskCount':
                      //       TasksDao.taskSubtasksCount[
                      //               currentTask.id] ??
                      //           0,
                      // },
                      builder: (context, snapshot) {
                        // Map<String, int> returnedMap =
                        //     snapshot.data!;
                        // int subtaskCount =
                        //     returnedMap['subtaskCount']!;
                        int subtaskCount =
                            TasksDao.taskSubtasksCount[currentTask.id] ?? 0;

                        int unreadChatCount =
                            ChatsDao.taskUnreadCount[currentTask.id] ?? 0;

                        bool isRecursive = currentTask.isRecursive;

                        return Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            PriorityIcon(
                              key: ValueKey(
                                  "${currentTask.id}${currentTask.taskPriority}"),
                              priority: currentTask.taskPriority,
                            ),
                            if (showGroupWidget)
                              TaskGroupIcon(
                                key: ValueKey("${currentTask.id}TaskGroupIcon"),
                                groupId: currentTask.groupId,
                              ),
                            if (isRecursive)
                              RecursiveIcon(
                                key: ValueKey(
                                    "${currentTask.id}RecursiveIconWithoutCheck"),
                              ),
                            if (subtaskCount != 0)
                              SubtaskIcon(
                                key: ValueKey("${currentTask.id}SubtaskIcon"),
                                subtaskCount: subtaskCount,
                              ),
                            if (unreadChatCount != 0)
                              ChatIcon(
                                key: ValueKey("${currentTask.id}ChatIcons"),
                                countToShow: unreadChatCount,
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(
          height: 0,
        ),
      ],
    );
  }

  Wrap wrapWidgetMaker(bool isOverdue) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ClockIcon(
          key: ValueKey("${currentTask.id}ClockIcon"),
          isBy: currentTask.isBy,
          isOverdue: isOverdue,
        ),
        TimeWidget(
          key: ValueKey("${currentTask.id}TimeWidget"),
          taskTime: currentTask.time,
          isOverdue: isOverdue,
          isBy: currentTask.isBy,
          fontSize: 12,
          minimal: true,
        ),
        ReminderWidget(
          key: ValueKey("${currentTask.id}ReminderWidget"),
          taskTime: currentTask.time,
          remindTimer: currentTask.remindTimer,
          isOverdue: isOverdue,
          inWords: true,
          withBrackets: true,
        ),
      ],
    );
  }
}
