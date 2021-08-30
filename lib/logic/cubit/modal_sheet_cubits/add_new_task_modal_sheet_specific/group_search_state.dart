part of 'group_search_cubit.dart';

@immutable
class GroupSearch {
  final List<Group> groupToShow;
  GroupSearch({
    required this.groupToShow,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupSearch && listEquals(other.groupToShow, groupToShow);
  }

  @override
  int get hashCode => groupToShow.hashCode;
}
