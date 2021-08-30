import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'side_drawer_state.dart';

class SideDrawerCubit extends Cubit<SideDrawerState> {
  static const String dashboardScreenId = 'dashboardScreenId';
  static const String settingsScreenId = 'settingsScreenId';
  static const String completedTasksScreenId = 'completedTasksScreenId';
  static const String deletedTasksScreenId = 'deletedTasksScreenId';

  final LoginCubit loginCubit;

  StreamSubscription? loginCubitSubscription;

  SideDrawerCubit({
    required this.loginCubit,
  }) : super(SideDrawerState(
          showGroups: false,
          selectID: '$dashboardScreenId',
        )) {
    initialize();
  }

  void performActionBasedOnLogin(LoginState currentState) {
    switch (currentState.currentLoginState) {
      case CurrentLoginState.loggedOut:
        _streamSubscription?.cancel();
        groupsIdToName.clear();
        break;
      case CurrentLoginState.loggedIn:
        reinitialize();
        break;
      case CurrentLoginState.choseNotToLogIn:
        reinitialize();
        break;
    }
  }

  void initialize() {
    loginCubitSubscription = loginCubit.stream.listen((currentState) {
      performActionBasedOnLogin(currentState);
    });
    performActionBasedOnLogin(loginCubit.state);
  }

  final GroupsDao _groupsDao = GroupsDao();
  StreamSubscription? _streamSubscription;
  Map<String, String> groupsIdToName = {};

  // can be called after user logs out/ then another user logs in(or chose not to log in)
  void reinitialize() async {
    _streamSubscription?.cancel();
    getAllGroups();
    groupsIdToName.clear();
  }

  void getAllGroups() {
    _streamSubscription = _groupsDao.findAllGroups().listen((streamGroupList) {
      streamGroupList.forEach((group) {
        groupsIdToName[group.id] = group.name;
      });
      if (streamGroupList.isNotEmpty) {
        emit(SideDrawerState(
          showGroups: state.showGroups,
          selectID: state.selectID,
        ));
      }
    });
  }

  void changeSelectedID(String newId) {
    emit(SideDrawerState(
      showGroups: state.showGroups,
      selectID: newId,
    ));
  }

  void changeGroupView() {
    emit(SideDrawerState(
      showGroups: !state.showGroups,
      selectID: state.selectID,
    ));
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    loginCubitSubscription?.cancel();
    return super.close();
  }
}
