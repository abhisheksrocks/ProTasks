import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/data/models/group.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'edit_group_state.dart';

class EditGroupCubit extends Cubit<EditGroupState> {
  final String groupId;
  EditGroupCubit({
    required this.groupId,
  }) : super(EditGroupLoading()) {
    startFetching();
  }

  StreamSubscription? _groupStreamSubscription;

  void startFetching() async {
    _groupStreamSubscription =
        GroupsDao().findGroupById(groupID: groupId).listen((group) {
      // if(toSubmit.members.contains(FirebaseAuthFunctions.getCurrentUser?.uid ?? Strings.defaultUserUID)){
      //   toSubmit.members.
      // }
      if (group == null) {
        throw Exception();
      }
      String yourUID =
          FirebaseAuthFunctions.getCurrentUser?.uid ?? Strings.defaultUserUID;
      int index = group.members.indexOf(yourUID);
      if (index != -1) {
        group.members.removeAt(index);
        group.members.insert(0, yourUID);
      }
      print("Emitting new state for EditGroupCubit with EditGroupLoaded");
      print("With Group: $group");
      Group updateGroup = Group.fromMapFromDatabase(group.toMapForDatabase());
      // Group updateGroup = group.copyWith();
      emit(EditGroupLoaded(
        groupToEdit: group,
        updatedGroup: updateGroup,
      ));
    });
  }

  void updateGroupInfo(
      {String? newName, List<String>? newMembers, List<String>? newAdmins}) {
    if (state is EditGroupLoaded) {
      var currentState = state as EditGroupLoaded;
      Group newGroup = Group.fromMapFromDatabase(
          currentState.updatedGroup.toMapForDatabase());
      if (newName != null) {
        if (newGroup.name != newName) {
          print("Updating name");
          newGroup.name = newName;
        } else {
          return;
        }
      }

      if (newAdmins != null) {
        if (newGroup.admins != newAdmins) {
          print("Updating admins");
          newGroup.admins = newAdmins;
        } else {
          return;
        }
      }
      if (newMembers != null) {
        if (newGroup.members != newMembers) {
          print("Updating members");
          newGroup.members = newMembers;
          // for (final admin in newGroup.admins) {
          //   if (!newGroup.members.contains(admin)) {
          //     newGroup.admins.removeWhere((element) => element == admin);
          //   }
          // }
          for (int i = 0; i < newGroup.admins.length; i++) {
            // int index = newGroup.members.indexOf(newGroup.admins.elementAt(i));
            // if(index)
            String currentAdminUid = newGroup.admins.elementAt(i);
            if (!newGroup.members.contains(currentAdminUid)) {
              newGroup.admins.removeAt(i);
            }
          }
          // newGroup.admins.forEach((element) {
          //   int index = newMembers.indexOf(element);
          //   if (index == -1) {
          //     newGroup.admins.removeWhere((admin) => admin == element);
          //   }
          //   // if(!newGroup.admins.contains(element)){
          //   //   newGroup.admins.re
          //   // }
          // });
        } else {
          return;
        }
      }
      // print("Emitting new updatedGroup: $newGroup");
      emit(EditGroupLoaded(
        groupToEdit: currentState.groupToEdit,
        updatedGroup: newGroup,
      ));
    }
  }

  @override
  Future<void> close() async {
    _groupStreamSubscription?.cancel();

    super.close();
  }
}
