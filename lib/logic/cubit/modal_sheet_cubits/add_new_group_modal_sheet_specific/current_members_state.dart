part of 'current_members_cubit.dart';

@immutable
class CurrentMembers {
  final List<Person> members;
  CurrentMembers({
    required this.members,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CurrentMembers && listEquals(other.members, members);
  }

  @override
  int get hashCode => members.hashCode;
}
