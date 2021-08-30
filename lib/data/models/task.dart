import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/timestamp.dart';

import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/models/recursion_interval.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/extra_functions.dart';

// TODO: Make Properties SECURE by using '_' and use get/set to access or change their value(if any)
class Task {
  String id;
  String groupId;
  String description;
  DateTime time;
  bool isBy;
  bool isCompleted;
  TaskPriority taskPriority;

  // ? In place of [RecursionInterval], why are we not using [Duration] instead,
  // ? as it also has almost all the same parameters ?
  // * ANSWER - Because a user can set a task to repeat every year, and since
  // * [Duration] doesn't have that, it would be better to have our own data type.
  RecursionInterval recursionInterval;

  DateTime recursionTill;
  DateTime createdOn;
  String createdBy;
  DateTime modifiedOn;
  String modifiedBy;
  String parentTaskId;
  Duration remindTimer;
  List<String> assignedTo;
  bool isSynced;
  bool isDeleted;

  Task({
    required this.id,
    required this.groupId,
    required this.description,
    required this.time,
    required this.isBy,
    required this.isCompleted,
    required this.taskPriority,
    required this.recursionInterval,
    required this.recursionTill,
    required this.createdOn,
    required this.createdBy,
    required this.modifiedOn,
    required this.modifiedBy,
    required this.parentTaskId,
    required this.remindTimer,
    required this.assignedTo,
    required this.isSynced,
    required this.isDeleted,
  }) {
    // [time] to [time without seconds, milliseconds, etc.]
    time = time.subtract(
      Duration(
        microseconds: time.microsecond,
        milliseconds: time.millisecond,
        seconds: time.second,
      ),
    );
  }

  bool get isOverdue {
    if (!isCompleted && DateTime.now().isAfter(time)) {
      return true;
    }
    return false;
  }

  DateTime get remindTime {
    return ExtraFunctions.findRemindTime(
      taskTime: time,
      taskRemindDuration: remindTimer,
    );
  }

  DateTime? get nextPossibleTaskTime {
    if (recursionInterval == RecursionInterval.zero) {
      return null;
    }
    DateTime nextTaskTime = recursionInterval + time;
    while (nextTaskTime.isBefore(DateTime.now())) {
      nextTaskTime = recursionInterval + nextTaskTime;
    }
    if (recursionTill.toUtc() != DateTimeExtensions.invalid) {
      // print("Recursion Till: $recursionTill");
      // print("DateTimeExtension: ${DateTimeExtensions.invalid}");
      if (nextTaskTime.isAfter(recursionTill) ||
          nextTaskTime.isAtSameMomentAs(recursionTill)) {
        return null;
      }
    }

    return nextTaskTime;
  }

  bool get isRecursive {
    if (recursionInterval == RecursionInterval.zero) {
      return false;
    }
    if (recursionTill.toUtc() == DateTimeExtensions.invalid) {
      return true;
    }
    if (nextPossibleTaskTime == null) {
      return false;
    }
    return true;
  }

  Map<String, dynamic> toMapForDatabase() {
    return {
      'id': id,
      'groupId': groupId,
      'description': description,
      'time': Timestamp.fromDateTime(time.toUtc()),
      'isBy': isBy,
      'isCompleted': isCompleted,
      'taskPriority': EnumToString.convertToString(taskPriority),
      'recursionInterval': recursionInterval.toMap(),
      'recursionTill': Timestamp.fromDateTime(recursionTill),
      'createdOn': Timestamp.fromDateTime(createdOn.toUtc()),
      'createdBy': createdBy,
      'modifiedOn': Timestamp.fromDateTime(modifiedOn.toUtc()),
      'modifiedBy': modifiedBy,
      'parentTaskId': parentTaskId,
      'remindTimer': remindTimer.inMinutes,
      'assignedTo': assignedTo,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  static Task fromMapOfDatabase(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      groupId: map['groupId'],
      description: map['description'],
      time: (map['time'] as Timestamp).toDateTime(),
      isBy: map['isBy'],
      isCompleted: map['isCompleted'],
      taskPriority:
          EnumToString.fromString(TaskPriority.values, map['taskPriority']) ??
              TaskPriority.high,
      recursionInterval: RecursionInterval.fromMap(map['recursionInterval']),
      recursionTill: (map['recursionTill'] as Timestamp).toDateTime(),
      createdOn: (map['createdOn'] as Timestamp).toDateTime(),
      createdBy: map['createdBy'],
      modifiedOn: (map['modifiedOn'] as Timestamp).toDateTime(),
      modifiedBy: map['modifiedBy'],
      parentTaskId: map['parentTaskId'] ?? Strings.noTaskID,
      assignedTo: List<String>.from((map['assignedTo'])),
      remindTimer: Duration(
        minutes: map['remindTimer'],
      ),
      isSynced: map['isSynced'],
      isDeleted: map['isDeleted'],
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, groupId: $groupId, description: $description, time: $time, isBy: $isBy, isCompleted: $isCompleted, recursionInterval: $recursionInterval, recursionTill: $recursionTill, createdOn: $createdOn, createdBy: $createdBy, modifiedOn: $modifiedOn, modifiedBy: $modifiedBy, parentTaskId: $parentTaskId, remindTimer: $remindTimer, assignedTo: $assignedTo, isSynced: $isSynced, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.groupId == groupId &&
        other.description == description &&
        other.time == time &&
        other.isBy == isBy &&
        other.isCompleted == isCompleted &&
        other.recursionInterval == recursionInterval &&
        other.recursionTill == recursionTill &&
        other.createdOn == createdOn &&
        other.createdBy == createdBy &&
        other.modifiedOn == modifiedOn &&
        other.modifiedBy == modifiedBy &&
        other.parentTaskId == parentTaskId &&
        other.remindTimer == remindTimer &&
        listEquals(other.assignedTo, assignedTo) &&
        other.isSynced == isSynced &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        groupId.hashCode ^
        description.hashCode ^
        time.hashCode ^
        isBy.hashCode ^
        isCompleted.hashCode ^
        recursionInterval.hashCode ^
        recursionTill.hashCode ^
        createdOn.hashCode ^
        createdBy.hashCode ^
        modifiedOn.hashCode ^
        modifiedBy.hashCode ^
        parentTaskId.hashCode ^
        remindTimer.hashCode ^
        assignedTo.hashCode ^
        isSynced.hashCode ^
        isDeleted.hashCode;
  }

  Task copyWith({
    String? id,
    String? groupId,
    String? description,
    DateTime? time,
    bool? isBy,
    bool? isCompleted,
    RecursionInterval? recursionInterval,
    DateTime? recursionTill,
    DateTime? createdOn,
    String? createdBy,
    DateTime? modifiedOn,
    String? modifiedBy,
    String? parentTaskId,
    Duration? remindTimer,
    List<String>? assignedTo,
    bool? isSynced,
    bool? isDeleted,
    TaskPriority? taskPriority,
  }) {
    return Task(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      description: description ?? this.description,
      time: time ?? this.time,
      isBy: isBy ?? this.isBy,
      isCompleted: isCompleted ?? this.isCompleted,
      recursionInterval: recursionInterval ?? this.recursionInterval,
      recursionTill: recursionTill ?? this.recursionTill,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      remindTimer: remindTimer ?? this.remindTimer,
      assignedTo: assignedTo ?? this.assignedTo,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      taskPriority: taskPriority ?? this.taskPriority,
    );
  }
}
