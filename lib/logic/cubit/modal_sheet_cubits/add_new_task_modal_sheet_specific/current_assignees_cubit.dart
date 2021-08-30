import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_group_cubit.dart';
import 'package:meta/meta.dart';

import 'package:flutter/foundation.dart';

part 'current_assignees_state.dart';

class CurrentAssigneesCubit extends Cubit<CurrentAssigneesState> {
  final CurrentGroupCubit currentGroupCubit;
  StreamSubscription? _streamSubscription;
  List<String>? defaultAssignees;
  CurrentAssigneesCubit({
    required this.currentGroupCubit,
    this.defaultAssignees,
  }) : super(CurrentAssigneesLoading()) {
    initialize();
  }

  void performSteps(CurrentGroupState currentGroupState) {
    if (currentGroupState is CurrentGroupLoaded) {
      // if (state is CurrentAssigneesLoaded) {
      //   final currentAssigneesLoadedState = state as CurrentAssigneesLoaded;
      //   if (currentAssigneesLoadedState.currentGroupID !=
      //       currentGroupState.currentGroup.id) {
      //     emit(CurrentAssigneesLoaded(
      //       currentGroupID: currentGroupState.currentGroup.id,
      //       currentAssigness: [],
      //     ));
      //   }
      // } else {
      //   emit(CurrentAssigneesLoaded(
      //     currentGroupID: currentGroupState.currentGroup.id,
      //     currentAssigness: [],
      //   ));
      // }

      if (!(state is CurrentAssigneesLoaded &&
          (state as CurrentAssigneesLoaded).currentGroupID ==
              currentGroupState.currentGroup.id)) {
        emit(CurrentAssigneesLoaded(
          currentGroupID: currentGroupState.currentGroup.id,
          currentAssigness: defaultAssignees ?? [],
        ));
        if (defaultAssignees != null) {
          defaultAssignees = null;
        }
      }
    } else {
      emit(CurrentAssigneesLoading());
    }
  }

  void initialize() {
    _streamSubscription = currentGroupCubit.stream.listen((currentGroupState) {
      performSteps(currentGroupState);
    });
    performSteps(currentGroupCubit.state);
  }

  void updateAssginees(String userID) {
    if (state is CurrentAssigneesLoaded) {
      final currentAssigneesLoaded = state as CurrentAssigneesLoaded;
      List<String> _newCurrentAssigness =
          List.from(currentAssigneesLoaded.currentAssigness);
      if (_newCurrentAssigness.contains(userID)) {
        _newCurrentAssigness.remove(userID);
      } else {
        _newCurrentAssigness.add(userID);
      }
      // print(
      //     "currentAssigneesLoaded.currentAssigness: ${currentAssigneesLoaded.currentAssigness}");
      // print("_newCurrentAssigness: $_newCurrentAssigness");
      // print(
      //     "List are equal ${listEquals(_newCurrentAssigness, currentAssigneesLoaded.currentAssigness)}");
      emit(CurrentAssigneesLoaded(
        currentGroupID: currentAssigneesLoaded.currentGroupID,
        currentAssigness: _newCurrentAssigness,
      ));
    }
  }

  void updateAssigneesWithUserIDList(List<String> userIDList) {
    print("listOfNewAssignees: $userIDList");
    if (state is CurrentAssigneesLoaded) {
      final currentAssigneesLoaded = state as CurrentAssigneesLoaded;
      emit(CurrentAssigneesLoaded(
        currentGroupID: currentAssigneesLoaded.currentGroupID,
        currentAssigness: userIDList,
      ));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
