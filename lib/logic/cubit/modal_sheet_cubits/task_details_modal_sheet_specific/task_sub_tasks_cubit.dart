import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:meta/meta.dart';

part 'task_sub_tasks_state.dart';

class TaskSubTasksCubit extends Cubit<TaskSubTasksState> {
  final String taskID;

  StreamSubscription? _streamSubscription;

  TaskSubTasksCubit({required this.taskID}) : super(TaskSubTasksLoading()) {
    startFetching();
  }

  void startFetching() async {
    _streamSubscription = TasksDao().findSubtask(taskID).listen((listOfTasks) {
      // TasksDao.defaultTaskSorter(taskToSort: listOfTasks);
      print("Subtasks loaded");
      emit(TaskSubTasksLoaded(subtaskList: listOfTasks));
    });
  }

  void refreshData() {
    if (state is TaskSubTasksLoaded) {
      List<Task> _subtaskList = (state as TaskSubTasksLoaded).subtaskList;
      TasksDao.defaultTaskSorter(taskToSort: _subtaskList);
      emit(TaskSubTasksLoaded(subtaskList: _subtaskList));
    }
    if (state is TaskSubTasksLoading) {
      emit(TaskSubTasksLoading());
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
