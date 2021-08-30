import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:meta/meta.dart';

part 'deleted_tasks_state.dart';

class DeletedTasksCubit extends Cubit<DeletedTasksState> {
  DeletedTasksCubit() : super(DeletedTasksLoading()) {
    initialize();
  }

  List<Task> taskList = [];

  StreamSubscription? _streamSubscription;

  void initialize() {
    _streamSubscription?.cancel();
    _streamSubscription = TasksDao().getDeletedTasks().listen((listOfTasks) {
      taskList = listOfTasks;
      listOfTasks.sort((a, b) => a.modifiedOn.compareTo(b.modifiedOn));
      emit(DeletedTasksLoaded());
    });
  }

  void refreshData() {
    taskList.sort((a, b) => a.modifiedOn.compareTo(b.modifiedOn));

    if (state is DeletedTasksLoading) {
      emit(DeletedTasksLoading());
    } else if (state is DeletedTasksLoaded) {
      // emit(DashboardLoaded(forBannerOnly: true));
      emit(DeletedTasksLoaded());
    }
  }

  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
