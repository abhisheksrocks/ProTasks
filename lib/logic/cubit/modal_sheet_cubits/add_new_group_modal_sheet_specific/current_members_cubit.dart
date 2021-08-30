import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/person.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';

part 'current_members_state.dart';

class CurrentMembersCubit extends Cubit<CurrentMembers> {
  CurrentMembersCubit()
      : super(CurrentMembers(
          members: [],
        ));

  void updateMembersWithList({required List<Person> membersList}) {
    emit(CurrentMembers(members: membersList));
  }

  void updateMembersWithUIDList({required List<String> membersUIDList}) async {
    List<Person> membersList =
        await UsersDao().getUsersFromUserIDList(userIDList: membersUIDList);
    emit(CurrentMembers(members: membersList));
  }

  void updateMember({required Person user}) {
    List<Person> userList = List.from(state.members);
    if (userList.contains(user)) {
      userList.remove(user);
    } else {
      userList.add(user);
    }
    emit(CurrentMembers(members: userList));
  }
}
