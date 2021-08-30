import 'dart:math';

import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/cubit/root_cubits/side_drawer_cubit.dart';
import 'package:protasks/logic/cubit/single_group_cubit.dart';
import 'package:protasks/presentation/common_widgets/headers/task_list_labels.dart';
import 'package:protasks/presentation/common_widgets/my_sliver_appbar.dart';
import 'package:protasks/presentation/common_widgets/task_representation/card_view/task_card_view.dart';
import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/add_new_task_modal_sheet.dart';
import 'package:protasks/presentation/screens/side_drawer/side_drawer.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/task_details_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

class SingleGroupTasksScreenProvider extends StatefulWidget {
  const SingleGroupTasksScreenProvider({
    Key? key,
    required this.groupID,
  }) : super(key: key);

  final String groupID;

  @override
  _SingleGroupTasksScreenProviderState createState() =>
      _SingleGroupTasksScreenProviderState();
}

class _SingleGroupTasksScreenProviderState
    extends State<SingleGroupTasksScreenProvider> {
  @override
  void didChangeDependencies() {
    context.read<SideDrawerCubit>().changeSelectedID(widget.groupID);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SingleGroupTasksCubit(
            groupID: widget.groupID,
          ),
        ),
      ],
      child: SingleGroupTasksScreen(
        groupID: widget.groupID,
      ),
    );
  }
}

class SingleGroupTasksScreen extends StatelessWidget {
  const SingleGroupTasksScreen({
    Key? key,
    required this.groupID,
  }) : super(key: key);

  final String groupID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            enableDrag: false,
            builder: (context) => AddNewTaskModalSheetProvider(
              groupIdToSelectByDefault: groupID,
            ),
          );
        },
        child: Icon(Icons.add),
        mini: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                Builder(
                  builder: (context) => MySliverAppBar(
                    title:
                        '${context.watch<SideDrawerCubit>().groupsIdToName[groupID]}',
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 30,
                        ),
                        onPressed: () async {
                          final wantToEditGroup = await showMenu<bool>(
                            useRootNavigator: true,
                            context: context,
                            color: Theme.of(context).backgroundColor,
                            position: RelativeRect.fromRect(
                                Rect.fromCenter(
                                  center: Offset(500, 0),
                                  width: 0,
                                  height: 0,
                                ),
                                Rect.fromCircle(
                                  center: Offset(0, 0),
                                  radius: 0,
                                )),
                            items: [
                              PopupMenuItem(
                                textStyle: TextStyle(
                                  fontFamily: Strings.primaryFontFamily,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryTextColor,
                                ),
                                child: Text('Group Info'),
                                value: true,
                              ),
                            ],
                          );
                          if (wantToEditGroup == true) {
                            Navigator.of(context).pushNamed(
                              AppRouter.editGroup,
                              arguments: EditGroupArguments(groupId: groupID),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // * <HEADER> SECTION BEGINS HERE
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DateWithDay(
                            //   dateTime: DateTime.now(),
                            // ),
                            // Text(
                            //   'All Tasks',
                            //   style: TextStyle(
                            //     fontSize: 20,
                            //     fontWeight: FontWeight.w400,
                            //   ),
                            // ),
                            const SizedBox(
                              height: 3,
                            ),
                            Builder(
                              builder: (context) {
                                List<Task> _taskList = context
                                    .watch<SingleGroupTasksCubit>()
                                    .taskList;
                                return TaskListLabels(
                                  taskList: _taskList,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      // The reason for having [Divider] with height zero is because
                      // divider has a non-visible thickness which is hampering the
                      // look when the [Dismissible] action is done on the tasks that
                      // are in the <TASK LIST> section.

                      const Divider(
                        height: 0,
                      ),

                      // ! </HEADER> SECTION ENDS HERE
                    ],
                  ),
                ),
                BlocBuilder<SingleGroupTasksCubit, SingleGroupTasksState>(
                  builder: (context, state) {
                    TasksDao _tasksDaoObject = TasksDao();
                    if (state is SingleGroupTasksLoading) {
                      return SliverToBoxAdapter(
                        child: const Center(
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }

                    final singleGroupTasksCubit =
                        context.read<SingleGroupTasksCubit>();

                    List<Task> _taskList = singleGroupTasksCubit.taskList;

                    return SliverImplicitlyAnimatedList<Task>(
                      // spawnIsolate: true,
                      areItemsTheSame: (item1, item2) {
                        return item1.id == item2.id &&
                            item1.time == item2.time &&
                            item1.taskPriority == item2.taskPriority;
                        // return false;
                      },
                      // removeItemBuilder: (context, animation, currentTask) {
                      //   return SizeFadeTransition(
                      //     sizeFraction: 0.7,
                      //     animation: animation,
                      //     curve: Curves.easeInOut,
                      //     child: TaskCardView(
                      //       currentTask: currentTask,
                      //     ),
                      //   );
                      // },
                      itemBuilder: (context, animation, currentTask, i) {
                        // Task currentTask = _taskList.elementAt(i);
                        // Task currentTask = item;
                        return SizeFadeTransition(
                          sizeFraction: 0.7,
                          animation: animation,
                          curve: Curves.easeInOut,
                          child: Dismissible(
                            key: ValueKey(
                                "${currentTask.toString()}Dismissible"),
                            confirmDismiss: (direction) async {
                              await _tasksDaoObject.changeIsCompletedNew(
                                taskId: currentTask.id,
                              );
                              return false;
                            },
                            background: Container(
                              color: currentTask.isCompleted
                                  ? Colors.black
                                  : Colors.green,
                              child: Center(
                                child: currentTask.isCompleted
                                    // ? Icon(
                                    //     Icons
                                    //         .radio_button_unchecked_rounded,
                                    //     color: Colors.white)
                                    ? const MyCircularCheckBox(
                                        value: false,
                                        onChanged: null,
                                      )
                                    : const MyCircularCheckBox(
                                        value: true,
                                        onChanged: null,
                                      ),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                // showBottomSheet(
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return TaskDetailsModalSheetProvider(
                                      task: currentTask,
                                    );
                                    // return TextField();
                                  },
                                );
                              },
                              child: TaskCardView(
                                currentTask: currentTask,
                                dataRefreshingFunction:
                                    singleGroupTasksCubit.refreshData,
                                showGroupWidget: false,
                              ),
                            ),
                          ),
                        );
                      },
                      items: _taskList,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
