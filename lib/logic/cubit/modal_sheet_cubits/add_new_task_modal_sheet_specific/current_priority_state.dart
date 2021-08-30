part of 'current_priority_cubit.dart';

@immutable
class CurrentPriority {
  final TaskPriority taskPriority;
  final bool isLocked;
  CurrentPriority({
    required this.taskPriority,
    required this.isLocked,
  });
}
