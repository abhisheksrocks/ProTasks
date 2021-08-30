// DAO are Database Access Objects which are used to
// Read, Insert, Update and Delete rows from the database
import 'dart:async';

import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/operation_status.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/cubit/root_cubits/ads_handler_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/sync_cubit.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:protasks/logic/firebase_rconfig_handler.dart';
import 'package:protasks/logic/my_navigator.dart';
import 'package:protasks/logic/notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_database.dart';

class TasksDao {
  static const String tableName = 'tasks';
  final _databaseTable = intMapStoreFactory.store(tableName);

  Future<Database> get _database async => await AppDatabase.instance.database;

  static Map<String, int?> taskSubtasksCount = {};

  Stream<List<Task>> getAllTasksToBeUploaded({int? limit}) async* {
    print("getAllTasksToBeUploaded called");
    final _queryRef = _databaseTable.query(
      finder: Finder(
        filter: Filter.equals('isSynced', false),
        limit: limit,
      ),
    );

    yield* _queryRef.onSnapshots(await _database).map(
        (listOfRecordSnapshots) => listOfRecordSnapshots.map((recordSnapshot) {
              print("Task to upload: ${recordSnapshot.value}");
              return Task.fromMapOfDatabase(recordSnapshot.value);
            }).toList());
  }

  Future<void> updateAllTasksWithNewUserInfo() async {
    String? getCurrentUserUID = FirebaseAuthFunctions.getCurrentUser?.uid;
    if (getCurrentUserUID == null) {
      return;
    }

    List<Task> taskList = await getAllTasks();
    taskList.forEach((task) {
      bool needToUpdate = false;
      if (task.assignedTo.contains(Strings.defaultUserUID)) {
        task.assignedTo.remove(Strings.defaultUserUID);
        task.assignedTo.add(getCurrentUserUID);
        needToUpdate = true;
      }

      if (task.createdBy == Strings.defaultUserUID) {
        task.createdBy = getCurrentUserUID;
        needToUpdate = true;
      }

      if (task.modifiedBy == Strings.defaultUserUID) {
        task.modifiedBy = getCurrentUserUID;
        needToUpdate = true;
      }

      if (needToUpdate) {
        insertOrUpdateTask(task);
      }
    });
  }

  static void defaultTaskSorter({required List<Task> taskToSort}) {
    taskToSort.sort((a, b) {
      // * complete-incomplete
      // * overdue
      // ? taskPriority ?
      // ? isBy ?
      // * time

      int cmpIsCompleted = "${a.isCompleted}".compareTo("${b.isCompleted}");
      if (cmpIsCompleted == 0) {
        DateTime dateTimeNow = DateTime.now();
        int cmpIsOverdue = "${b.time.isBefore(dateTimeNow)}"
            .compareTo("${a.time.isBefore(dateTimeNow)}");
        if (cmpIsOverdue == 0) {
          int cmpTaskPriority =
              b.taskPriority.index.compareTo(a.taskPriority.index);
          if (cmpTaskPriority == 0) {
            int cmpIsBy = "${b.isBy}".compareTo("${a.isBy}");
            if (cmpIsBy == 0) {
              return a.time.compareTo(b.time);
            }
            return cmpIsBy;
          }
          return cmpTaskPriority;
        }
        return cmpIsOverdue;
      }
      return cmpIsCompleted;
    });
  }

  Stream<List<Task>> getSpecficGroupTasks({
    required String groupID,
  }) async* {
    Finder _finder = Finder(
        filter: Filter.and(
      [
        Filter.equals('groupId', groupID),
        Filter.equals('isCompleted', false),
        Filter.equals('isDeleted', false),
      ],
    ));

    yield* _databaseTable
        .query(finder: _finder)
        .onSnapshots(await _database)
        .map((taskSnapshotList) {
      return taskSnapshotList.map((taskSnapshot) {
        return Task.fromMapOfDatabase(taskSnapshot.value);
      }).toList();
    });
  }

  static int numberOfTasksAdded = 0;

  Future<OperationStatus> insertOrUpdateTask(Task task) async {
    final _finder = Finder(filter: Filter.equals('id', task.id));

    print("Task is synced: ${task.isSynced}");
    print("lastTaskSyncTime : ${MyNavigator.context!.read<SyncCubit>().state.lastTaskSyncTime}");
    print("lastTaskSyncTime != DateTimeExtensions.invalid : ${MyNavigator.context!.read<SyncCubit>().state.lastTaskSyncTime !=
                DateTimeExtensions.invalid}");

    try {
      final _recordSnapshot =
          await _databaseTable.findFirst(await _database, finder: _finder);

      if (_recordSnapshot == null) {
        await _databaseTable.add(
          await _database,
          task.toMapForDatabase(),
        );
        await NotificationHandler.makeTaskReminder(
          MyNavigator.context,
          givenTask: task,
        );
        if (!task.isSynced &&
            MyNavigator.context!.read<SyncCubit>().state.lastTaskSyncTime !=
                DateTimeExtensions.invalid) {
          //i.e. created by user
          numberOfTasksAdded += 1;
          if (numberOfTasksAdded >= FirebaseRConfigHandler.tasksPerAd) {
            (MyNavigator.context!)
                .read<AdsHandlerCubit>()
                .performActionBasedOnLoginState();
            numberOfTasksAdded = 0;
          }
        }
        return OperationStatus(
          returnStatus: ReturnStatus.success,
          databaseInsertStatus: DatabaseInsertStatus.createdNew,
        );
      }
      // else {
      await _databaseTable.update(
        await _database,
        task.toMapForDatabase(),
        finder: _finder,
      );
      Task _presentTask = Task.fromMapOfDatabase(_recordSnapshot.value);
      NotificationHandler.cancelNotification(
        taskId: _presentTask.id,
        taskRemindTime: _presentTask.remindTime,
      );
      await NotificationHandler.makeTaskReminder(
        MyNavigator.context,
        givenTask: task,
      );
      if (!task.isSynced ) {
        //i.e. created by user
        numberOfTasksAdded += 1;
        if (numberOfTasksAdded >= FirebaseRConfigHandler.tasksPerAd) {
          (MyNavigator.context!)
              .read<AdsHandlerCubit>()
              .performActionBasedOnLoginState();
          numberOfTasksAdded = 0;
        }
      }
      return OperationStatus(
        returnStatus: ReturnStatus.success,
        databaseInsertStatus: DatabaseInsertStatus.updatedValue,
      );
    } catch (exception) {
      print("insertOrUpdateTask exception: $exception");
      return OperationStatus(
        returnStatus: ReturnStatus.failure,
        databaseInsertStatus: DatabaseInsertStatus.insertFailed,
      );
    }

    // }
  }

  // USED
  // Filter generalAssignedTo = Filter.or([
  //   Filter.custom((record) => record.value['assignedTo'].isEmpty),
  //   Filter.equals('assignedTo', Strings.defaultUserUID, anyInList: true),
  // ]);

  // StreamSubscription? groupStreamSubscription;
  // StreamSubscription? tasksStreamSubscription;
  // USED

  Stream<List<Task>> getTodayTasksOfGroupList(List<String> groupIdList) async* {
    DateTime now = DateTime.now();
    DateTime todayZero = now.subtract(Duration(
      hours: now.hour,
      microseconds: now.microsecond,
      milliseconds: now.millisecond,
      minutes: now.minute,
      seconds: now.second,
    ));

    DateTime today24 = todayZero.add(Duration(days: 1));

    yield* _databaseTable
        .query(
            finder: Finder(
          filter: Filter.and([
            Filter.equals('isCompleted', false),
            Filter.equals('isDeleted', false),
            Filter.lessThanOrEquals(
              'time',
              Timestamp.fromDateTime(today24),
            ),
            Filter.inList('groupId', groupIdList),
            // Filter.equals('groupId', _groupIdList, anyInList: true),
          ]),
        ))
        .onSnapshots(await _database)
        .map(
          (listOfRecordSnapshots) => listOfRecordSnapshots
              .map((recordSnapshot) =>
                  Task.fromMapOfDatabase(recordSnapshot.value))
              .toList(),
        );
  }

  Stream<List<Task>> getDashboardTasks() async* {
    // groupStreamSubscription?.cancel();

    // groupStreamSubscription =
    //     GroupsDao().findAllGroups().listen((groupList) async {
    //   tasksStreamSubscription?.cancel();
    //   await for (final value
    //       in _databaseTable.query().onSnapshots(await _database)) {}
    // });

    DateTime now = DateTime.now();
    DateTime todayZero = now.subtract(Duration(
      hours: now.hour,
      microseconds: now.microsecond,
      milliseconds: now.millisecond,
      minutes: now.minute,
      seconds: now.second,
    ));

    DateTime today24 = todayZero.add(Duration(days: 1));

    // await for (var groupList in GroupsDao().findAllGroups()) {
    // print("dashboard groupList: $groupList");
    // List<String> _groupIdList = groupList.map((e) => e.id).toList();
    await for (var taskList in _databaseTable
        .query(
          finder: Finder(
            filter: Filter.and([
              Filter.equals('isCompleted', false),
              Filter.equals('isDeleted', false),
              Filter.lessThanOrEquals(
                'time',
                Timestamp.fromDateTime(today24),
              ),
              // Filter.inList('groupId', _groupIdList),
              // Filter.equals('groupId', _groupIdList, anyInList: true),
            ]),
          ),
        )
        .onSnapshots(await _database)
        .map(
          (listOfRecordSnapshots) => listOfRecordSnapshots
              .map((recordSnapshot) =>
                  Task.fromMapOfDatabase(recordSnapshot.value))
              .toList(),
        )) {
      print("TaskList for Dashboard: $taskList");
      yield taskList;
    }
    // }

    // DateTime twoDaysBeforeZero = todayZero.subtract(Duration(days: 2));

    // Filter.inList('assignedTo', []);

    // final Finder _finder = Finder(
    //     filter: Filter.or(
    //   [
    //     // Filter.and([
    //     //   generalAssignedTo,
    //     //   Filter.lessThanOrEquals(
    //     //     'time',
    //     //     Timestamp.fromDateTime(today24),
    //     //   ),
    //     // ]),
    //     // Filter.and([
    //     //   generalAssignedTo,
    //     //   Filter.equals('isCompleted', true),
    //     //   Filter.greaterThanOrEquals(
    //     //     'modifiedOn',
    //     //     Timestamp.fromDateTime(twoDaysBeforeZero),
    //     //   ),
    //     // ]),
    //     Filter.and([
    //       Filter.equals('isCompleted', false),
    //       Filter.lessThanOrEquals(
    //         'time',
    //         Timestamp.fromDateTime(today24),
    //       ),
    //     ]),
    //   ],
    // ));

    // final _querySnapshot = _databaseTable.query(finder: _finder);

    // yield* _querySnapshot.onSnapshots(await _database).map((event) {
    //   return event.map((taskSnapshot) {
    //     return Task.fromMapOfDatabase(taskSnapshot.value);
    //   }).toList();
    // });
  }

  Stream<List<Task>> getDeletedTasks() async* {
    yield* _databaseTable
        .query(
          finder: Finder(
            filter: Filter.and([
              Filter.equals('isDeleted', true),
            ]),
          ),
        )
        .onSnapshots(await _database)
        .map((listOfRecordSnapshots) => listOfRecordSnapshots
            .map((recordSnapshot) =>
                Task.fromMapOfDatabase(recordSnapshot.value))
            .toList());
  }

  Stream<List<Task>> getCompletedTasks() async* {
    yield* _databaseTable
        .query(
          finder: Finder(
            filter: Filter.and([
              Filter.equals('isCompleted', true),
              Filter.equals('isDeleted', false),
            ]),
          ),
        )
        .onSnapshots(await _database)
        .map((listOfRecordSnapshots) => listOfRecordSnapshots
            .map((recordSnapshot) =>
                Task.fromMapOfDatabase(recordSnapshot.value))
            .toList());
  }

  Future<List<Task>> getAllTasks() async {
    final _finder = Finder(sortOrders: [
      SortOrder('time'),
    ]);

    final recordSnapshots =
        await _databaseTable.find(await _database, finder: _finder);

    return recordSnapshots.map((taskSnapshot) {
      print("Snapshot value getAllTasks: ");
      return Task.fromMapOfDatabase(taskSnapshot.value)..toString();
    }).toList();
  }

  // USED
  Stream<Task?> getSingleTaskDetailsStream({required String taskId}) async* {
    final _finder = Finder(
      filter: Filter.equals('id', taskId),
      limit: 1,
    );

    final _querySnapshot = _databaseTable.query(
      finder: _finder,
    );

    yield* _querySnapshot.onSnapshot(await _database).map((taskSnapshot) {
      if (taskSnapshot == null) {
        print("Invalid TaskId or TaskId not yet found in database");
        // throw TaskException("Task Not Found");
        return null;
      } else {
        return Task.fromMapOfDatabase(taskSnapshot.value);
      }
    });
  }

  Stream<List<Task>> getAllTasksByDateTimeRangeStream({
    required DateTimeRange dateTimeRange,
    bool includeCompleted = true,
  }) async* {
    final _finder = Finder(
      filter: Filter.and(
        [
          // Filter.equals('isCompleted', false),
          Filter.greaterThan(
              'time', Timestamp.fromDateTime(dateTimeRange.start)),
          Filter.lessThan('time', Timestamp.fromDateTime(dateTimeRange.end)),
        ],
      ),
      // ! Not using sort here since we are sorting later
      // sortOrders: [
      // SortOrder('isCompleted'),
      //   SortOrder('time'),
      // ],
    );

    // final _recordSnapshots =
    //     await _databaseTable.find(await _database, finder: _finder);

    final _querySnapshot = _databaseTable.query(finder: _finder);

    Database _myDatabase = await _database;

    yield* _querySnapshot.onSnapshots(_myDatabase).map((event) {
      // print("This is executed");
      List<Task> taskList = event.map((taskSnapshot) {
        // return event.map((taskSnapshot) {
        // print("Snapshot value getAllTasksByDateTimeRange: ");
        // print("Snapvalue value: ${taskSnapshot.value}");
        return Task.fromMapOfDatabase(taskSnapshot.value)..toString();
      }).toList();
      defaultTaskSorter(taskToSort: taskList);
      return taskList;
      // }).toList()
      // ..sort((a, b) {
      //   // * complete-incomplete
      //   // * overdue
      //   // ? taskPriority ?
      //   // ? isBy ?
      //   // * time

      //   int cmpIsCompleted = "${a.isCompleted}".compareTo("${b.isCompleted}");
      //   if (cmpIsCompleted == 0) {
      //     DateTime dateTimeNow = DateTime.now();
      //     int cmpIsOverdue = "${b.time.isBefore(dateTimeNow)}"
      //         .compareTo("${a.time.isBefore(dateTimeNow)}");
      //     if (cmpIsOverdue == 0) {
      //       int cmpTaskPriority =
      //           b.taskPriority.index.compareTo(a.taskPriority.index);
      //       if (cmpTaskPriority == 0) {
      //         int cmpIsBy = "${b.isBy}".compareTo("${a.isBy}");
      //         if (cmpIsBy == 0) {
      //           return a.time.compareTo(b.time);
      //         }
      //         return cmpIsBy;
      //       }
      //       return cmpTaskPriority;
      //     }
      //     return cmpIsOverdue;
      //   }
      //   return cmpIsCompleted;
      // });
    });
  }

  // Stream<List<Task>> tasksToBeRemoved() async* {
  //   final Finder _finder = Finder(
  //     filter: Filter.equals('field', value)
  //   );
  // }

  // Future<void> deleteTaskCompletelyById(String taskId){}

  // Stream<Task> getOldestCompletedTask() async* {
  //   final Finder _finder = Finder(
  //     filter: Filter.equals('isCompleted', true),
  //     sortOrders: [
  //       SortOrder('modifiedOn'),
  //     ],
  //     limit: 1,
  //   );

  //   _databaseTable.query(finder: _finder)
  // }

  Future<void> removeTasksDatabaseForGroup({
    required String groupId,
  }) async {
    await _databaseTable.delete(await _database,
        finder: Finder(
          filter: Filter.equals('groupId', groupId),
        ));
  }

  // Future<void> trashOrRestoreAllGroupTasks({
  //   required String groupID,
  //   required bool moveToTrash,
  // }) async {
  //   final _finder = Finder(
  //     filter: Filter.equals(
  //       'groupId',
  //       groupID,
  //     ),
  //   );

  //   final Database _myDatabase = await _database;
  //   await _databaseTable.update(
  //     _myDatabase,
  //     {
  //       'isDeleted': moveToTrash,
  //     },
  //     finder: _finder,
  //   );
  // }

  // Rule: I am allowing to trash or restore tasks in the backend, without
  // verifying whether the task group is in trash state or not. I plan to
  // only show those tasks in deleted section, whose groups aren't
  Future<void> trashOrRestoreTask({
    required String taskId,
    required bool moveToTrash,
  }) async {
    Finder _finder;
    if (moveToTrash) {
      _finder = Finder(
        filter: Filter.or([
          Filter.equals('id', taskId),
          Filter.equals('parentTaskId', taskId),
        ]),
      );
    } else {
      _finder = Finder(
        filter: Filter.equals('id', taskId),
      );
    }

    final Database _myDatabase = await _database;

    final listOfRecordSnapshots =
        await _databaseTable.find(await _database, finder: _finder);

    if (listOfRecordSnapshots.isNotEmpty) {
      if (moveToTrash) {
        for (var i = 0; i < listOfRecordSnapshots.length; i++) {
          Task _taskAtIndex =
              Task.fromMapOfDatabase(listOfRecordSnapshots.elementAt(i).value);
          NotificationHandler.cancelNotification(
            taskId: _taskAtIndex.id,
            taskRemindTime: _taskAtIndex.remindTime,
          );
          if (_taskAtIndex.id != taskId) {
            await trashOrRestoreTask(
              taskId: _taskAtIndex.id,
              moveToTrash: moveToTrash,
            );
          }
        }
      } else {
        for (var i = 0; i < listOfRecordSnapshots.length; i++) {
          Task _taskAtIndex =
              Task.fromMapOfDatabase(listOfRecordSnapshots.elementAt(i).value);
          await NotificationHandler.makeTaskReminder(
            MyNavigator.context,
            givenTask: _taskAtIndex,
          );

          if (_taskAtIndex.parentTaskId != Strings.noTaskID) {
            await trashOrRestoreTask(
              taskId: _taskAtIndex.parentTaskId,
              moveToTrash: moveToTrash,
            );
          }
        }
      }
    }

    // if (moveToTrash) {
    await _databaseTable.update(
      _myDatabase,
      {
        'isDeleted': moveToTrash,
        'isSynced': false,
      },
      finder: _finder,
    );
    if (moveToTrash) {
      // NotificationHandler.cancelNotification(notificationId)
      Fluttertoast.showToast(msg: "Moved to 'Recycle Bin'");
    } else {
      Fluttertoast.showToast(msg: "Task restored");
    }
    // } else {
    //   final recordSnapshot = await _databaseTable.findFirst(
    //     _myDatabase,
    //     finder: _finder,
    //   );
    //   if (recordSnapshot == null) {
    //     return;
    //   }
    //   Task toRecover = Task.fromMapOfDatabase(recordSnapshot.value);
    //   Group? group =
    //       await GroupsDao().findGroupById(groupID: toRecover.groupId);
    //   if (group != null) {
    //     if (!group.isDeleted) {
    //       await _databaseTable.update(
    //         _myDatabase,
    //         {
    //           'isDeleted': moveToTrash,
    //         },
    //         finder: _finder,
    //       );
    //     }
    //   }
    //   // if (toRecover.groupId) {
    //   // } else {}
    // }
  }

  // Future<void> deleteTask({required String taskId}) async {
  //   final _finder = Finder(
  //     filter: Filter.or([
  //       Filter.equals('id', taskId),
  //       Filter.equals('parentTaskId', taskId),
  //     ]),
  //   );

  //   print(
  //       "tasks deleted: ${await _databaseTable.delete(await _database, finder: _finder)}");
  // }

  Future changeIsCompletedNew({required String taskId}) async {
    final _finderForParent = Finder(
      filter: Filter.equals('id', taskId),
    );

    Database _myDatabase = await _database;

    final recordSnapshot = await _databaseTable.findFirst(
      _myDatabase,
      finder: _finderForParent,
    );

    if (recordSnapshot != null) {
      Task parentTaskToUpdate = Task.fromMapOfDatabase(recordSnapshot.value);
      if (parentTaskToUpdate.isRecursive && !parentTaskToUpdate.isCompleted) {
        // if (!parentTaskToUpdate.isCompleted) {
        //   //because we will update this below
        //   await NotificationHandler.cancelNotification(
        //       ExtraFunctions.makeIntIdFromStringIdAndDateTime(
        //     stringId: parentTaskToUpdate.id,
        //     sourceDateTime: parentTaskToUpdate.remindTime,
        //   ));
        // } else {
        NotificationHandler.cancelNotification(
          taskId: parentTaskToUpdate.id,
          taskRemindTime: parentTaskToUpdate.remindTime,
        );

        await NotificationHandler.makeTaskReminder(
          MyNavigator.context,
          givenTask: parentTaskToUpdate.copyWith(
            time: parentTaskToUpdate.nextPossibleTaskTime,
          ),
        );

        // }

        _databaseTable.update(
            _myDatabase,
            {
              'time': Timestamp.fromDateTime(
                parentTaskToUpdate.nextPossibleTaskTime!,
              ),
              'modifiedOn': Timestamp.now(),
              'modifiedBy': FirebaseAuthFunctions.getCurrentUser?.uid ??
                  Strings.defaultUserUID,
              'isSynced': false,
            },
            finder: Finder(
              filter: Filter.byKey(recordSnapshot.key),
            ));

        Fluttertoast.showToast(msg: 'Updated task time');

        // final updatedParentRecordSnapshot = await _databaseTable
        //     .record(recordSnapshot.key)
        //     .getSnapshot(_myDatabase);

        // Task updatedParentTask =
        //     Task.fromMapOfDatabase(updatedParentRecordSnapshot!.value);

        // await NotificationHandler.makeTaskReminder(
        //   null,
        //   givenTask: updatedParentTask,
        // );
      } else {
        if (!parentTaskToUpdate.isCompleted) {
          // task to be marked as completed
          NotificationHandler.cancelNotification(
            taskId: parentTaskToUpdate.id,
            taskRemindTime: parentTaskToUpdate.remindTime,
          );
        } else {
          await NotificationHandler.makeTaskReminder(
            MyNavigator.context,
            givenTask: parentTaskToUpdate,
          );
        }

        _databaseTable.update(
          _myDatabase,
          {
            'isCompleted': !parentTaskToUpdate.isCompleted,
            'modifiedOn': Timestamp.now(),
            'modifiedBy': FirebaseAuthFunctions.getCurrentUser?.uid ??
                Strings.defaultUserUID,
            'isSynced': false,
          },
          finder: Finder(
            filter: Filter.byKey(recordSnapshot.key),
          ),
        );

        if (!parentTaskToUpdate.isCompleted) {
          Fluttertoast.showToast(msg: "Moved to 'Completed Tasks'");
        } else {
          Fluttertoast.showToast(msg: "Task Restored to Group");
        }

        final _finderForChildren = Finder(
          filter: Filter.equals('parentTaskId', taskId),
        );

        final recordSnapshotList =
            await _databaseTable.find(_myDatabase, finder: _finderForChildren);

        bool childWillBeCompleted = !parentTaskToUpdate.isCompleted;
        recordSnapshotList.forEach((recordSnapshot) async {
          Task _taskToUpdate = Task.fromMapOfDatabase(recordSnapshot.value);

          if (childWillBeCompleted) {
            // i.e. updatedParentTask is Completed
            //because we will update this below
            NotificationHandler.cancelNotification(
              taskId: _taskToUpdate.id,
              taskRemindTime: _taskToUpdate.remindTime,
            );
          } else {
            // i.e. updated parent task is not completed
            await NotificationHandler.makeTaskReminder(
              MyNavigator.context,
              givenTask: _taskToUpdate,
            );
          }

          Finder _newFinder = Finder(
            filter: Filter.byKey(recordSnapshot.key),
          );
          // _databaseTable.record(key)

          await _databaseTable.update(
            _myDatabase,
            {
              'isCompleted': childWillBeCompleted,
              'modifiedOn': Timestamp.now(),
              'modifiedBy': FirebaseAuthFunctions.getCurrentUser?.uid ??
                  Strings.defaultUserUID,
              'isSynced': false,
            },
            finder: _newFinder,
          );
        });
      }
    }
  }

  // Future changeIsCompleted({required String taskId}) async {
  //   final _finder = Finder(
  //     filter: Filter.or(
  //       [
  //         Filter.equals('id', taskId),
  //         Filter.equals('parentTaskId', taskId),
  //       ],
  //     ),
  //     sortOrders: [
  //       SortOrder('parentTaskId', false),
  //     ],
  //   );

  //   Database _myDatabase = await _database;

  //   // final _recordSnapshot =
  //   //     await _databaseTable.findFirst(_myDatabase, finder: _finder);

  //   final _recordSnapshots =
  //       await _databaseTable.find(_myDatabase, finder: _finder);

  //   // bool? newValue;
  //   // bool? oldValue;

  //   // print("RecordSnapshots length: ${_recordSnapshots.length}");

  //   _recordSnapshots.forEach(
  //     (recordSnapshot) async {
  //       Task taskToUpdate = Task.fromMapOfDatabase(recordSnapshot.value);

  //       if (!taskToUpdate.isCompleted) {
  //         await NotificationHandler.cancelNotification(
  //             ExtraFunctions.makeIntIdFromStringIdAndDateTime(
  //           stringId: taskToUpdate.id,
  //           sourceDateTime: taskToUpdate.remindTime,
  //         ));
  //       } else {
  //         await NotificationHandler.makeTaskReminder(
  //           null,
  //           givenTask: taskToUpdate,
  //         );
  //       }
  //       // if (oldValue == null) {
  //       //   oldValue = taskToUpdate.isCompleted;
  //       // }
  //       // // print("is oldValue == null ? : ${oldValue == null}");
  //       // if (newValue == null) {
  //       //   newValue = oldValue == null ? true : !oldValue!;
  //       // }
  //       // print("is newValue == null ? : ${newValue == null}");

  //       // Filter _newFilter = Filter.byKey(recordSnapshot.key);
  //       Finder _newFinder = Finder(
  //         filter: Filter.byKey(recordSnapshot.key),
  //       );
  //       // _databaseTable.record(key)

  //       await _databaseTable.update(
  //         _myDatabase,
  //         {
  //           'isCompleted': !taskToUpdate.isCompleted,
  //         },
  //         finder: _newFinder,
  //       );
  //     },
  //   );
  // }

  // Future<List<Task>> getAllTasksByDateTimeRangeFuture(
  //     DateTimeRange dateTimeRange) async {
  //   final _finder = Finder(
  //     filter: Filter.and(
  //       [
  //         Filter.equals('isCompleted', false),
  //         Filter.greaterThan(
  //             'time', Timestamp.fromDateTime(dateTimeRange.start)),
  //         Filter.lessThan('time', Timestamp.fromDateTime(dateTimeRange.end)),
  //       ],
  //     ),
  //     sortOrders: [
  //       // SortOrder('isCompleted'),
  //       SortOrder('time'),
  //     ],
  //   );

  //   final _recordSnapshots =
  //       await _databaseTable.find(await _database, finder: _finder);

  //   // print(
  //   //     "RECORD SNAPSHOT getAllTasksByDateTimeRange length: ${_recordSnapshots.length}");

  //   return _recordSnapshots.map((taskSnapshot) {
  //     print("Snapshot value getAllTasksByDateTimeRange: ");
  //     return Task.fromMapOfDatabase(taskSnapshot.value)..toString();
  //   }).toList();
  // }

  // Future<String> findPersonById({required String personId}) async {
  //   if (personId == '' || personId == null) {
  //     return '';
  //   }
  //   if (personId == 'Abhishek') {
  //     return 'You';
  //   }
  //   return personId;
  // }

  Stream<List<Task>> findSubtask(String sourceTaskId) async* {
    yield* _databaseTable
        .query(
          finder: Finder(
            filter: Filter.equals("parentTaskId", sourceTaskId) &
                Filter.equals("isDeleted", false),
          ),
        )
        .onSnapshots(await _database)
        .map((event) {
      List<Task> taskList = event.map((taskSnapshot) {
        // print("Snapshot value getAllTasksByDateTimeRange: ");
        // print("Snapvalue value: ${taskSnapshot.value}");
        return Task.fromMapOfDatabase(taskSnapshot.value);
      }).toList();
      defaultTaskSorter(taskToSort: taskList);
      return taskList;
    });

    // int count = event.length;
    // taskSubtasksCount[sourceTaskId] = count;
    // print("findSubtaskCount, sourceTaskId: $sourceTaskId");
    // return count;
  }

  // USED IN [minimalTaskRepresentation] ABOVE
  Stream<int> findSubtaskCount(String sourceTaskId) async* {
    // int count = await _databaseTable.count(
    //   await _database,
    //   filter: Filter.equals("parentTaskId", sourceTaskId),
    // );

    yield* _databaseTable
        .query(
          finder: Finder(
            filter: Filter.equals("parentTaskId", sourceTaskId) &
                Filter.equals("isDeleted", false),
          ),
        )
        .onSnapshots(await _database)
        .map((event) {
      int count = event.length;
      taskSubtasksCount[sourceTaskId] = count;
      print("findSubtaskCount, sourceTaskId: $sourceTaskId");
      return count;
    });

    // yield count;

    // print("Here");
    // QueryRef<int, Map<String, Object?>> queryRef = _databaseTable.query(
    //   finder: _finder,
    // );
    // print("QueryRef: $queryRef");
    // yield* queryRef.onSnapshots(await _database).map((allUnreadChats) {
    //   print("Object");
    //   taskSubtasksCount[sourceTaskId] = allUnreadChats.length;
    //   return allUnreadChats.length;
    // });

    // int count = await _databaseTable.count(
    //   await _database,
    //   filter: Filter.equals("parentTaskId", sourceTaskId),
    // );
  }

  // Future<bool> ifTaskHasSubtask(String taskId) async {
  //   bool _boolToReturn = (await _databaseTable.count(
  //         await _database,
  //         filter: Filter.equals("parentTaskId", taskId),
  //       ) >
  //       0);
  //   print("isThereSubtask: $_boolToReturn");
  //   return _boolToReturn;
  // }

  Future<List<Task>> getUpcomingUnfinishedTasks() async {
    Finder _finder = Finder(
        filter: Filter.and([
      Filter.greaterThanOrEquals(
          'time', Timestamp.fromDateTime(DateTime.now())),
      Filter.equals('isCompleted', false),
      Filter.equals('isDeleted', false),
    ]));

    final queryRef = _databaseTable.query(finder: _finder);
    final snapshotList = await queryRef.getSnapshots(await _database);
    return snapshotList.map((e) {
      // print("e.value ${e.value}");
      return Task.fromMapOfDatabase(e.value);
    }).toList();
  }
}
