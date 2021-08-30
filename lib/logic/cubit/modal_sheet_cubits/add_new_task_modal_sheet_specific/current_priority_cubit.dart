import 'package:bloc/bloc.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:flutter/cupertino.dart';
// import 'package:meta/meta.dart';

part 'current_priority_state.dart';

class CurrentPriorityCubit extends Cubit<CurrentPriority> {
  CurrentPriorityCubit({
    TaskPriority? defaultTaskPriority,
  }) : super(CurrentPriority(
          taskPriority: defaultTaskPriority ?? TaskPriority.medium,
          isLocked: false,
        ));

  void changePriority({
    required TaskPriority taskPriority,
    bool isForced = false,
  }) {
    if (isForced) {
      emit(CurrentPriority(
        taskPriority: taskPriority,
        isLocked: true,
      ));
    } else if (!state.isLocked) {
      emit(CurrentPriority(
        taskPriority: taskPriority,
        isLocked: false,
      ));
    }
  }
}
