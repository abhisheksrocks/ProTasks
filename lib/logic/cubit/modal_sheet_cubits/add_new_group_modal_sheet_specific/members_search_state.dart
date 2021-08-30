part of 'members_search_cubit.dart';

@immutable
class MembersSearch {
  final List<Person> usersToShow;
  final bool forceNewState;
  MembersSearch({
    required this.usersToShow,
    this.forceNewState = false,
  });

  @override
  String toString() =>
      'MembersSearch(usersToShow: $usersToShow, forceNewState: $forceNewState)';

  // * THIS SOLVES MULTIPLE STATE EMIT
  // ** solved it
  // ! BUT WE ARE SUPPOSED TO SHOW EXACT SAME STATE WHEN THE USER LIST(TO SEARCH FROM) UPDATES
  // ! SO FIGURE OUT SOMETHING FOR THAT, ONE WAY COULD BE TO STORE THE WHOLE SEARCH ALSO IN STATE
  // ** solved it
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MembersSearch &&
        listEquals(other.usersToShow, usersToShow) &&
        other.forceNewState == forceNewState;
  }

  @override
  int get hashCode => usersToShow.hashCode ^ forceNewState.hashCode;
}
