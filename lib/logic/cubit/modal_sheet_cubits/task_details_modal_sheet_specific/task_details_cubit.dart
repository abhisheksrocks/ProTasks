import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:meta/meta.dart';

part 'task_details_state.dart';

class SingleTaskDetailsCubit extends Cubit<SingleTaskDetailsState> {
  Task task;
  StreamSubscription? _streamSubscription;
  TasksDao _tasksDao = TasksDao();
  SingleTaskDetailsCubit({
    required this.task,
  }) : super(SingleTaskDetailsLoaded(
          currentTask: task,
        )) {
    startFetching();
  }

  void startFetching() async {
    _streamSubscription = _tasksDao
        .getSingleTaskDetailsStream(taskId: task.id)
        .listen((currentTask) async {
      // if (state is SingleTaskDetailsLoading) {
      //   await Future.delayed(Duration(seconds: 1));
      // }
      if (currentTask == null) {
        _streamSubscription?.cancel();
      } else {
        if (task != currentTask) {
          task = currentTask;
          emit(SingleTaskDetailsLoaded(currentTask: currentTask));
        }
      }
    });
    emit(SingleTaskDetailsLoaded(currentTask: task));
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
