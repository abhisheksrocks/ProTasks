import 'package:bloc/bloc.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'current_date_time_state.dart';

class CurrentDateTimeCubit extends Cubit<CurrentDateTime> {
  CurrentDateTimeCubit({
    DateTime? defaultDateTime,
  }) : super(
          CurrentDateTime(
            currentDateOnly: defaultDateTime ?? DateTime.now(),
            currentTimeOnly: TimeOfDay(
              hour: defaultDateTime?.hour ?? 23,
              minute: defaultDateTime?.minute ?? 59,
            ),
            isTimeForced: false,
            isDateForced: false,
          ),
        );

  void changeTime({
    required TimeOfDay? newTimeOfDay,
    required bool isForced,
  }) {
    if (newTimeOfDay != null) {
      // if (ExtraFunctions.isTaskTimePossible(
      //   timeOfDayToCheck: newTimeOfDay,
      //   dateOnlyToCheck: state.currentDateOnly,
      // )) {
      emit(CurrentDateTime(
        currentDateOnly: state.currentDateOnly,
        currentTimeOnly: newTimeOfDay,
        isTimeForced: isForced,
        isDateForced: state.isDateForced,
      ));
      //   return true;
      // }
      // return false;
    }
    // return true;
  }

  // * ONLY USED TO REFRESH DATA, USE CASE - TO REFRESH WHEN CURRENT TIME REACHES NEW TASK TIME
  // * AND NEW TASK IS NOT YET SAVED
  void refreshData() {
    emit(CurrentDateTime(
      currentTimeOnly: state.currentTimeOnly,
      currentDateOnly: state.currentDateOnly,
      isTimeForced: state.isTimeForced,
      isDateForced: state.isDateForced,
    ));
  }

  void changeDate({
    required DateTime? newDate,
    required bool isForced,
  }) {
    if (newDate != null) {
      emit(CurrentDateTime(
        currentTimeOnly: state.currentTimeOnly,
        currentDateOnly: newDate,
        isTimeForced: state.isTimeForced,
        isDateForced: isForced,
      ));
    }
  }
}
