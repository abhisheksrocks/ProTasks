

part of 'current_assignees_cubit.dart';

@immutable
abstract class CurrentAssigneesState {}

class CurrentAssigneesLoading extends CurrentAssigneesState {}

class CurrentAssigneesLoaded extends CurrentAssigneesState {
  final String currentGroupID;
  final List<String> currentAssigness;
  CurrentAssigneesLoaded({
    required this.currentGroupID,
    required this.currentAssigness,
  });

  @override
  String toString() =>
      'CurrentAssigneesLoaded(currentGroupID: $currentGroupID, currentAssigness: $currentAssigness)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CurrentAssigneesLoaded &&
      other.currentGroupID == currentGroupID &&
      listEquals(other.currentAssigness, currentAssigness);
  }

  @override
  int get hashCode => currentGroupID.hashCode ^ currentAssigness.hashCode;
}
