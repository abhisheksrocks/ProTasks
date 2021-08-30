import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/cubit/deleted_tasks_cubit.dart';
import 'package:protasks/presentation/common_widgets/my_sliver_appbar.dart';
import 'package:protasks/presentation/common_widgets/task_representation/card_view/task_card_view.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/task_details_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

class DeletedTasksProvider extends StatefulWidget {
  const DeletedTasksProvider({Key? key}) : super(key: key);

  @override
  _DeletedTasksProviderState createState() => _DeletedTasksProviderState();
}

class _DeletedTasksProviderState extends State<DeletedTasksProvider> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeletedTasksCubit>(
      create: (context) => DeletedTasksCubit(),
      child: DeletedTasksScreen(),
    );
  }
}

class DeletedTasksScreen extends StatelessWidget {
  const DeletedTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MySliverAppBar(
            title: 'Recycle Bin',
            actions: [],
            leading: BackButton(),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).primaryTextColor.withOpacity(0.1),
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "INFORMATION",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: Strings.primaryFontFamily,
                    ),
                  ),
                  Text(
                    "To optimize storage, deleted tasks are automatically removed after 1 day, unless restored.",
                    style: TextStyle(
                      fontFamily: Strings.secondaryFontFamily,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<DeletedTasksCubit, DeletedTasksState>(
            builder: (context, state) {
              if (state is DeletedTasksLoading) {
                return SliverToBoxAdapter(
                  child: const Center(
                    child: const CircularProgressIndicator(),
                  ),
                );
              }

              final deletedTasksCubitObject = context.read<DeletedTasksCubit>();

              List<Task> _taskList = deletedTasksCubitObject.taskList;

              return SliverImplicitlyAnimatedList<Task>(
                areItemsTheSame: (item1, item2) => item1.id == item2.id,
                itemBuilder: (context, animation, currentTask, i) {
                  return SizeFadeTransition(
                    sizeFraction: 0.7,
                    animation: animation,
                    curve: Curves.easeInOut,
                    child: InkWell(
                      onTap: () {
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
                      child: AbsorbPointer(
                        absorbing: currentTask.isDeleted,
                        child: TaskCardView(
                          currentTask: currentTask,
                          dataRefreshingFunction:
                              deletedTasksCubitObject.refreshData,
                          opacityOnCompleted: false,
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
    );
  }
}
