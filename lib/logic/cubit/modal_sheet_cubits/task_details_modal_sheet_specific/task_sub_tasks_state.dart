part of 'task_sub_tasks_cubit.dart';

@immutable
abstract class TaskSubTasksState {}

class TaskSubTasksLoading extends TaskSubTasksState {}

class TaskSubTasksLoaded extends TaskSubTasksState {
  final List<Task> subtaskList;

  TaskSubTasksLoaded({required this.subtaskList});
}
