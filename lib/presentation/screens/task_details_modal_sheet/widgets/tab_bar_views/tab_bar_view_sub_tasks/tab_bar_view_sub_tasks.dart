import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/task_details_modal_sheet_specific/task_details_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/task_details_modal_sheet_specific/task_sub_tasks_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/status_nav_bar_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/presentation/common_widgets/task_representation/card_view/task_card_view.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/add_new_task_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

import '../../../task_details_modal_sheet.dart';

import 'package:protasks/core/themes/app_theme.dart';

class TabBarViewSubTasks extends StatelessWidget {
  const TabBarViewSubTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<KeyboardVisibilityWithFocusNodeCubit>().dismissKeyboard();
    return BlocBuilder<TaskSubTasksCubit, TaskSubTasksState>(
        builder: (context, state) {
      if (state is TaskSubTasksLoaded) {
        List<Task> _subtaskList = state.subtaskList;
        late Widget mainWidgetToShow;

        if (_subtaskList.length == 0) {
          mainWidgetToShow = Center(
            child: Text("No sub-tasks"),
          );
        } else {
          mainWidgetToShow = ImplicitlyAnimatedList<Task>(
            items: _subtaskList,
            areItemsTheSame: (item1, item2) => item1.id == item2.id,
            itemBuilder: (context, animation, currentTask, i) {
              TaskSubTasksCubit _taskSubTaskCubit =
                  context.read<TaskSubTasksCubit>();
              return SizeFadeTransition(
                animation: animation,
                sizeFraction: 0.7,
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return TaskDetailsModalSheetProvider(
                          task: currentTask,
                        );
                      },
                    );
                  },
                  child: TaskCardView(
                    currentTask: currentTask,
                    dataRefreshingFunction: _taskSubTaskCubit.refreshData,
                  ),
                ),
              );
            },
          );
        }

        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (context.read<SingleTaskDetailsCubit>().task.parentTaskId !=
                        Strings.noTaskID)
                    ? Material(
                        color: Theme.of(context).accentColor.withOpacity(0.2),
                        child: InkWell(
                          onTap: () async {
                            Task taskToShow = (await TasksDao()
                                .getSingleTaskDetailsStream(
                                    taskId: context
                                        .read<SingleTaskDetailsCubit>()
                                        .task
                                        .parentTaskId)
                                .first)!;
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return TaskDetailsModalSheetProvider(
                                  task: taskToShow,
                                );
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.levelUpAlt,
                                  size: 16,
                                  // color: Theme.of(context).accentColor,
                                  color: context
                                              .read<StatusNavBarCubit>()
                                              .state
                                              .themeMode ==
                                          ThemeMode.dark
                                      ? Colors.white
                                      : Theme.of(context).accentColor,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Go to Parent Task",
                                  style: TextStyle(
                                    fontFamily: Strings.primaryFontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    // color: Colors.white,
                                    color: context
                                                .read<StatusNavBarCubit>()
                                                .state
                                                .themeMode ==
                                            ThemeMode.dark
                                        ? Colors.white
                                        : Theme.of(context).accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        color: Theme.of(context).chatTextFieldColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          "No Parent Task",
                          style: TextStyle(
                            fontFamily: Strings.primaryFontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                Expanded(child: mainWidgetToShow),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              // padding: const EdgeInsets.symmetric(
              //   horizontal: 16,
              //   vertical: 16,
              // ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Task currentTask =
                      context.read<SingleTaskDetailsCubit>().task;
                  currentTask.isDeleted
                      ? Fluttertoast.showToast(msg: "Restore task first")
                      : showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          enableDrag: false,
                          builder: (context) => AddNewTaskModalSheetProvider(
                            groupIdToSelectByDefault: currentTask.groupId,
                            isGroupChangeAllowed: false,
                            parentTaskId: currentTask.id,
                          ),
                        );
                },
                label: Text("Add sub-task"),
                icon: Icon(Icons.add),
              ),
            ),
          ],
        );
      }

      return Center(
        child: Text("Loading..."),
      );
    });
  }
}
