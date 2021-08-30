import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:meta/meta.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  StreamSubscription? _streamSubscription;
  List<Task> taskList = [];
  TasksDao _tasksDao = TasksDao();
  DashboardCubit() : super(DashboardLoading()) {
    startFetching();
  }

  // *** using defaultSort() function from TasksDao instead ****
  // void taskListSort() {
  //   taskList.sort((a, b) {
  //     // * complete-incomplete
  //     // * overdue
  //     // ? taskPriority ?
  //     // ? isBy ?
  //     // * time

  //     int cmpIsCompleted = "${a.isCompleted}".compareTo("${b.isCompleted}");
  //     if (cmpIsCompleted == 0) {
  //       DateTime dateTimeNow = DateTime.now();
  //       int cmpIsOverdue = "${b.time.isBefore(dateTimeNow)}"
  //           .compareTo("${a.time.isBefore(dateTimeNow)}");
  //       if (cmpIsOverdue == 0) {
  //         int cmpTaskPriority =
  //             b.taskPriority.index.compareTo(a.taskPriority.index);
  //         if (cmpTaskPriority == 0) {
  //           int cmpIsBy = "${b.isBy}".compareTo("${a.isBy}");
  //           if (cmpIsBy == 0) {
  //             return a.time.compareTo(b.time);
  //           }
  //           return cmpIsBy;
  //         }
  //         return cmpTaskPriority;
  //       }
  //       return cmpIsOverdue;
  //     }
  //     return cmpIsCompleted;
  //   });
  // }

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

    if (state is DashboardLoading) {
      emit(DashboardLoading());
    } else if (state is DashboardLoaded) {
      // emit(DashboardLoaded(forBannerOnly: true));
      emit(DashboardLoaded());
    }
  }

  void startFetching() async {
    // StreamSubscription? tasksStreamSubscription;
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
    _streamSubscription = _tasksDao.getDashboardTasks().listen(
      (listOfTasks) async {
        // print("listOfTasks.length : ${listOfTasks.length}");
        // listOfTasks.forEach((element) {
        //   print("Assigned To: ${element.assignedTo}");
        // });

        // TEMPORARY ADDITION
        taskList = listOfTasks;

        // listOfTasks.forEach(
        //   (element) {
        //     if (!taskList.contains(element)) {
        //       taskList.add(element);
        //     }
        //   },
        // );

        // ! DON'T USE forEach HERE BECAUSE WHEN WE REMOVE ELEMENT FROM taskList
        // ! THE taskList.length IS MODIFIED AND forEach ISN'T WRITTEN LIKE THAT
        // for (int i = 0; i < taskList.length; i++) {
        //   if (!listOfTasks.contains(taskList[i])) {
        //     taskList.remove(taskList[i]);
        //     i++;
        //   }
        // }

        // taskListSort();
        TasksDao.defaultTaskSorter(taskToSort: taskList);

        // * For testing only
        // await Future.delayed(Duration(seconds: 5));

        emit(DashboardLoaded());
      },
    );
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
