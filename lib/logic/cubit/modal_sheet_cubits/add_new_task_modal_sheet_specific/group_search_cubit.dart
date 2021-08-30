import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/data/models/group.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';

part 'group_search_state.dart';

class GroupSearchCubit extends Cubit<GroupSearch> {
  // TODO: Make a logic for searching such that if a child group is searched, the parent group is also shown in return
  GroupSearchCubit() : super(GroupSearch(groupToShow: [])) {
    initialize();
  }

  StreamSubscription? _streamSubscription;
  final GroupsDao _groupsDao = GroupsDao();
  List<Group> groupListToSearchFrom = [];

  // TODO: Either sort groupList here, or get a sorted list from [_groupsDao.findAllGroups()] directly.
  void initialize() {
    _streamSubscription =
        _groupsDao.findAllGroups().asBroadcastStream().listen((groupList) {
      groupListToSearchFrom = groupList;
      emit(GroupSearch(groupToShow: groupListToSearchFrom));
    });
  }

  void reinitialize({
    bool onlyParentsGroups = false,
  }) {
    _streamSubscription?.cancel();
    _streamSubscription = _groupsDao
        .findAllGroups(onlyParentGroups: onlyParentsGroups)
        .asBroadcastStream()
        .listen((groupList) {
      groupListToSearchFrom = groupList;
      emit(GroupSearch(groupToShow: groupListToSearchFrom));
    });
  }

  void searchGroup({required String searchQuery}) {
    searchQuery = searchQuery.trim();
    if (searchQuery.isNotEmpty) {
      List<Group> groupToShow = [];
      RegExp _regExp = RegExp(
        "$searchQuery",
        caseSensitive: false,
      );
      groupListToSearchFrom.forEach((group) {
        if (_regExp.hasMatch(group.name)) {
          groupToShow.add(group);
        }
      });
      emit(GroupSearch(groupToShow: groupToShow));
    } else {
      // if (state.groupToShow.length != groupListToSearchFrom.length) {
      emit(GroupSearch(groupToShow: groupListToSearchFrom));
      // }
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
