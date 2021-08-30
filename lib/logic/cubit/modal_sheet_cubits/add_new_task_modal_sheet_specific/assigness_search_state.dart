part of 'assigness_search_cubit.dart';

@immutable
class AssignessSearchState {
  final List<Person> usersToShow;
  AssignessSearchState({
    required this.usersToShow,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AssignessSearchState &&
        listEquals(other.usersToShow, usersToShow);
  }

  @override
  int get hashCode => usersToShow.hashCode;
}
