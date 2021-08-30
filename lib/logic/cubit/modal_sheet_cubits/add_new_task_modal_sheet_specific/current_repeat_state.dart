part of 'current_repeat_cubit.dart';

@immutable
class CurrentRepeatState {
  final RecursionInterval recursionInterval;
  final DateTime recursionTill;
  final DateTime taskTime;
  final Duration remindTimer;
  final bool isAcceptable;
  CurrentRepeatState({
    required this.recursionInterval,
    required this.recursionTill,
    required this.remindTimer,
    required this.taskTime,
  }) : isAcceptable = ExtraFunctions.isTaskRepeatIntervalPossible(
          recursionInterval: recursionInterval,
          remindTimer: remindTimer,
          taskTime: taskTime,
        ) {
    // print("for recursionInterval: $recursionInterval");
    // print("for taskTime: $taskTime");
    // print("for remindTimer: $remindTimer");
    // print(
    //     "isTaskRepeatIntervalPossible: ${ExtraFunctions.isTaskRepeatIntervalPossible(
    //   recursionInterval: recursionInterval,
    //   remindTimer: remindTimer,
    //   taskTime: taskTime,
    // )}");
    // print("isAccepatable: $isAcceptable");
  }

  // @override
  // String toString() {
  //   return 'CurrentRepeatState(recursionInterval: $recursionInterval, recursionTill: $recursionTill, taskTime: $taskTime, remindTimer: $remindTimer, isAcceptable: $isAcceptable)';
  // }
}
