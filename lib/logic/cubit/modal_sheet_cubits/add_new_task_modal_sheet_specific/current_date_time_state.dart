part of 'current_date_time_cubit.dart';

@immutable
class CurrentDateTime {
  final TimeOfDay currentTimeOnly;
  final DateTime currentDateOnly;
  final bool isAcceptable;
  final bool isTimeForced;
  final bool isDateForced;
  CurrentDateTime({
    required this.currentTimeOnly,
    required this.currentDateOnly,
    required this.isTimeForced,
    required this.isDateForced,
  }) : isAcceptable = ExtraFunctions.isTaskTimePossible(
          timeOfDayToCheck: currentTimeOnly,
          dateOnlyToCheck: currentDateOnly,
        );

  DateTime get finalTaskTime =>
      ExtraFunctions.findDateTimeFromTimeOfDayAndAnotherDateTime(
        timeOfDay: currentTimeOnly,
        dateTime: currentDateOnly,
      );
}
