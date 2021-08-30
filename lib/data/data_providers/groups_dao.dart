import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/operation_status.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/data_providers/app_database.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/group.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/cubit/root_cubits/ads_handler_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/sync_cubit.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:protasks/logic/firebase_rconfig_handler.dart';
import 'package:protasks/logic/my_navigator.dart';
import 'package:sembast/sembast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupsDao {
  static const String tableName = 'groups';
  final _databaseTable = intMapStoreFactory.store(tableName);

  Future<Database> get _database async => await AppDatabase.instance.database;

  static Map<String, String?> groupIdToName = {};

  static Map<String, List<String>?> groupIdToMembersUID = {};

  Stream<List<Group>> getAllGroupsToBeUploaded({int? limit}) async* {
    final _queryRef = _databaseTable.query(
      finder: Finder(
        filter: Filter.equals('isSynced', false),
        limit: limit,
      ),
    );

    yield* _queryRef.onSnapshots(await _database).map(
        (listOfRecordSnapshots) => listOfRecordSnapshots.map((recordSnapshot) {
              print("Group to upload: ${recordSnapshot.value}");
              return Group.fromMapFromDatabase(recordSnapshot.value);
            }).toList());
  }

  Future<void> updateAllGroupsWithNewUserInfo() async {
    String? newUserUID = FirebaseAuthFunctions.getCurrentUser?.uid;
    if (newUserUID == null) {
      return;
    }
    List<Group> groupList = await findAllGroups().first;
    groupList.forEach((eachGroup) {
      if (eachGroup.admins.contains(Strings.defaultUserUID)) {
        eachGroup.admins.remove(Strings.defaultUserUID);
        eachGroup.admins.add(newUserUID);
      }

      eachGroup.members.remove(Strings.defaultUserUID);
      eachGroup.members.add(newUserUID);

      insertOrUpdateGroups(eachGroup);
    });
  }

  static int numberOfGroupsAdded = 0;

  Future<OperationStatus> insertOrUpdateGroups(Group group) async {
    print("Task is synced: ${group.isSynced}");
    print(
        "lastGroupSyncTime : ${MyNavigator.context!.read<SyncCubit>().state.lastGroupSyncTime}");
    print(
        "lastGroupSyncTime != DateTimeExtensions.invalid : ${MyNavigator.context!.read<SyncCubit>().state.lastGroupSyncTime != DateTimeExtensions.invalid}");

    Finder _finder = Finder(filter: Filter.equals('id', group.id));
    try {
      final _recordSnapshot =
          await _databaseTable.findFirst(await _database, finder: _finder);

      if (_recordSnapshot == null) {
        print("Creating new group with id ${group.id}");
        await _databaseTable.add(
          await _database,
          group.toMapForDatabase(),
        );
        if (!group.isSynced && //i.e. created by user
            MyNavigator.context!.read<SyncCubit>().state.lastGroupSyncTime !=
                DateTimeExtensions.invalid) {
          numberOfGroupsAdded += 1;
          if (numberOfGroupsAdded >= FirebaseRConfigHandler.groupsPerAd) {
            (MyNavigator.context!)
                .read<AdsHandlerCubit>()
                .performActionBasedOnLoginState();
            numberOfGroupsAdded = 0;
          }
        }
        return OperationStatus(
          returnStatus: ReturnStatus.success,
          databaseInsertStatus: DatabaseInsertStatus.createdNew,
        );
      }

      print("updating previous group with id ${group.id}");
      await _databaseTable.update(
        await _database,
        group.toMapForDatabase(),
        finder: _finder,
      );
      if (!group.isSynced) {
        //i.e. created by user
        numberOfGroupsAdded += 1;
        if (numberOfGroupsAdded >= FirebaseRConfigHandler.groupsPerAd) {
          (MyNavigator.context!)
              .read<AdsHandlerCubit>()
              .performActionBasedOnLoginState();
          numberOfGroupsAdded = 0;
        }
      }
      return OperationStatus(
        returnStatus: ReturnStatus.success,
        databaseInsertStatus: DatabaseInsertStatus.updatedValue,
      );
    } catch (exception) {
      print("insertOrUpdateGroups exception: $exception");
      return OperationStatus(
        returnStatus: ReturnStatus.failure,
        databaseInsertStatus: DatabaseInsertStatus.insertFailed,
      );
    }
  }

  Future removeGroup(Group group) async {
    Finder _finder = Finder(
      filter: Filter.equals('id', group.id),
      limit: 1,
    );

    await _databaseTable.delete(
      await _database,
      finder: _finder,
    );
  }

  Stream<Group?> findGroupById({required String groupID}) async* {
    // Finder _finder = Finder(
    //   filter: Filter.equals('id', groupID),
    //   limit: 1,
    // );

    // yield* _databaseTable
    //     .stream(await _database, filter: Filter.equals('id', groupID))
    //     .map(
    //       (recordSnapshot) => Group.fromMapFromDatabase(recordSnapshot.value),
    //     );

    yield* _databaseTable
        .query(
          finder: Finder(filter: Filter.equals('id', groupID)),
        )
        .onSnapshot(await _database)
        .map((recordSnapshot) {
      if (recordSnapshot != null) {
        return Group.fromMapFromDatabase(recordSnapshot.value);
      }
    });

    // RecordSnapshot<int, Map<String, dynamic>>? _groupRecordSnapshot =
    //     await _databaseTable.findFirst(await _database, finder: _finder);

    // if (_groupRecordSnapshot != null) {
    //   return Group.fromMapFromDatabase(_groupRecordSnapshot.value);
    // }
  }

  // ! NOT USED
  Future<List<Person>> getAllUsersFromGroupID({required String groupID}) async {
    List<Person> _listToReturn = [];
    UsersDao _usersDao = UsersDao();
    Group? groupToSearch = await findGroupById(groupID: groupID).first;
    if (groupToSearch != null) {
      groupToSearch.members.forEach((userID) async {
        Person? userToAdd =
            await _usersDao.getUserFromUserID(userIDtoSearch: userID);
        if (userToAdd != null) {
          _listToReturn.add(userToAdd);
        }
      });
    }
    return _listToReturn;
  }

  Future<bool> deleteLocalGroup({required String groupId}) async {
    try {
      await _databaseTable.delete(
        await _database,
        finder: Finder(
          filter: Filter.equals('id', groupId),
        ),
      );

      return true;
    } catch (exception) {
      print("deleteLocalGroup exception: $exception");
      return false;
    }
  }

  Future<void> leaveFromGroup({
    required String groupId,
  }) async {
    if (await deleteLocalGroup(groupId: groupId)) {
      await TasksDao().removeTasksDatabaseForGroup(groupId: groupId);
    }
  }

  // Future<void> trashOrRestoreGroup({
  //   required String groupID,
  //   required bool moveToTrash,
  // }) async {
  //   Finder _finder = Finder(filter: Filter.equals('id', groupID));

  //   await _databaseTable.update(
  //     await _database,
  //     {
  //       'isDeleted': moveToTrash,
  //     },
  //     finder: _finder,
  //   );

  //   // await TasksDao().trashOrRestoreAllGroupTasks(
  //   //   groupID: groupID,
  //   //   moveToTrash: moveToTrash,
  //   // );
  // }

  Future<bool> isGroupPresent(String groupID) async {
    Finder _finder = Finder(filter: Filter.equals('id', groupID));
    var _recordSnapshot = await _databaseTable.findFirst(
      await _database,
      finder: _finder,
    );

    if (_recordSnapshot == null) {
      return false;
    }

    return true;
  }

  // * USED IN current_group_cubit
  // TODO: Either sort the list here only based on parent and child here, otherwise will have to implement the logic seperately everytime
  Stream<List<Group>> findAllGroups({
    bool onlyParentGroups = false,
  }) async* {
    Finder _finder = Finder(
      filter: Filter.and(
        [
          if (onlyParentGroups)
            Filter.equals('parentGroupId', Strings.noGroupID),
          Filter.equals(
              'members',
              (FirebaseAuthFunctions.getCurrentUser?.uid ??
                  Strings.defaultUserUID),
              anyInList: true)
        ],
      ),
      sortOrders: [
        SortOrder('createdOn'),
      ],
    );
    yield* _databaseTable
        .query(finder: _finder)
        .onSnapshots(await _database)
        .map((event) {
      return event.map((groupSnapshot) {
        return Group.fromMapFromDatabase(groupSnapshot.value);
      }).toList();
    });
  }

  // * USED IN MODAL SHEET -------------------------------
  Future<String?> findGroupNameById(String groupId) async {
    Finder _finder = Finder(
      filter: Filter.equals('id', groupId),
      limit: 1,
    );

    if (groupIdToName[groupId] == null) {
      final _recordSnapshot =
          await _databaseTable.findFirst(await _database, finder: _finder);

      Map<String, Object?>? _groupMap = _recordSnapshot?.value;
      // print("Map: $_groupMap");
      // print("Name: ${_groupMap['name']}");
      // assert(_groupMap?['name'] != null, "Couldn't find the group");
      if (_groupMap?['name'] == null) {
        return null;
      }
      groupIdToName[groupId] = _groupMap?['name'].toString();
      return groupIdToName[groupId];
    }
    return groupIdToName[groupId];
  }
  // * ---------------------------------------------------

  // * USED IN MODAL SHEET -------------------------------
  Future<List<String>> getAllMemberNamesOfGroup(String groupID) async {
    List<String> listOfUIDs = [];
    if (groupIdToMembersUID[groupID] == null) {
      Finder _finder = Finder(
        filter: Filter.equals('id', groupID),
      );

      final recordSnapshot =
          await _databaseTable.findFirst(await _database, finder: _finder);

      if (recordSnapshot == null) {
        return [];
      }

      Map<String, dynamic> map = recordSnapshot.value;

      listOfUIDs = List<String>.from(map['members']);
      if (listOfUIDs.isEmpty) {
        return [];
      }
      groupIdToMembersUID[groupID] = listOfUIDs;
    }

    return await UsersDao().getUserNamesFromIDs(groupIdToMembersUID[groupID]!);
  }
  // * ---------------------------------------------------

}
