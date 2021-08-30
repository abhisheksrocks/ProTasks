part of 'deleted_tasks_cubit.dart';

@immutable
abstract class DeletedTasksState {}

class DeletedTasksLoading extends DeletedTasksState {}

class DeletedTasksLoaded extends DeletedTasksState {}
