part of 'completed_tasks_cubit.dart';

@immutable
abstract class CompletedTasksState {}

class CompletedTasksLoading extends CompletedTasksState {}

class CompletedTasksLoaded extends CompletedTasksState {}
