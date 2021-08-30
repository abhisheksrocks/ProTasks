import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/cubit/completed_tasks_cubit.dart';
import 'package:protasks/presentation/common_widgets/my_sliver_appbar.dart';
import 'package:protasks/presentation/common_widgets/task_representation/card_view/task_card_view.dart';
import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/task_details_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

class CompletedTasksProvider extends StatefulWidget {
  const CompletedTasksProvider({Key? key}) : super(key: key);

  @override
  _CompletedTasksProviderState createState() => _CompletedTasksProviderState();
}

class _CompletedTasksProviderState extends State<CompletedTasksProvider> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CompletedTasksCubit>(
          create: (context) => CompletedTasksCubit(),
        ),
      ],
      child: CompletedTasksScreen(),
    );
  }
}

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MySliverAppBar(
            title: 'Completed Tasks',
            actions: [
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Information"),
                        content: Text(
                            'To optimize storage, all completed tasks are automatically removed after 5 DAYS of inactivity.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
            leading: BackButton(),
          ),
          BlocBuilder<CompletedTasksCubit, CompletedTasksState>(
            builder: (context, state) {
              TasksDao _tasksDaoObject = TasksDao();
              if (state is CompletedTasksLoading) {
                return SliverToBoxAdapter(
                  child: const Center(
                    child: const CircularProgressIndicator(),
                  ),
                );
              }

              final completedTasksCubitObject =
                  context.read<CompletedTasksCubit>();

              List<Task> _taskList = completedTasksCubitObject.taskList;

              return SliverImplicitlyAnimatedList<Task>(
                // areItemsTheSame: (item1, item2) => false,
                key: ValueKey("Completed Tasks SliverImplicitlyAnimatedList"),
                areItemsTheSame: (item1, item2) => item1.id == item2.id,
                itemBuilder: (context, animation, currentTask, i) {
                  return SizeFadeTransition(
                    sizeFraction: 0.7,
                    animation: animation,
                    curve: Curves.easeInOut,
                    child: Dismissible(
                      key: ValueKey(
                          "CompletedTasks${currentTask.id}Dismissible"),
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
                              completedTasksCubitObject.refreshData,
                          opacityOnCompleted: false,
                        ),
                      ),
                    ),
                  );
                },
                items: _taskList,
              );
            },
          )
        ],
      ),
    );
  }
}
