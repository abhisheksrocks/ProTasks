part of 'current_reminder_cubit.dart';

@immutable
class CurrentReminderState {
  final Duration remindTimer;
  final CurrentReminderOption currentReminderOption;
  final DateTime taskTime;
  final bool isAcceptable;
  CurrentReminderState({
    required this.remindTimer,
    required this.currentReminderOption,
    required this.taskTime,
  }) : isAcceptable = ExtraFunctions.isRemindTimePossible(
          taskTime: taskTime,
          remindBefore: remindTimer,
        );

  int get textFieldValue {
    switch (currentReminderOption) {
      case CurrentReminderOption.mins:
        return remindTimer.inMinutes;
      case CurrentReminderOption.hrs:
        return remindTimer.inHours;
      case CurrentReminderOption.days:
        return remindTimer.inDays;
      case CurrentReminderOption.weeks:
        return (remindTimer.inDays / 7).floor();
      default:
        return 0;
    }
  }

  DateTime get getRemindTime {
    return ExtraFunctions.findRemindTime(
      taskTime: taskTime,
      taskRemindDuration: remindTimer,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CurrentReminderState &&
        other.remindTimer == remindTimer &&
        other.currentReminderOption == currentReminderOption &&
        other.taskTime == taskTime &&
        other.isAcceptable == isAcceptable;
  }

  @override
  int get hashCode {
    return remindTimer.hashCode ^
        currentReminderOption.hashCode ^
        taskTime.hashCode ^
        isAcceptable.hashCode;
  }

  @override
  String toString() {
    return 'CurrentReminderState(remindTimer: $remindTimer, currentReminderOption: $currentReminderOption, taskTime: $taskTime, isAcceptable: $isAcceptable)';
  }
}
