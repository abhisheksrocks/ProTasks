part of 'current_group_cubit.dart';

@immutable
abstract class CurrentGroupState {}

class CurrentGroupLoading extends CurrentGroupState {}

class CurrentGroupLoaded extends CurrentGroupState {
  final Group currentGroup;
  final bool isLocked;
  CurrentGroupLoaded({
    required this.currentGroup,
    required this.isLocked,
  });
}

class CurrentGroupEmpty extends CurrentGroupState {}
