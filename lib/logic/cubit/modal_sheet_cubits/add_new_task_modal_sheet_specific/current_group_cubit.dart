import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/data/models/group.dart';
import 'package:meta/meta.dart';

part 'current_group_state.dart';

class CurrentGroupCubit extends Cubit<CurrentGroupState> {
  CurrentGroupCubit({
    required this.groupIDtoSelectByDefault,
    required this.isGroupChangeAllowed,
  }) : super(CurrentGroupLoading()) {
    initialize();
  }

  final String? groupIDtoSelectByDefault;
  final bool isGroupChangeAllowed;

  StreamSubscription? _streamSubscription;
  List<Group> groupList = [];
  final GroupsDao _groupsDao = GroupsDao();

  // TODO: Implement a sorting logic, for group and sub-group together

  void initialize() {
    _streamSubscription = _groupsDao
        .findAllGroups()
        .asBroadcastStream()
        .listen((groupListStream) {
      groupList = groupListStream;
      if (groupList.isNotEmpty) {
        if (state is CurrentGroupLoading) {
          if (groupIDtoSelectByDefault != null) {
            emit(CurrentGroupLoaded(
              currentGroup: groupList.firstWhere(
                  (element) => element.id == groupIDtoSelectByDefault),
              isLocked: false,
            ));
          } else {
            // TODO: Make it so that it never gets a sub-group as the first element
            emit(CurrentGroupLoaded(
              currentGroup: groupList.elementAt(0),
              isLocked: false,
            ));
          }
        }
        if (state is CurrentGroupLoaded) {
          CurrentGroupLoaded _currentState = state as CurrentGroupLoaded;
          if (!groupListStream.contains(_currentState.currentGroup)) {
            // if (groupListStream.contains(_currentState.currentGroup)) {
            //   emit(CurrentGroupLoaded(
            //     currentGroup: _currentState.currentGroup,
            //     isLocked: _currentState.isLocked,
            //   ));
            // } else {
            emit(CurrentGroupLoaded(
              currentGroup: groupListStream.elementAt(0),
              isLocked: false,
            ));
          }
        }
      } else {
        // This state can occur for an existing user, if he didn't save his previous data
        // and logged in to a new device
        emit(CurrentGroupEmpty());
      }
    });
  }

  // void searchThroughList(String query) {
  //   if (query.isNotEmpty) {
  //     RegExp _regexp = RegExp(
  //       "$query",
  //       caseSensitive: false,
  //     );
  //     List<
  //   }
  // }

  void changeCurrentGroup({
    required Group newGroup,
    bool isForced = false,
  }) {
    emit(CurrentGroupLoaded(
      currentGroup: newGroup,
      isLocked: isForced,
    ));
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
