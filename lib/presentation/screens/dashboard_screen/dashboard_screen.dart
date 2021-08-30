import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/cubit/dashboard_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/side_drawer_cubit.dart';
import 'package:protasks/presentation/common_widgets/headers/date_with_day.dart';
import 'package:protasks/presentation/common_widgets/my_sliver_appbar.dart';
import 'package:protasks/presentation/common_widgets/headers/task_list_labels.dart';
import 'package:protasks/presentation/common_widgets/task_representation/card_view/task_card_view.dart';
import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:protasks/presentation/screens/add_new_task_modal_sheet/add_new_task_modal_sheet.dart';
import 'package:protasks/presentation/screens/dashboard_screen/widgets/bottom_sync_status.dart';
import 'package:protasks/presentation/screens/side_drawer/side_drawer.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/task_details_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

class DashboardScreenProvider extends StatefulWidget {
  @override
  _DashboardScreenProviderState createState() =>
      _DashboardScreenProviderState();
}

class _DashboardScreenProviderState extends State<DashboardScreenProvider> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    String dashboardScreenId = SideDrawerCubit.dashboardScreenId;
    context.read<SideDrawerCubit>().changeSelectedID('$dashboardScreenId');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(
          create: (context) => DashboardCubit(),
        ),
        // BlocProvider(
        //   create: (context) => SubjectBloc(),
        // ),
      ],
      child: DashboardScreenEntry(),
    );
  }
}

class DashboardScreenEntry extends StatelessWidget {
  // Stream<Widget> childBuilder(Widget initial) async* {
  //   yield initial;
  //   Future.delayed(Duration(seconds: 2));
  //   yield SizedBox();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            enableDrag: false,
            builder: (context) => AddNewTaskModalSheetProvider(),
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
                MySliverAppBar(title: 'Dashboard'),
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
                            DateWithDay(
                              dateTime: DateTime.now(),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Builder(
                              builder: (context) {
                                List<Task> _taskList =
                                    context.watch<DashboardCubit>().taskList;
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
                      const Divider(
                        height: 0,
                      ),

                      // ! </HEADER> SECTION ENDS HERE
                    ],
                  ),
                ),
                // * <TASK LIST> BEGINS HERE
                BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, state) {
                    TasksDao _tasksDaoObject = TasksDao();
                    if (state is DashboardLoading) {
                      return SliverToBoxAdapter(
                        child: const Center(
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }

                    final dashboardCubitObject = context.read<DashboardCubit>();

                    List<Task> _taskList = dashboardCubitObject.taskList;

                    return SliverImplicitlyAnimatedList<Task>(
                      areItemsTheSame: (item1, item2) {
                        // return item1.id == item2.id;
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
                                  },
                                );
                              },
                              child: TaskCardView(
                                currentTask: currentTask,
                                dataRefreshingFunction:
                                    dashboardCubitObject.refreshData,
                              ),
                            ),
                          ),
                        );
                      },
                      items: _taskList,
                    );
                  },
                ),
                // ! </TASK LIST> SECTION ENDS HERE
              ],
            ),
          ),
          BottomSyncStatus(),
        ],
      ),
    );
  }
}
