part of 'task_details_cubit.dart';

@immutable
abstract class SingleTaskDetailsState {}

class SingleTaskDetailsLoading extends SingleTaskDetailsState {}

class SingleTaskDetailsLoaded extends SingleTaskDetailsState {
  final Task currentTask;
  SingleTaskDetailsLoaded({
    required this.currentTask,
  });
}
