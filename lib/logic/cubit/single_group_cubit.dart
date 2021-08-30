import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:meta/meta.dart';

part 'single_group_state.dart';

class SingleGroupTasksCubit extends Cubit<SingleGroupTasksState> {
  final String groupID;

  SingleGroupTasksCubit({
    required this.groupID,
  }) : super(SingleGroupTasksLoading()) {
    initialize();
  }

  final TasksDao _tasksDao = TasksDao();
  StreamSubscription? _taskStreamSubscription;
  // StreamSubscription? _groupStreamSubscription;
  List<Task> taskList = [];

  void initialize() {
    _taskStreamSubscription = _tasksDao
        .getSpecficGroupTasks(groupID: groupID)
        .listen((streamTaskList) {
      // temporary edit instead of below
      taskList = streamTaskList;

      // * BELOW CODE COPIED FROM [dashboard_cubit]
      // streamTaskList.forEach(
      //   (element) {
      //     if (!taskList.contains(element)) {
      //       taskList.add(element);
      //     }
      //   },
      // );

      // for (int i = 0; i < taskList.length; i++) {
      //   if (!streamTaskList.contains(taskList[i])) {
      //     taskList.remove(taskList[i]);
      //     i++;
      //   }
      // }

      // TasksDao.defaultTaskSorter(taskToSort: taskList);
      DateTime _dateTimeNow = DateTime.now();
      DateTime _dateTimeToday = DateTime(
        _dateTimeNow.year,
        _dateTimeNow.month,
        _dateTimeNow.day + 1,
        0,
        0,
      );

      taskList.sort((a, b) {
        // * complete-incomplete
        // * overdue
        // * time
        // ? taskPriority ?
        // ? isBy ?

        int cmpIsCompleted = "${a.isCompleted}".compareTo("${b.isCompleted}");
        if (cmpIsCompleted == 0) {
          DateTime dateTimeNow = DateTime.now();
          int cmpIsOverdue = "${b.time.isBefore(dateTimeNow)}"
              .compareTo("${a.time.isBefore(dateTimeNow)}");
          if (cmpIsOverdue == 0) {
            if (a.time.difference(b.time) >= Duration(days: 1)) {
              // if (b.time.isBefore(_dateTimeToday)) {
              int cmpTaskTime = a.time.compareTo(b.time);
              if (cmpTaskTime == 0) {
                int cmpTaskPriority =
                    b.taskPriority.index.compareTo(a.taskPriority.index);
                if (cmpTaskPriority == 0) {
                  return "${b.isBy}".compareTo("${a.isBy}");
                }
                return cmpTaskPriority;
              }
              return cmpTaskTime;
            } else {
              int cmpTaskPriority =
                  b.taskPriority.index.compareTo(a.taskPriority.index);
              if (cmpTaskPriority == 0) {
                int cmpIsBy = "${b.isBy}".compareTo("${a.isBy}");
                if (cmpIsBy == 0) {
                  return a.time.compareTo(b.time);
                }
                return cmpIsBy;
              }
              return cmpTaskPriority;
            }
          }

          return cmpIsOverdue;
        }
        return cmpIsCompleted;
      });

      emit(SingleGroupTasksLoaded());
    });
  }

  // * COPIED FROM [DashboardCubit]
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
    TasksDao.defaultTaskSorter(taskToSort: taskList);

    if (state is SingleGroupTasksLoading) {
      emit(SingleGroupTasksLoaded());
    } else if (state is SingleGroupTasksLoaded) {
      // emit(DashboardLoaded(forBannerOnly: true));
      emit(SingleGroupTasksLoaded());
    }
  }

  @override
  Future<void> close() {
    _taskStreamSubscription?.cancel();
    return super.close();
  }
}
