import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_group_cubit.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';

part 'assigness_search_state.dart';

class AssignessSearchCubit extends Cubit<AssignessSearchState> {
  final CurrentGroupCubit currentGroupCubit;
  StreamSubscription? _streamSubscription;
  AssignessSearchCubit({
    required this.currentGroupCubit,
  }) : super(AssignessSearchState(usersToShow: [])) {
    initialize();
  }

  List<Person> usersToSearchFrom = [];

  void performSteps(CurrentGroupState currentGroupCubitState) async {
    // print(
    //     "AssignessSearchCubit stream new currentGroupCubitState : $currentGroupCubitState");
    if (currentGroupCubitState is CurrentGroupLoaded) {
      usersToSearchFrom = await UsersDao().getUsersFromUserIDList(
        userIDList: currentGroupCubitState.currentGroup.members,
      );
      // print("usersToSearchFrom performSteps: $usersToSearchFrom");
      emit(AssignessSearchState(usersToShow: usersToSearchFrom));
    } else {
      // print("No Assignees to show");
      emit(AssignessSearchState(usersToShow: []));
    }
  }

  void initialize() async {
    _streamSubscription = currentGroupCubit.stream
        .asBroadcastStream()
        .listen((currentGroupCubitState) async {
      performSteps(currentGroupCubitState);
    });
    performSteps(currentGroupCubit.state);
  }

  void searchAssignees({required String searchQuery}) {
    searchQuery = searchQuery.trim();
    // print("usersToSearchFrom: $usersToSearchFrom");
    if (searchQuery.isEmpty) {
      emit(AssignessSearchState(usersToShow: usersToSearchFrom));
    } else {
      List<Person> usersToShow = [];
      RegExp _regExp = RegExp(
        "$searchQuery",
        caseSensitive: false,
      );
      usersToSearchFrom.forEach((user) {
        if (_regExp.hasMatch(user.name ?? '') ||
            _regExp.hasMatch(user.email ?? '')) {
          usersToShow.add(user);
        }
      });
      emit(AssignessSearchState(usersToShow: usersToShow));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
