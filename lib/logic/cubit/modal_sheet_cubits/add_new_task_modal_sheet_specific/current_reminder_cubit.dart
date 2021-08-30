import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_date_time_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'current_reminder_state.dart';

class CurrentReminderCubit extends Cubit<CurrentReminderState> {
  final CurrentDateTimeCubit currentDateTimeCubit;

  CurrentReminderCubit({
    required this.currentDateTimeCubit,
    Duration? defaultReminder,
  }) : super(CurrentReminderState(
          remindTimer: defaultReminder ?? Duration.zero,
          currentReminderOption: CurrentReminderOption.mins,
          taskTime: currentDateTimeCubit.state.finalTaskTime,
        )) {
    initialize();
  }

  StreamSubscription? _streamSubscription;

  void initialize() {
    _streamSubscription = currentDateTimeCubit.stream.listen((event) {
      // if (!event.isAcceptable) {
      print("Update due to DateTime");
      emit(CurrentReminderState(
        currentReminderOption: state.currentReminderOption,
        remindTimer: state.remindTimer,
        taskTime: event.finalTaskTime,
      ));
      // }
    });
  }

  void refreshState() {
    emit(CurrentReminderState(
      currentReminderOption: state.currentReminderOption,
      remindTimer: state.remindTimer,
      taskTime: state.taskTime,
    ));
  }

  void changeReminder({
    required String textFieldValue,
    required CurrentReminderOption currentReminderOption,
  }) {
    if (textFieldValue.isEmpty) {
      textFieldValue = '0';
    }
    int? integerValue = int.tryParse(textFieldValue);
    if (integerValue != null) {
      Duration newDurationValue;
      switch (currentReminderOption) {
        case CurrentReminderOption.mins:
          newDurationValue = Duration(minutes: integerValue);
          break;
        case CurrentReminderOption.hrs:
          newDurationValue = Duration(hours: integerValue);
          break;
        case CurrentReminderOption.days:
          newDurationValue = Duration(days: integerValue);
          break;
        case CurrentReminderOption.weeks:
          newDurationValue = Duration(days: integerValue * 7);
          break;
        default:
          return;
      }

      final newState = CurrentReminderState(
        remindTimer: newDurationValue,
        currentReminderOption: currentReminderOption,
        taskTime: state.taskTime,
      );

      if (state != newState) {
        emit(newState);
      }
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
