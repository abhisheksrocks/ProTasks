import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/data/models/recursion_interval.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_reminder_cubit.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:meta/meta.dart';

part 'current_repeat_state.dart';

class CurrentRepeatCubit extends Cubit<CurrentRepeatState> {
  final CurrentReminderCubit currentReminderCubit;

  CurrentRepeatCubit({
    required this.currentReminderCubit,
    RecursionInterval? defaultRecursionInterval,
    DateTime? defaultRecursionTill,
  }) : super(CurrentRepeatState(
          recursionInterval: defaultRecursionInterval ?? RecursionInterval.zero,
          recursionTill: defaultRecursionTill ?? DateTimeExtensions.invalid,
          remindTimer: currentReminderCubit.state.remindTimer,
          taskTime: currentReminderCubit.state.taskTime,
        )) {
    initialize();
  }

  StreamSubscription? _streamSubscription;

  void initialize() {
    _streamSubscription =
        currentReminderCubit.stream.listen((currentReminderState) {
      emit(CurrentRepeatState(
        remindTimer: currentReminderState.remindTimer,
        taskTime: currentReminderState.taskTime,
        recursionInterval: state.recursionInterval,
        recursionTill: state.recursionTill,
      ));
    });
  }

  void updateRepeatState({
    RecursionInterval? recursionInterval,
    DateTime? recursionTill,
  }) {
    emit(CurrentRepeatState(
      recursionInterval: recursionInterval ?? state.recursionInterval,
      recursionTill: recursionTill ?? state.recursionTill,
      remindTimer: state.remindTimer,
      taskTime: state.taskTime,
    ));
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
