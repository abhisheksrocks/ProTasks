import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/recursion_interval.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/my_will_pop_scope/confirmation_dialog.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/select_people/person_icon.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/add_new_task_modal_sheet.dart';
import 'package:protasks/presentation/common_widgets/detail_maker.dart';
import 'package:protasks/presentation/common_widgets/detail_title.dart';
import 'package:protasks/presentation/common_widgets/detail_value.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/widgets/tab_bar_views/tab_bar_view_details/widgets/priority_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/task_details_modal_sheet_specific/task_details_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:protasks/presentation/common_widgets/task_representation/priority_icon.dart';
import 'package:protasks/presentation/common_widgets/task_representation/reminder_widget.dart';
import 'package:protasks/presentation/common_widgets/task_representation/time_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TabBarViewDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This statement is only if the chat screen has keyboard showing and it moves to this screen
    // I noticed that it doesn't [dispose()], and hence the keyboard remains on the screen.
    // FocusScope.of(context).requestFocus(new FocusNode());
    //
    // Using context.read<KeyboardVisibilityWithFocusNodeCubit>().dismissKeyboard() since I
    // moved KeyboardVisibilityWithFocusNodeCubit to the whole modalBottomSheet, instead of
    // TabBarViewChat specifically(where it was originally) so I don't think
    // FocusScope.of(context).requestFocus(new FocusNode()) will be required.
    context.read<KeyboardVisibilityWithFocusNodeCubit>().dismissKeyboard();
    return BlocBuilder<SingleTaskDetailsCubit, SingleTaskDetailsState>(
      builder: (context, state) {
        if (state is SingleTaskDetailsLoaded) {
          Task currentTask = state.currentTask;
          TasksDao tasksDaoObject = TasksDao();
          GroupsDao groupsDaoObject = GroupsDao();
          UsersDao usersDaoObject = UsersDao();

          return ListView(
            physics: const BouncingScrollPhysics(
              parent: const AlwaysScrollableScrollPhysics(),
            ),
            children: [
              Wrap(
                runSpacing: 8,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyCircularCheckBox(
                          value: currentTask.isCompleted,
                          onChanged: (value) async {
                            currentTask.isDeleted
                                ? Fluttertoast.showToast(
                                    msg: "Task must be restored first")
                                : await tasksDaoObject.changeIsCompletedNew(
                                    taskId: currentTask.id,
                                  );
                          },
                          visualDensity: VisualDensity.standard,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              right: 16,
                            ),
                            child: Text(
                              currentTask.description,
                              style: TextStyle(
                                fontFamily: Strings.secondaryFontFamily,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DetailMaker(
                    firstWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'TIME'),
                        FutureBuilder(
                          future: ExtraFunctions.updateAtThisDateTime(
                            dateTime: currentTask.time,
                          ),
                          builder: (context, snapshot) {
                            return TimeWidget(
                              key: ValueKey("${currentTask.id}TimeWidget"),
                              taskTime: currentTask.time,
                              isOverdue: currentTask.isOverdue,
                              isBy: currentTask.isBy,
                              fontSize: 16,
                              minimal: false,
                            );
                          },
                        ),
                      ],
                    ),
                    secondWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'REMIND AT'),
                        FutureBuilder(
                          future: ExtraFunctions.updateAtThisDateTime(
                            dateTime: currentTask.time,
                          ),
                          builder: (context, snapshot) {
                            return ReminderWidget(
                              key: ValueKey("${currentTask.id}ReminderWidget"),
                              taskTime: currentTask.time,
                              remindTimer: currentTask.remindTimer,
                              isOverdue: currentTask.isOverdue,
                              inWords: false,
                              withBrackets: false,
                              fontSize: 16,
                              stringToDisplayIfNoReminder: 'No Reminder',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  DetailMaker(
                    firstWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'PRIORITY'),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            new PriorityIcon(
                              key: new ValueKey(
                                  "${currentTask.id}${currentTask.taskPriority}PriorityIcon"),
                              priority: currentTask.taskPriority,
                            ),
                            PriorityText(
                              key: ValueKey(
                                  "${currentTask.id}${currentTask.taskPriority}PriorityText"),
                              priority: currentTask.taskPriority,
                            )
                          ],
                        ),
                      ],
                    ),
                    secondWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'GROUP'),
                        FutureBuilder<String?>(
                          future: groupsDaoObject
                              .findGroupNameById(currentTask.groupId),
                          builder: (context, snapshot) {
                            String stringToShow =
                                GroupsDao.groupIdToName[currentTask.groupId] ??
                                    'Loading⌛';
                            String? receivedData = snapshot.data;
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (receivedData == null) {
                                stringToShow = '<INVALID>';
                              } else {
                                stringToShow = receivedData;
                              }
                            }
                            return DetailValue(
                              stringToShow: stringToShow,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  if (context.read<LoginCubit>().state.currentLoginState ==
                      CurrentLoginState.loggedIn)
                    const Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: const Divider(
                        thickness: 2,
                      ),
                    ),
                  if (context.read<LoginCubit>().state.currentLoginState ==
                      CurrentLoginState.loggedIn)
                    DetailMaker(
                      firstWidget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DetailTitle(title: 'ASSIGNED TO'),
                          const SizedBox(
                            height: 4,
                          ),
                          Builder(
                            builder: (context) {
                              bool notAssignedToAnyone =
                                  currentTask.assignedTo.isEmpty;
                              return FutureBuilder<List<String>>(
                                future: notAssignedToAnyone
                                    ?
                                    // groupsDaoObject.getAllMemberNamesOfGroup(
                                    //     currentTask.groupId,
                                    //   )
                                    null
                                    : usersDaoObject.getUserNamesFromIDs(
                                        currentTask.assignedTo,
                                      ),
                                builder: (context, snapshot) {
                                  Widget widgetToShow;
                                  if (notAssignedToAnyone) {
                                    widgetToShow = Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.person_add_disabled),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            const DetailValue(
                                              stringToShow: 'No one assigned',
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    widgetToShow = Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: const Center(
                                        child:
                                            const CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    List<String> returnedUsers = snapshot.data!;
                                    if (returnedUsers.isNotEmpty) {
                                      List<Widget> _userList = returnedUsers
                                          .map(
                                            (uid) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 4,
                                              ),
                                              child: Row(
                                                children: [
                                                  // Container(
                                                  //   height: 36,
                                                  //   width: 36,
                                                  //   margin:
                                                  //       const EdgeInsets.only(
                                                  //     right: 8,
                                                  //   ),
                                                  //   decoration: BoxDecoration(
                                                  //     color: Theme.of(context)
                                                  //         .backgroundColor,
                                                  //     borderRadius:
                                                  //         BorderRadius.circular(
                                                  //             50),
                                                  //   ),
                                                  //   child: const Center(
                                                  //     child: const Icon(
                                                  //         Icons.person),
                                                  //   ),
                                                  // ),
                                                  PersonIcon(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .accentColor
                                                            .withOpacity(0.2),
                                                    foregroundColor:
                                                        Theme.of(context)
                                                            .accentColor,
                                                  ),
                                                  Expanded(
                                                    child: uid ==
                                                            (FirebaseAuthFunctions
                                                                    .getCurrentUser
                                                                    ?.uid ??
                                                                Strings
                                                                    .defaultUserUID)
                                                        ? DetailValue(
                                                            stringToShow: 'You',
                                                            textStyle:
                                                                TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          )
                                                        : DetailValue(
                                                            stringToShow: UsersDao
                                                                    .usersIdToName[
                                                                uid]!,
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList();

                                      // if (_userList.length > 2) {
                                      //   _userList.add(
                                      //     Padding(
                                      //       padding: const EdgeInsets.symmetric(
                                      //         vertical: 0,
                                      //       ),
                                      //       child: Row(
                                      //         children: [
                                      //           const Spacer(),
                                      //           TextButton(
                                      //             onPressed: () {},
                                      //             child: Text(
                                      //               '${_userList.length - 2} Others',
                                      //             ),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   );
                                      // }
                                      widgetToShow = Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          child: Column(
                                            children: _userList,
                                          ),
                                        ),
                                      );
                                    } else
                                      widgetToShow = const Center(
                                        child:
                                            const Text('Something went wrong'),
                                      );
                                  }

                                  return Container(
                                    // constraints: const BoxConstraints(
                                    //   minHeight: 75,
                                    // ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryTextColor
                                          .withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: widgetToShow,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  if (context.read<LoginCubit>().state.currentLoginState ==
                      CurrentLoginState.loggedIn)
                    const Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: const Divider(
                        thickness: 2,
                      ),
                    ),
                  // DetailMaker(
                  //   firstWidget: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const DetailTitle(title: 'CREATED BY'),
                  //       UserNameWidget(userUID: currentTask.createdBy),
                  //     ],
                  //   ),
                  //   secondWidget: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const DetailTitle(title: 'UPDATED BY'),
                  //       UserNameWidget(userUID: currentTask.modifiedBy),
                  //     ],
                  //   ),
                  // ),
                  DetailMaker(
                    firstWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: "REPEAT INTERVAL"),
                        Builder(
                          builder: (context) {
                            String stringToShow = currentTask
                                        .recursionInterval ==
                                    RecursionInterval.zero
                                ? 'Not Defined'
                                : "Every ${currentTask.recursionInterval.recursionIntervalToString}";
                            // String stringToShow =
                            //     ExtraFunctions.findRecursionIntervalInWords(
                            //           recursionInterval:
                            //               currentTask.recursionInterval,
                            //         ) ??
                            //         'Not Defined';
                            return DetailValue(stringToShow: stringToShow);
                          },
                        ),
                      ],
                    ),
                    secondWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: "REPEATING TILL"),
                        DetailValue(
                          stringToShow: ExtraFunctions.findAbsoluteDateAndTime(
                                time: currentTask.recursionTill,
                              ) ??
                              'Not Defined',
                        ),
                      ],
                    ),
                  ),
                  DetailMaker(
                    firstWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'NEXT TASK TIME'),
                        Builder(
                          builder: (context) {
                            DateTime? nextTaskTime =
                                currentTask.nextPossibleTaskTime;
                            late String stringToShow = "Not Possible";
                            if (nextTaskTime != null) {
                              stringToShow =
                                  ExtraFunctions.findAbsoluteDateAndTime(
                                          time: nextTaskTime) ??
                                      "Not Possible";
                            }
                            return DetailValue(stringToShow: stringToShow);
                          },
                        ),
                      ],
                    ),
                    secondWidget: (context
                                .read<LoginCubit>()
                                .state
                                .currentLoginState ==
                            CurrentLoginState.loggedIn)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const DetailTitle(title: 'SYNC STATUS'),
                              currentTask.isSynced
                                  ? DetailValue(
                                      stringToShow: 'Uploaded to Cloud',
                                      textStyle: TextStyle(
                                        fontFamily: Strings.primaryFontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Theme.of(context).accentColor,
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        DetailValue(
                                          stringToShow: 'Yet to upload ',
                                          textStyle: TextStyle(
                                            fontFamily:
                                                Strings.primaryFontFamily,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Icon(
                                          Icons.error,
                                          size: 20,
                                          color: Theme.of(context)
                                              .errorColor
                                              .withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                            ],
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              // TODO: Implement task delete function
              DetailMaker(
                firstWidget: TextButton(
                  onPressed: () async {
                    // Navigator.of(context).pop();
                    bool? confirmAction = currentTask.isDeleted
                        ? true
                        : await showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmationDialog(
                                content:
                                    'This will also delete all the subtasks(if any) under this task.',
                                actionText: 'Delete task',
                              );
                            },
                          );
                    if (confirmAction == true) {
                      if (!currentTask.isDeleted) {
                        Navigator.of(context).pop();
                      }
                      // await TasksDao().deleteTask(taskId: currentTask.id);
                      await TasksDao().trashOrRestoreTask(
                        taskId: currentTask.id,
                        moveToTrash: currentTask.isDeleted ? false : true,
                      );
                    }
                  },
                  style: currentTask.isDeleted
                      ? Theme.of(context).greenTextButtonStyle
                      : Theme.of(context).errorTextButtonStyle,
                  child: currentTask.isDeleted
                      ? Text("Restore Task")
                      : Text("Delete Task"),
                ),
              ),
              DetailMaker(
                firstWidget: Opacity(
                  opacity: currentTask.isDeleted ? 0.7 : 1,
                  child: TextButton(
                    style: Theme.of(context).myTextButtonStyle,
                    onPressed: () {
                      currentTask.isDeleted
                          ? Fluttertoast.showToast(msg: "Restore task first")
                          : showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              enableDrag: false,
                              builder: (context) =>
                                  AddNewTaskModalSheetProvider(
                                taskToEdit: currentTask,
                              ),
                            );
                    },
                    child: Text("Edit"),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          );
        }
        return const Center(
          child: const CircularProgressIndicator(),
        );
      },
    );
  }
}
