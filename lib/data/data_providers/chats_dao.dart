import 'dart:async';

import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/operation_status.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/data_providers/app_database.dart';
import 'package:protasks/data/models/chat.dart';
import 'package:protasks/logic/cubit/root_cubits/ads_handler_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/sync_cubit.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:protasks/logic/firebase_rconfig_handler.dart';
import 'package:protasks/logic/my_navigator.dart';
import 'package:sembast/sembast.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsDao {
  static const String tableName = 'chats';
  final _databaseTable = intMapStoreFactory.store(tableName);

  Future<Database> get _database async => await AppDatabase.instance.database;

  static Map<String, int?> taskUnreadCount = {};

  static RecordSnapshot? _lastRecordSnapshot;
  static RecordSnapshot? _firstRecordSnapshot;

  Stream<Chat> getRealtimeChatToBeUploaded() async* {
    print("getRealtimeChatToBeUploaded called");
    yield* _databaseTable
        .stream(
          await _database,
          filter: Filter.equals('isSynced', false)
          // &
          //     Filter.or([
          //       Filter.equals(
          //         'fromUId',
          //         (FirebaseAuthFunctions.getCurrentUser?.uid ??
          //             Strings.defaultUserUID),
          //       ),
          //       Filter.equals(
          //         'fromUId',
          //         Strings.defaultProTasksUID,
          //       ),
          //     ])
          ,
        )
        .map((event) => Chat.fromMapOfDatabase(event.value));
  }

  Stream<List<Chat>> getAllChatsToBeUploaded({int? limit}) async* {
    print("getAllChatsToBeUploaded called");
    final _queryRef = _databaseTable.query(
      finder: Finder(
        filter: Filter.equals('isSynced', false)
        // &
        //     Filter.or([
        //       Filter.equals(
        //         'fromUId',
        //         (FirebaseAuthFunctions.getCurrentUser?.uid ??
        //             Strings.defaultUserUID),
        //       ),
        //       Filter.equals(
        //         'fromUId',
        //         Strings.defaultProTasksUID,
        //       ),
        //     ])
        ,
        limit: limit,
      ),
    );

    yield* _queryRef.onSnapshots(await _database).map(
          (listOfRecordSnapshots) => listOfRecordSnapshots
              .map((recordSnapshot) =>
                  Chat.fromMapOfDatabase(recordSnapshot.value))
              .toList(),
        );
  }

  Future<void> updateAllChatsWithNewUserInfo() async {
    String? newUserUID = FirebaseAuthFunctions.getCurrentUser?.uid;
    if (newUserUID == null) {
      return;
    }
    await _databaseTable.update(
      await _database,
      {
        'fromUID': newUserUID,
      },
      finder: Finder(
        filter: Filter.equals('fromUID', Strings.defaultUserUID),
      ),
    );
  }

  // * USED IN TASK CHAT CUBIT --------------------------
  Future<List<Chat>> fetchChatsFromTaskID({
    required String taskID,
    bool findMore = false,
    int limit = 10,
  }) async {
    if (!findMore) {
      _lastRecordSnapshot = null;
    }
    Finder _finder = Finder(
      filter: Filter.equals('refId', taskID),
      sortOrders: [
        SortOrder('time', false),
      ],
      limit: limit,
      start: findMore
          ? Boundary(
              include: false,
              record: _lastRecordSnapshot,
            )
          : null,
    );

    List<RecordSnapshot<int, Map<String, Object?>>> _listOfRecordSnapshots =
        await _databaseTable.find(await _database, finder: _finder);

    if (_listOfRecordSnapshots.isNotEmpty) {
      _lastRecordSnapshot = _listOfRecordSnapshots.last;

      if (!findMore) {
        _firstRecordSnapshot = _listOfRecordSnapshots.first;
      }
    }

    return _listOfRecordSnapshots.map((recordSnapshot) {
      return Chat.fromMapOfDatabase(recordSnapshot.value);
    }).toList();
  }
  // * --------------------------------------------------

  // * USED IN TASK CHAT CUBIT --------------------------
  Future<List<Chat>> fetchLatestChatFromTaskIDs({
    required String taskID,
  }) async {
    if (_firstRecordSnapshot == null) {
      return [];
    }
    Finder _finder = Finder(
      filter: Filter.equals('refId', taskID),
      sortOrders: [
        SortOrder('time', false),
      ],
      end: _firstRecordSnapshot != null
          ? Boundary(include: false, record: _firstRecordSnapshot)
          : null,
    );

    final _listOfRecordSnapshots =
        await _databaseTable.find(await _database, finder: _finder);
    if (_listOfRecordSnapshots.isNotEmpty) {
      _firstRecordSnapshot = _listOfRecordSnapshots.first;
    }
    return _listOfRecordSnapshots.map((recordSnapshot) {
      return Chat.fromMapOfDatabase(recordSnapshot.value);
    }).toList();
  }
  // * --------------------------------------------------

  Future<void> markAllChatAsRead({required String taskId}) async {
    Finder _finder = Finder(
      filter: Filter.equals('refId', taskId) & Filter.equals('isSeen', false),
    );
    await _databaseTable.update(
      await _database,
      {
        "isSeen": true,
      },
      finder: _finder,
    );
  }

  // * USED IN TASK CHAT CUBIT --------------------------
  Stream<List<Chat>> fetchLatestChatStreamFromTaskIDs({
    required String taskID,
    int? limit,
  }) async* {
    Finder _finder = Finder(
      filter: Filter.equals('refId', taskID),
      sortOrders: [
        SortOrder('time', false),
      ],
      limit: limit,
      // end: _firstRecordSnapshot != null
      //     ? Boundary(include: false, record: _firstRecordSnapshot)
      //     : null,
    );

    yield* _databaseTable
        .query(finder: _finder)
        .onSnapshot(
          await _database,
        )
        .map((latestSnapshot) {
      print("Got new message");
      if (latestSnapshot != null)
        return [Chat.fromMapOfDatabase(latestSnapshot.value)];
      else
        return [];
    });

    // final _listOfRecordSnapshots =
    //     await _databaseTable.find(await _database, finder: _finder);
    // if (_listOfRecordSnapshots.isNotEmpty) {
    //   _firstRecordSnapshot = _listOfRecordSnapshots.first;
    // }
    // return _listOfRecordSnapshots.map((recordSnapshot) {
    //   return Chat.fromMapOfDatabase(recordSnapshot.value);
    // }).toList();
  }
  // * --------------------------------------------------

  // * USED IN DASHBOARD SCREEN -------------------------
  Stream<int> findUnreadChatCount(String sourceTaskId) async* {
    yield* _databaseTable
        .query(
          finder: Finder(
            filter: Filter.equals("refId", sourceTaskId) &
                Filter.equals("isSeen", false),
          ),
        )
        .onSnapshots(await _database)
        .map((event) {
      int count = event.length;
      taskUnreadCount[sourceTaskId] = count;
      print("findUnreadChat, source: $sourceTaskId");
      return count;
    });

    // int count = await _databaseTable.count(
    //   await _database,
    //   filter: Filter.equals("refId", sourceTaskId) &
    //       Filter.equals("isSeen", false),
    // );

    // yield count;
  }
  // * --------------------------------------------------

  // * USED IN CHAT DETAILS MODAL -----------------------
  Future<Chat?> findChatFromChatID(String chatID) async {
    Finder _finder = Finder(
      filter: Filter.equals('id', chatID),
    );

    final recordSnapshot = await _databaseTable.findFirst(
      await _database,
      finder: _finder,
    );

    if (recordSnapshot == null) {
      return null;
    }

    return Chat.fromMapOfDatabase(recordSnapshot.value);
  }

  static int numberOfChatsAdded = 0;

  Future<OperationStatus> insertOrUpdateChat(Chat chat) async {
    print("Task is synced: ${chat.isSynced}");
    print(
        "lastChatSyncTime : ${MyNavigator.context!.read<SyncCubit>().state.lastChatSyncTime}");
    print(
        "lastChatSyncTime != DateTimeExtensions.invalid : ${MyNavigator.context!.read<SyncCubit>().state.lastChatSyncTime != DateTimeExtensions.invalid}");

    Finder _finder = Finder(filter: Filter.equals('id', chat.id));

    try {
      final _recordSnapshot =
          await _databaseTable.findFirst(await _database, finder: _finder);

      if (_recordSnapshot == null) {
        await _databaseTable.add(
          await _database,
          chat.toMapForDatabase(),
        );
        print("Creating new chat ${chat.toMapForDatabase()}");
        if (!chat.isSynced &&
            MyNavigator.context!.read<SyncCubit>().state.lastChatSyncTime !=
                DateTimeExtensions.invalid) {
          //i.e. created by user
          numberOfChatsAdded += 1;
          if (numberOfChatsAdded >= FirebaseRConfigHandler.chatsPerAd) {
            (MyNavigator.context!)
                .read<AdsHandlerCubit>()
                .performActionBasedOnLoginState();
            numberOfChatsAdded = 0;
          }
        }
        return OperationStatus(
          returnStatus: ReturnStatus.success,
          databaseInsertStatus: DatabaseInsertStatus.createdNew,
        );
      }

      await _databaseTable.update(
        await _database,
        chat.toMapForDatabase(),
        finder: _finder,
      );
      print("Updating previous chat");
      if (!chat.isSynced) {
        //i.e. created by user
        numberOfChatsAdded += 1;
        if (numberOfChatsAdded >= FirebaseRConfigHandler.chatsPerAd) {
          (MyNavigator.context!)
              .read<AdsHandlerCubit>()
              .performActionBasedOnLoginState();
          numberOfChatsAdded = 0;
        }
      }
      return OperationStatus(
        returnStatus: ReturnStatus.success,
        databaseInsertStatus: DatabaseInsertStatus.updatedValue,
      );
    } catch (exception) {
      print("insertOrUpdateChat exception: $exception");
      return OperationStatus(
        returnStatus: ReturnStatus.success,
        databaseInsertStatus: DatabaseInsertStatus.updatedValue,
      );
    }
  }

  // Future addNewChatMessageNew(Chat chatMessageToAdd) async {
  //   // await _databaseTable.add(await _database, value);
  //   // (await _database).transaction((transaction) async {
  //   await _databaseTable.add(
  //     await _database,
  //     chatMessageToAdd.toMapForDatabase(),
  //   );
  //   // });
  // }
}
