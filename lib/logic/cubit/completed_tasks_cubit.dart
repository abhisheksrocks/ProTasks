import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:meta/meta.dart';

part 'completed_tasks_state.dart';

class CompletedTasksCubit extends Cubit<CompletedTasksState> {
  CompletedTasksCubit() : super(CompletedTasksLoading()) {
    initialize();
  }

  List<Task> taskList = [];
  StreamSubscription? _streamSubscription;

  void initialize() async {
    // _streamSubscription = GroupsDao().findAllGroups().listen((listOfGroups) {
    //   print("Dashboard Cubit-> List of groups: $listOfGroups");
    //   List<String> groupIdList = listOfGroups.map((e) => e.id).toList();
    //   tasksStreamSubscription?.cancel();
    //   tasksStreamSubscription =
    //       _tasksDao.getTodayTasksOfGroupList(groupIdList).listen((listOfTasks) {
    //     print("Dashboard Cubit-> List of tasks: $listOfTasks");
    //     taskList = listOfTasks;
    //     TasksDao.defaultTaskSorter(taskToSort: taskList);
    //     emit(DashboardLoaded());
    //   });
    // });
    _streamSubscription?.cancel();
    _streamSubscription = TasksDao().getCompletedTasks().listen((listOfTasks) {
      taskList = listOfTasks;
      listOfTasks.sort((a, b) => a.modifiedOn.compareTo(b.modifiedOn));
      emit(CompletedTasksLoaded());
    });
  }

  void refreshData(
      //   {
      //   bool forBannersOnly = true,
      // }
      ) {
    // * USE THIS JUST TO REFRESH THE DATA
    // * USED BY FUTUREBUILT TASK TIME IN TASK REPRESENTATIONS
    // * (Used to notify new overdues)

    // ? Can't we move this sort just inside DashboardLoaded ?
    // ? Will it be required for DashboardLoading ?
    // taskListSort();
    // TasksDao.defaultTaskSorter(taskToSort: taskList);
    taskList.sort((a, b) => a.modifiedOn.compareTo(b.modifiedOn));

    if (state is CompletedTasksLoading) {
      emit(CompletedTasksLoading());
    } else if (state is CompletedTasksLoaded) {
      // emit(DashboardLoaded(forBannerOnly: true));
      emit(CompletedTasksLoaded());
    }
  }

  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
