import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_assignees_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_date_time_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_by_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_group_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_reminder_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_repeat_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/logic/notification_handler.dart';
import 'package:protasks/presentation/common_widgets/my_button.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/my_will_pop_scope/confirmation_dialog.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/my_will_pop_scope/my_will_pop_scope.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/widgets/current_assignees_widget.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/widgets/current_by_widget.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/widgets/current_date_widget.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/widgets/current_group_widget.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/widgets/current_priority_widget.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/widgets/current_reminder_widget.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/widgets/current_repeat_widget.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/widgets/current_time_widget.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/widgets/new_task_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_priority_cubit.dart';

// TODO: Change it name to a resonable one
// because for later developments one might not always remember if a widget has provider or not

class AddNewTaskModalSheetProvider extends StatelessWidget {
  const AddNewTaskModalSheetProvider({
    Key? key,
    this.groupIdToSelectByDefault,
    this.isGroupChangeAllowed = true,
    this.parentTaskId = Strings.noTaskID,
    this.taskToEdit,
  }) : super(key: key);

  final String? groupIdToSelectByDefault;
  final bool isGroupChangeAllowed;
  final String parentTaskId;
  final Task? taskToEdit;

  @override
  Widget build(BuildContext context) {
    return MyWillPopScope(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TextEditingControllerCubit>(
            create: (context) => TextEditingControllerCubit(),
          ),
          BlocProvider<CurrentPriorityCubit>(
            create: (context) => CurrentPriorityCubit(
              defaultTaskPriority: taskToEdit?.taskPriority,
            ),
          ),
          BlocProvider<CurrentGroupCubit>(
            create: (context) => CurrentGroupCubit(
              groupIDtoSelectByDefault:
                  taskToEdit?.groupId ?? groupIdToSelectByDefault,
              isGroupChangeAllowed:
                  taskToEdit != null ? false : isGroupChangeAllowed,
            ),
          ),
          BlocProvider<CurrentByCubit>(
            create: (context) => CurrentByCubit(
              defaultIsBy: taskToEdit?.isBy,
            ),
          ),
          BlocProvider<CurrentDateTimeCubit>(
            create: (context) => CurrentDateTimeCubit(
              defaultDateTime: taskToEdit?.time,
            ),
            // lazy: false,
          ),
          BlocProvider<CurrentReminderCubit>(
            create: (context) => CurrentReminderCubit(
              currentDateTimeCubit: context.read<CurrentDateTimeCubit>(),
              defaultReminder: taskToEdit?.remindTimer,
            ),
            // lazy: false,
          ),
          BlocProvider<CurrentRepeatCubit>(
            create: (context) => CurrentRepeatCubit(
              currentReminderCubit: context.read<CurrentReminderCubit>(),
              defaultRecursionInterval: taskToEdit?.recursionInterval,
              defaultRecursionTill: taskToEdit?.recursionTill,
            ),
          ),
          BlocProvider<CurrentAssigneesCubit>(
            create: (context) => CurrentAssigneesCubit(
              currentGroupCubit: context.read<CurrentGroupCubit>(),
              defaultAssignees: taskToEdit?.assignedTo,
            ),
          ),
        ],
        child: AddNewTaskModalSheet(
          parentTaskId: parentTaskId,
          taskToEdit: taskToEdit,
        ),
      ),
    );
  }
}

class AddNewTaskModalSheet extends StatelessWidget {
  const AddNewTaskModalSheet({
    Key? key,
    required this.parentTaskId,
    required this.taskToEdit,
  }) : super(key: key);

  final String parentTaskId;
  final Task? taskToEdit;

  final Duration animationDuration = const Duration(milliseconds: 500);

  final Curve animationCurve = Curves.easeInOut;

  final double buttonIconSize = 16;

  final TextStyle buttonTextStyle = const TextStyle(
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => ConfirmationDialog(),
              );
              if (confirm == true) {
                Navigator.of(context).pop();
              }
            },
            // child: SizedBox(),
          ),
        ),
        Container(
          color: Theme.of(context).backgroundColor,
          child: IntrinsicHeight(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 8,
                      left: 20,
                      right: 20,
                    ),
                    child: NewTaskTextField(
                      defaultText: taskToEdit?.description,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                CurrentPriorityWidget(),
                                CurrentGroupWidget(),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                CurrentByWidget(),
                                CurrentTimeWidget(
                                  buttonIconSize: buttonIconSize,
                                ),
                                CurrentDateWidget(
                                  buttonIconSize: buttonIconSize,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                CurrentReminderWidget(
                                  buttonIconSize: buttonIconSize,
                                  taskTime: context
                                      .read<CurrentDateTimeCubit>()
                                      .state
                                      .finalTaskTime,
                                ),
                                CurrentRepeatWidget(
                                    buttonIconSize: buttonIconSize),
                                if (context
                                        .watch<LoginCubit>()
                                        .state
                                        .currentLoginState ==
                                    CurrentLoginState.loggedIn)
                                  CurrentAssigneesWidget(
                                      buttonIconSize: buttonIconSize),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Builder(builder: (context) {
                        bool canSubmit = true;
                        if (context
                            .watch<TextEditingControllerCubit>()
                            .state
                            .textString
                            .isEmpty) {
                          canSubmit = false;
                        }
                        if (!(context.watch<CurrentGroupCubit>().state
                            is CurrentGroupLoaded)) {
                          canSubmit = false;
                        }
                        if (!context
                            .watch<CurrentDateTimeCubit>()
                            .state
                            .isAcceptable) {
                          canSubmit = false;
                        }
                        if (!context
                            .watch<CurrentReminderCubit>()
                            .state
                            .isAcceptable) {
                          canSubmit = false;
                        }
                        if (!context
                            .watch<CurrentRepeatCubit>()
                            .state
                            .isAcceptable) {
                          canSubmit = false;
                        }

                        return MyButton(
                          icon: Icon(
                            Icons.check,
                            size: 32,
                            color: const Color(0xFFFFFFFF),
                          ),
                          onTap: canSubmit
                              ? () async {
                                  final CurrentGroupLoaded
                                      currentGroupLoadedState = context
                                          .read<CurrentGroupCubit>()
                                          .state as CurrentGroupLoaded;

                                  final TextEditingController
                                      textEditingController = context
                                          .read<TextEditingControllerCubit>()
                                          .textEditingController!;

                                  final CurrentDateTime currentDateTime =
                                      context
                                          .read<CurrentDateTimeCubit>()
                                          .state;

                                  final DateTime taskTime =
                                      currentDateTime.finalTaskTime;

                                  final CurrentBy currentBy =
                                      context.read<CurrentByCubit>().state;

                                  final CurrentPriority currentPriority =
                                      context
                                          .read<CurrentPriorityCubit>()
                                          .state;

                                  final CurrentRepeatState currentRepeatState =
                                      context.read<CurrentRepeatCubit>().state;

                                  final Person currentUser =
                                      await UsersDao().getCurrentUser();

                                  final CurrentReminderState
                                      currentReminderState = context
                                          .read<CurrentReminderCubit>()
                                          .state;

                                  final CurrentAssigneesLoaded
                                      currentAssigneesLoaded = context
                                          .read<CurrentAssigneesCubit>()
                                          .state as CurrentAssigneesLoaded;

                                  // print(textEditingControllerState)

                                  // TODO: CHANGE THIS MOST PROBABLY. (Its better to mangage from TasksDao instead)
                                  final Task taskToInsert = Task(
                                    id: taskToEdit?.id ??
                                        ExtraFunctions.createId,
                                    groupId:
                                        currentGroupLoadedState.currentGroup.id,
                                    description:
                                        textEditingController.text.trim(),
                                    time: taskTime,
                                    isBy: currentBy.isBy,
                                    isCompleted: false,
                                    taskPriority: currentPriority.taskPriority,
                                    recursionInterval:
                                        currentRepeatState.recursionInterval,
                                    recursionTill:
                                        currentRepeatState.recursionTill,
                                    createdOn:
                                        taskToEdit?.createdOn ?? DateTime.now(),
                                    createdBy: taskToEdit?.createdBy ??
                                        currentUser.uid,
                                    modifiedOn: DateTime.now(),
                                    modifiedBy: currentUser.uid,
                                    parentTaskId: taskToEdit?.parentTaskId ??
                                        parentTaskId,
                                    remindTimer:
                                        currentReminderState.remindTimer,
                                    assignedTo:
                                        currentAssigneesLoaded.currentAssigness,
                                    isSynced: false,
                                    isDeleted: false,
                                  );

                                  // await NotificationHandler.makeTaskReminder(
                                  //   context,
                                  //   givenTask: taskToInsert,
                                  // );

                                  await TasksDao()
                                      .insertOrUpdateTask(taskToInsert);

                                  Navigator.of(context).pop();
                                }
                              : null,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
