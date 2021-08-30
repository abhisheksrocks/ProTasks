part of 'version_checker_cubit.dart';

@immutable
class VersionCheckerState {
  final bool needsUpdate;
  VersionCheckerState({
    required this.needsUpdate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VersionCheckerState && other.needsUpdate == needsUpdate;
  }

  @override
  int get hashCode => needsUpdate.hashCode;

  @override
  String toString() => 'VersionCheckerState(needsUpdate: $needsUpdate)';
}
