import 'dart:async';
import 'dart:math';

import 'package:protasks/data/data_providers/chats_dao.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/data/models/recursion_interval.dart';
import 'package:flutter/material.dart';
import 'package:sembast/timestamp.dart';
import 'extra_extensions.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

class ExtraFunctions {
  // ! ID GENERATING FUNCTIONS ******************************************************
  static Uuid _uuid = Uuid();

  static String _removeUnderscore(String inputString) {
    // print("Input String to Remove Underscore: " + inputString);
    String _resultToReturn = '';
    for (int _i = 0; _i < inputString.length; _i++) {
      if (inputString[_i] != '-') {
        _resultToReturn = _resultToReturn + inputString[_i];
      }
    }
    // print("Returned String with Underscore Removed: " + _resultToReturn);
    return _resultToReturn;
  }

  static String _randomizeUppercase(String inputString) {
    // print("Input String to Randomize Uppercase: " + inputString);

    Random _randomObject = Random();
    String _resultingString = '';
    for (int _i = 0; _i < inputString.length; _i++) {
      if (_randomObject.nextBool()) {
        _resultingString += inputString[_i].toUpperCase();
      } else {
        _resultingString += inputString[_i];
      }
    }
    // print("Returned String with Randomized Uppercase: $_resultingString");
    return _resultingString;
  }

  static bool isTaskRepeatIntervalPossible({
    required RecursionInterval recursionInterval,
    required DateTime taskTime,
    required Duration remindTimer,
  }) {
    if (recursionInterval == RecursionInterval.zero) {
      return true;
    }
    if (remindTimer == Duration.zero) {
      return true;
    }
    // print("taskTime: $taskTime");
    final nextTaskTime = recursionInterval + taskTime;
    // print("nextTaskTime: $nextTaskTime");
    final nextReminderTime = nextTaskTime.subtract(remindTimer);
    // print("nextReminderTime: $nextReminderTime");
    if (nextReminderTime.isAfter(taskTime)) {
      // print("Returning true");
      return true;
    }
    // print("Returning false");
    return false;
  }

  // static String recursionIntervalToString

  static String getRandomSubsetOfString({
    required int stringToReturnLength,
    required String inputString,
  }) {
    int lengthCounter = 0;
    String stringToReturn = '';
    int inputStringLength = inputString.length;
    for (int i = 0;; i = (i + 1) % inputStringLength) {
      if (lengthCounter == stringToReturnLength) break;
      if (Random().nextBool()) {
        stringToReturn += inputString[i];
        lengthCounter++;
      }
    }
    return stringToReturn;
  }

  static String get createId {
    String _semiResultId;
    String _randomizedString;
    String _string1 = _uuid.v1();
    _string1 = _removeUnderscore(_string1);
    // print("UUID V1: $_string1");
    String _string2 = _uuid.v4();
    _string2 = _removeUnderscore(_string2);

    if (Random().nextBool()) {
      int _randomPlaceToCut = Random().nextInt(30);
      _string1 = getRandomSubsetOfString(
          stringToReturnLength: _randomPlaceToCut, inputString: _string1);
      if (30 - _randomPlaceToCut != 0) {
        _string2 = getRandomSubsetOfString(
            stringToReturnLength: 30 - _randomPlaceToCut,
            inputString: _string2);
      }
    } else {
      int _randomPlaceToCut = Random().nextInt(30);
      _string2 = getRandomSubsetOfString(
          stringToReturnLength: _randomPlaceToCut, inputString: _string2);
      if (30 - _randomPlaceToCut != 0) {
        _string1 = getRandomSubsetOfString(
            stringToReturnLength: 30 - _randomPlaceToCut,
            inputString: _string1);
      }
    }
    // print("UUID V4: $_string2");
    // int _randomPlaceToCut = 10;
    // int _randomPlaceToCut = Random().nextInt(31);
    // print("Substring cut at: $_randomPlaceToCut");
    // _string1 = _string1.substring(0, _randomPlaceToCut);
    // print("Substring v1 : $_string1");
    // _string2 = _string2.substring(0, 20);
    // _string2 = _string2.substring(_randomPlaceToCut);
    // print("Substring v4 : $_string2");
    _semiResultId = _string1 + _string2;
    // print("Semi-Result : $_semiResultId");
    _randomizedString = _randomizeUppercase(_semiResultId);
    // print("Randomized String : $_randomizedString");
    return _randomizedString;
  }

  // ! ID GENERATING FUNCTION ENDS HERE ************************************

  // *Used in Header --------------------------------------------------------
  static String headerDate(DateTime dateToCheck) {
    String? _stringToReturn = findTodayTomorrowOrYesterday(dateToCheck);
    if (_stringToReturn == null) {
      return DateFormat("dd MMM yyyy").format(DateTime.now());
    }
    return "$_stringToReturn, ${DateFormat("dd MMM yyyy").format(DateTime.now())}";
  }
  // *-----------------------------------------------------------------------

  // *Used in Task Representations -----------------------------------------------
  //
  /// This function will return [Future] when [DateTime.now()] reaches [dateTime].
  /// If [dateTime] has passed, the function stops, no [Future] is returned ever.
  static Future<bool?> updateAtThisDateTime(
      {required DateTime dateTime}) async {
    Duration duration = dateTime.difference(DateTime.now());
    if (!duration.isNegative) {
      print("Duration: $duration");
      await Future.delayed(duration);
      return true; //Returns true if we reach given time
    }
    // If the Duration is negative or invalid in some way then returns null,
    // you can use the returned value to check if the task is ever going to update
    return null;
  }
  // *----------------------------------------------------------------------------

  // Temp only [USED WITH findTodayTomorrowOrYesterday]
  // static Map<DateTime, String?> todTomYes = {};

  // *Used generally ---------------------------
  static String? findTodayTomorrowOrYesterday(
    DateTime dateToCheck, {
    bool checkForToday = true,
    bool checkForYesterday = true,
    bool checkForTomorrow = true,
  }) {
    if (!checkForToday && !checkForTomorrow && !checkForYesterday) {
      return null;
    }

    DateTime now = DateTime.now();
    String? stringToReturn;

    // ** Newly added logic *******
    dateToCheck = dateToCheck.subtract(Duration(
      hours: dateToCheck.hour,
      minutes: dateToCheck.minute,
      seconds: dateToCheck.second,
      microseconds: dateToCheck.microsecond,
      milliseconds: dateToCheck.millisecond,
    ));

    // if (todTomYes.containsKey(dateToCheck)) {
    //   print(
    //       "Already existing $dateToCheck in todTomYes with Value: ${todTomYes[dateToCheck]}");
    //   return todTomYes[dateToCheck];
    // }

    DateTime today = now.subtract(Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      microseconds: now.microsecond,
      milliseconds: now.millisecond,
    ));

    Duration difference = dateToCheck.difference(today);
    int differenceInDays = difference.inDays;
    if (checkForToday && differenceInDays == 0) {
      stringToReturn = 'Today';
      // todTomYes[dateToCheck] = 'Today';
    } else if (checkForTomorrow && differenceInDays == 1) {
      stringToReturn = 'Tomorrow';
      // todTomYes[dateToCheck] = 'Tomorrow';
    } else if (checkForYesterday && differenceInDays == -1) {
      stringToReturn = 'Yesterday';
      // todTomYes[dateToCheck] = 'Yesterday';
    }

    // **************************************

    // ** ORIGINAL Logic ******
    // if (dateToCheck.year == now.year && dateToCheck.month == now.month) {
    //   if (dateToCheck.day == now.day) {
    //     stringToReturn = 'Today';
    //   } else if (dateToCheck.day + 1 == now.day) {
    //     stringToReturn = 'Yesterday';
    //   } else if (dateToCheck.day == now.day + 1) {
    //     stringToReturn = 'Tomorrow';
    //   }
    // }
    // ************************
    return stringToReturn;
  }

  // TODO: Think of a better name maybe
  // * Used in current_date_time_cubit
  static DateTime findDateTimeFromTimeOfDayAndAnotherDateTime({
    required TimeOfDay timeOfDay,
    required DateTime dateTime,
  }) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }

  // * Used in current_date_time_cubit
  static bool isTaskTimePossible({
    required TimeOfDay timeOfDayToCheck,
    required DateTime dateOnlyToCheck,
  }) {
    DateTime currentTime = DateTime.now();
    DateTime formedTime =
        ExtraFunctions.findDateTimeFromTimeOfDayAndAnotherDateTime(
      timeOfDay: timeOfDayToCheck,
      dateTime: dateOnlyToCheck,
    );

    if (formedTime.isAfter(currentTime)) {
      return true;
    }
    return false;
  }

  static bool isRemindTimePossible({
    required DateTime taskTime,
    required Duration remindBefore,
  }) {
    DateTime currentTime = DateTime.now();
    DateTime remindTime = taskTime.subtract(remindBefore);
    if (remindTime.isAfter(currentTime)) {
      return true;
    }
    return false;
  }

  // *Used in tab_bar_view_chat ---------------------------------------
  static DateTime findJustDateWithoutTime(DateTime sourceDateTime) {
    return DateTime(
      sourceDateTime.year,
      sourceDateTime.month,
      sourceDateTime.day,
    );
  }

  // * USED IN Chat screen and Add new task screen
  static String findRelativeDateOnly({
    required DateTime date,
    bool checkForToday = true,
    bool checkForTomorrow = true,
    bool checkForYesterday = true,
  }) {
    DateTime dateTimeNow = DateTime.now();
    String toPrint = date.year != dateTimeNow.year
        ? "${DateFormat("dd MMM y").format(date)}"
        : "${DateFormat("dd MMM").format(date)}";
    return ExtraFunctions.findTodayTomorrowOrYesterday(
          date,
          checkForToday: checkForToday,
          checkForTomorrow: checkForTomorrow,
          checkForYesterday: checkForYesterday,
        ) ??
        toPrint;
  }

  // *Used in Task in Section ------------------------------------------
  static String? findRelativeDateWithTime({
    required DateTime dateAndTime,
    required bool isBy,
  }) {
    if (dateAndTime.toUtc() == DateTimeExtensions.invalid) {
      return null;
    }
    String _stringToReturn = '';
    if (isBy) {
      _stringToReturn = 'by ';
    }

    String? _todayTommorrowOrYesterday =
        findTodayTomorrowOrYesterday(dateAndTime);
    DateTime dateTimeNow = DateTime.now();

    if (_todayTommorrowOrYesterday == null) {
      if (dateAndTime.year != dateTimeNow.year) {
        return "$_stringToReturn${DateFormat("HH:mm a, MMM d y").format(dateAndTime)}";
      }

      return "$_stringToReturn${DateFormat("HH:mm a, MMM dd").format(dateAndTime)}";
    }

    return "$_stringToReturn${DateFormat("HH:mm a").format(dateAndTime)}, $_todayTommorrowOrYesterday";
  }
  // *-----------------------------------------------------

  static String? findAbsoluteDateOnly({
    required DateTime dateTime,
    bool isBy = false,
  }) {
    if (dateTime.toUtc() == DateTimeExtensions.invalid) {
      return null;
    }
    String _stringToReturn = "${DateFormat("MMM d y").format(dateTime)}";
    return isBy ? "by $_stringToReturn" : _stringToReturn;
  }

  // *Used in Task Modal Sheet ------------------------------------------
  static String? findAbsoluteDateAndTime({
    required DateTime time,
    bool isBy = false,
  }) {
    if (time.toUtc() == DateTimeExtensions.invalid) {
      return null;
    }
    String _stringToReturn = "${DateFormat("HH:mm a, MMM d y").format(time)}";
    return isBy ? "by $_stringToReturn" : _stringToReturn;
  }
  // *----------------------------------------------------------------------

  // * Used internally in findRemindTimerInWords
  static String stringToAppendWith({
    required int unitValue,
    required String unitString,
  }) {
    return unitValue > 1
        ? '$unitValue ${unitString}s'
        : '$unitValue $unitString';
  }
  // * ----------------------------------------

  static DateTime findRemindTime({
    required DateTime taskTime,
    required Duration taskRemindDuration,
  }) {
    return taskTime.subtract(taskRemindDuration);
  }

  // * Used in Modal Sheet --------------------
  static String? findDateFormattedRemindTime({
    required DateTime taskTime,
    required Duration taskRemindDuration,
  }) {
    DateTime _remindTimeInDateTime = taskTime.subtract(taskRemindDuration);
    return taskRemindDuration.inSeconds == 0
        ? null
        : findAbsoluteDateAndTime(time: _remindTimeInDateTime, isBy: false);
  }
  // * ----------------------------------------

  // * Used in Screen Sections
  static String? findRemindTimeInWords({
    required DateTime taskTime,
    required Duration taskRemindTimer,
    String? prefix = "Reminder:",
    String? suffix = "before",
  }) {
    DateTime _remindTimeInDateTime = taskTime.subtract(taskRemindTimer);
    String? _stringToAppend;

    // Initialization
    int minute = 0;
    int hour = 0;
    int day = 0;
    int week = 0;
    int month = 0;
    int year = 0;

    minute = (taskTime.minute - _remindTimeInDateTime.minute);
    if (minute < 0) {
      hour -= 1;
      minute = 60 + minute;
    }
    if (minute != 0) {
      // _stringToAppend = _stringToAppend == null
      //     ? "$minute mins"
      //     : "$_stringToAppend, $minute mins";
      _stringToAppend = "$minute mins";
    }

    hour += (taskTime.hour - _remindTimeInDateTime.hour);
    if (hour < 0) {
      day -= 1;
      hour += 24;
    }
    if (hour != 0) {
      _stringToAppend =
          _stringToAppend == null ? "$hour hrs" : "$hour hrs, $_stringToAppend";
    }

    day += (taskTime.day - _remindTimeInDateTime.day);
    if (day < 0) {
      // print("This is true");
      month -= 1;
      // print("day before: $day");
      // print(
      //     "DateTime(taskTime.year, taskTime.month + 1, 0).day : ${DateTime(taskTime.year, taskTime.month - 1, 0).day}");
      day = DateTime(_remindTimeInDateTime.year,
                  _remindTimeInDateTime.month - 1, 0)
              .day +
          day;
      // day = DateTime(taskTime.year, taskTime.month, 0).day + day;
      // day = DateTime(taskTime.year, taskTime.month + 1, 0).day + day; //first one
      // print("day: $day");
    }
    if (day != 0) {
      if (day % 7 == 0) {
        week = (day / 7).floor();
        _stringToAppend = _stringToAppend == null
            ? stringToAppendWith(unitValue: week, unitString: "week")
            : "${stringToAppendWith(unitValue: week, unitString: 'week')}, $_stringToAppend";
      } else {
        _stringToAppend = _stringToAppend == null
            ? stringToAppendWith(unitValue: day, unitString: "day")
            : "${stringToAppendWith(unitValue: day, unitString: 'day')}, $_stringToAppend";
      }
    }

    month += (taskTime.month - _remindTimeInDateTime.month);
    if (month < 0) {
      year -= 1;
      month += 12;
    }
    if (month != 0) {
      _stringToAppend = _stringToAppend == null
          ? stringToAppendWith(unitValue: month, unitString: 'month')
          : "${stringToAppendWith(unitValue: month, unitString: 'month')}, $_stringToAppend";
    }

    year += (taskTime.year - _remindTimeInDateTime.year);
    if (year != 0) {
      // _stringToAppend =
      //     _stringToAppendWith(unitValue: year, unitString: 'year');

      _stringToAppend = _stringToAppend == null
          ? stringToAppendWith(unitValue: year, unitString: 'year')
          : "${stringToAppendWith(unitValue: year, unitString: 'year')}, $_stringToAppend";
    }

    return (taskRemindTimer.inSeconds == 0)
        ? null
        : '${prefix != null ? '$prefix ' : ''}$_stringToAppend${suffix != null ? ' $suffix' : ''}';
  }
  // * ----------------------------------------

  static void updateTextEditingControllerValue({
    required TextEditingController textEditingController,
    required String newValue,
  }) {
    textEditingController.text = '$newValue';
    textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: textEditingController.text.length));
  }

  // * USED IN MODAL SHEET --------------------
  static String priorityToText({
    required TaskPriority taskPriority,
  }) {
    // if (taskPriority == TaskPriority.low) {
    //   return null;
    // }
    String stringToReturn =
        EnumToString.convertToString(taskPriority, camelCase: true);
    stringToReturn = stringToReturn + ' Priority';
    return stringToReturn.capitalize;
  }
  // * -----------------------------------------

  // * USED IN MODAL SHEET  --------------------
  static String? findRecursionIntervalInWords({
    required RecursionInterval recursionInterval,
  }) {
    if (recursionInterval == RecursionInterval.zero) {
      return null;
    }
    String _stringToReturn = 'Every';
    if (recursionInterval.years != 0) {
      _stringToReturn =
          "$_stringToReturn ${stringToAppendWith(unitValue: recursionInterval.years, unitString: 'year')}";
    }
    if (recursionInterval.months != 0) {
      if (_stringToReturn == 'Every') {
        _stringToReturn =
            "$_stringToReturn ${stringToAppendWith(unitValue: recursionInterval.months, unitString: 'month')}";
      } else {
        _stringToReturn =
            "$_stringToReturn ,${stringToAppendWith(unitValue: recursionInterval.months, unitString: 'month')}";
      }
    }
    if (recursionInterval.days != 0) {
      if (_stringToReturn == 'Every') {
        _stringToReturn =
            "$_stringToReturn ${stringToAppendWith(unitValue: recursionInterval.days, unitString: 'day')}";
      } else {
        _stringToReturn =
            "$_stringToReturn ,${stringToAppendWith(unitValue: recursionInterval.days, unitString: 'day')}";
      }
    }
    if (recursionInterval.hours != 0) {
      if (_stringToReturn == 'Every') {
        _stringToReturn =
            "$_stringToReturn ${stringToAppendWith(unitValue: recursionInterval.hours, unitString: 'hour')}";
      } else {
        _stringToReturn =
            "$_stringToReturn ,${stringToAppendWith(unitValue: recursionInterval.hours, unitString: 'hour')}";
      }
    }
    if (recursionInterval.minutes != 0) {
      if (_stringToReturn == 'Every') {
        _stringToReturn =
            "$_stringToReturn ${stringToAppendWith(unitValue: recursionInterval.minutes, unitString: 'minute')}";
      } else {
        _stringToReturn =
            "$_stringToReturn ,${stringToAppendWith(unitValue: recursionInterval.minutes, unitString: 'minute')}";
      }
    }
    return _stringToReturn;
  }
  // * ------------------------------------------------

  // TODO: Find a better name
  // USED IN DASHBOARD SCREEN
  // * Fetches subtask count only one time
  static Stream<int> minimalTaskRepresentation(String taskId) async* {
    // Map<String, int> _mapToReturn = {
    //   'subtaskCount': taskSubtasksCount[taskId] ?? 0,
    // };
    // yield _mapToReturn;
    // _mapToReturn['subtaskCount'] =
    // yield ChatsDao().findUnreadChatCount(taskId).map((event) {
    //   return event;
    // });
    // yield TasksDao().findSubtaskCount(taskId).map((event) => event);
    // yield* Rx.combineLatest2(ChatsDao().findUnreadChatCount(taskId),
    //     TasksDao().findSubtaskCount(taskId), (a, b) => );
    yield* Rx.merge([
      TasksDao().findSubtaskCount(taskId),
      ChatsDao().findUnreadChatCount(taskId)
    ]).map((event) {
      print("RxMerge: $event");
      return event;
    });
  }

  // ** TO BE USED FOR NOTIFICATIONS ID **

  static String intFromStringSequence(String sourceString) {
    String result = '';
    for (int i = 0; i < sourceString.length; i++) {
      if (result.length >= 5) {
        break;
      }
      result += "${int.tryParse(sourceString[i]) ?? ''}";
    }
    // return int.tryParse(result) ?? 0;
    print("intFromStringSequence : $result");
    return result;
  }

  static int makeIntIdFromStringIdAndDateTime({
    required String stringId,
    required DateTime sourceDateTime,
  }) {
    final String string2 =
        "${dateTimeToIntTimestamp(sourceDateTime)}".substring(0, 4);
    return int.tryParse("${intFromStringSequence(stringId)}$string2") ??
        Random().nextInt(99999);
  }

  static int dateTimeToIntTimestamp(DateTime source) {
    print(
        "dateTimeToIntTimestamp $source: ${Timestamp.fromDateTime(source.toUtc()).seconds}");
    return Timestamp.fromDateTime(source.toUtc()).seconds;
  }
}
