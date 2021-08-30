import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/data/data_providers/chats_dao.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/chat.dart';
import 'package:protasks/data/models/group.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/cubit/root_cubits/side_drawer_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/sync_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/sync_queues_cubit.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:protasks/logic/my_navigator.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/timestamp.dart' as sembast;
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO: On adding group, make a temporary user to show to the current user, with updatedOn as invalid
// TODO: For the downloadUserFunction, search for the UIDs which are older than two days before
// TODO: I don't think we need a download stream
// TODO: For the upload stream, upload when isSynced == false, and uid == currentUser.uid

class FirebaseFstoreFunctions {
  static FirebaseFirestore get _instance => FirebaseFirestore.instance;

  static const String groupCollectionName = "groups";
  static const String taskCollectionName = "tasks";
  static const String chatCollectionName = "chats";
  static const String usersCollectionName = "users";

  static Map<String, String> taskIdToGroupId = {};

  // static final RegExp _regExp = RegExp(r".*\/([A-z0-9]*)\/[a-z]*\/([A-z0-9]*)");

  static List<String> groupIdList = [];

  Future<bool> fetchAllTasksOfGroup() async {
    return true;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getRealTimeLatestGroupUpdateFromCloud(
          {required DateTime lastUpdatedTime}) async* {
    yield* _instance
        .collection(groupCollectionName)
        .where(
          'members',
          arrayContains: FirebaseAuthFunctions.getCurrentUser!.uid,
        )
        .where(
          'updatedOn',
          isGreaterThanOrEqualTo: Timestamp.fromDate(lastUpdatedTime),
        )
        .orderBy('updatedOn', descending: true)
        .limit(1)
        .snapshots(includeMetadataChanges: true);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getRealTimeLatestTaskUpdateFromCloud({
    required DateTime lastUpdatedTime,
  }) async* {
    if (groupIdList.isEmpty) {
      groupIdList =
          (await GroupsDao().findAllGroups().first).map((e) => e.id).toList();
      print("Group ID list: $groupIdList");
    }
    int _groupListLength = groupIdList.length;

    List<Stream<QuerySnapshot<Map<String, dynamic>>>> _listOfStream = [];

    for (int i = 0; i < _groupListLength / 10; i++) {
      // ? Why 10?
      // * Because firestore supports upto 10 in "whereIn" query, so we divide our list by 10
      int startIndex = 10 * i;
      int endIndex =
          _groupListLength - startIndex > 10 ? 10 * (i + 1) : _groupListLength;
      final _subGroupList = groupIdList.sublist(startIndex, endIndex);

      _listOfStream.add(_instance
          .collectionGroup(taskCollectionName)
          .orderBy('modifiedOn', descending: true)
          .where(
            'groupId',
            whereIn: _subGroupList,
          )
          .where(
            'modifiedOn',
            isGreaterThanOrEqualTo: Timestamp.fromDate(lastUpdatedTime),
          )
          .limit(1)
          .snapshots(
              // includeMetadataChanges: true
              ));
    }

    yield* Rx.merge(_listOfStream);
  }

  Future<List<Person>> findEmailOnCloud(String searchQuery) async {
    List<Person> _listToReturn = [];
    if (searchQuery.isValidEmail) {
      final querySnapshot = await _instance
          .collection(usersCollectionName)
          .where(
            'email',
            isEqualTo: searchQuery,
          )
          .limit(1)
          .get();

      print("querySnapshot.length: ${querySnapshot.size}");

      querySnapshot.docs.forEach((docSnapshot) {
        if (docSnapshot.id != FirebaseAuthFunctions.getCurrentUser!.uid) {
          Map<String, dynamic> userMap = Map.from(docSnapshot.data());
          print("UserMap: $userMap");
          userMap['updatedOn'] = sembast.Timestamp.fromDateTime(
            (userMap['updatedOn'] as Timestamp).toDate(),
          );

          Person toInsert = Person.fromMapOfDatabase(
            userMap
              ..['uid'] = docSnapshot.id
              // ..['updatedOn'] = DateTime.now()
              ..['isSynced'] = true,
          );

          print("ToInsert: $toInsert");

          _listToReturn.add(toInsert);
        }
      });
    }
    return _listToReturn;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getRealTimeLatestChatUpdateFromCloud(
          {required DateTime lastUpdatedTime}) async* {
    if (groupIdList.isEmpty) {
      groupIdList =
          (await GroupsDao().findAllGroups().first).map((e) => e.id).toList();
      print("Group ID list: $groupIdList");
    }
    int _groupListLength = groupIdList.length;

    List<Stream<QuerySnapshot<Map<String, dynamic>>>> _listOfStream = [];

    for (int i = 0; i < _groupListLength / 10; i++) {
      // ? Why 10?
      // * Because firestore supports upto 10 in "whereIn" query, so we divide our list by 10
      int startIndex = 10 * i;
      int endIndex =
          _groupListLength - startIndex > 10 ? 10 * (i + 1) : _groupListLength;
      final _subGroupList = groupIdList.sublist(startIndex, endIndex);

      _listOfStream.add(
        _instance
            .collectionGroup(chatCollectionName)
            .where(
              'groupId',
              whereIn: _subGroupList,
            )
            .where(
              'time',
              isGreaterThanOrEqualTo: Timestamp.fromDate(lastUpdatedTime),
            )
            .orderBy('time', descending: true)
            .limit(4)
            .snapshots(
                // includeMetadataChanges: true
                ),
      );
    }

    yield* Rx.merge(_listOfStream);
  }

  Future<bool> groupQuerySnapshotHandler(
    QuerySnapshot<Map<String, dynamic>> querySnapshot,
  ) async {
    try {
      print("querySnapshot.length : ${querySnapshot.size}");

      print("Got the groups from server, now updating local db");

      for (final queryDocSnapshot in querySnapshot.docs) {
        print(
            "for group queryDocSnapshot:-\n id: ${queryDocSnapshot.id} \n path: ${queryDocSnapshot.reference.path} \n data: ${queryDocSnapshot.data()}");

        Map<String, dynamic> groupMap = Map.from(queryDocSnapshot.data());
        groupMap['createdOn'] = sembast.Timestamp.fromDateTime(
          (groupMap['createdOn'] as Timestamp).toDate(),
        );
        if (groupMap['updatedOn'] == null) {
          groupMap['updatedOn'] = sembast.Timestamp.now();
        } else {
          groupMap['updatedOn'] = sembast.Timestamp.fromDateTime(
            (groupMap['updatedOn'] as Timestamp).toDate(),
          );
        }

        // groupMap['updatedOn'] = (groupMap['updatedOn'] as Timestamp).toDate();
        print("groupMap : $groupMap ");

        final insertStatus = await GroupsDao().insertOrUpdateGroups(
          Group.fromMapFromDatabase(
            groupMap
              ..['id'] = queryDocSnapshot.id
              ..['isSynced'] = true,
          ),
        );
        if (insertStatus.returnStatus == ReturnStatus.success) {
          List<String> _membersList =
              (groupMap['members'] as List).map((e) => e.toString()).toList();
          print("for memberList in group: $_membersList");
          UsersDao _usersDao = UsersDao();
          // _membersList.forEach((memberUID) async {
          for (final memberUID in _membersList) {
            if (await _usersDao.getUserFromUserID(userIDtoSearch: memberUID) ==
                null) {
              // Adding a temporary user so that we have something to show the current user
              await _usersDao.insertOrUpdateUser(
                Person(
                  uid: memberUID,
                  name: "Unknown User",
                  updatedOn: DateTimeExtensions.invalid,
                  isSynced: false,
                ),
              );
            }
          }
        }
        if (insertStatus.databaseInsertStatus ==
                DatabaseInsertStatus.createdNew &&
            (MyNavigator.context!).read<SyncCubit>().state.lastTaskSyncTime !=
                DateTimeExtensions.invalid) {
          print("New group found, fetching old tasks");
          (MyNavigator.context!).read<SyncQueuesCubit>().addItemToQueue(
                groupId: queryDocSnapshot.id,
              );
        }
      }
      return true;
    } catch (exception) {
      print("groupQuerySnapshotHandler exception: $exception");
      return false;
    }
  }

  Future<bool> downloadGroupUpdatesFromCloud({
    required DateTime lastUpdatedTime,
  }) async {
    try {
      final querySnapshot = await _instance
          .collection(groupCollectionName)
          .where(
            'members',
            arrayContains: FirebaseAuthFunctions.getCurrentUser!.uid,
          )
          .where(
            'updatedOn',
            isGreaterThanOrEqualTo: Timestamp.fromDate(lastUpdatedTime),
          )
          .orderBy('updatedOn', descending: true)
          // .limit(5)
          .get(GetOptions(source: Source.server));

      await groupQuerySnapshotHandler(querySnapshot);
      return true;
    } catch (exception) {
      print("downloadGroupUpdatesFromCloud exception: $exception");
      return false;
    }
  }

  Future<bool> taskQuerySnapshotHandler(
    QuerySnapshot<Map<String, dynamic>> querySnapshot,
  ) async {
    try {
      print("querySnapshot.length : ${querySnapshot.size}");

      print("Got the tasks from server, now updating local db");

      for (final queryDocSnapshot in querySnapshot.docs) {
        print(
            "for task queryDocSnapshot:-\n id: ${queryDocSnapshot.id} \n path: ${queryDocSnapshot.reference.path} \n data: ${queryDocSnapshot.data()}");

        Map<String, dynamic> taskMap = Map.from(queryDocSnapshot.data());
        taskMap['time'] = sembast.Timestamp.fromDateTime(
          (taskMap['time'] as Timestamp).toDate(),
        );

        taskMap['recursionTill'] = sembast.Timestamp.fromDateTime(
          (taskMap['recursionTill'] as Timestamp).toDate(),
        );

        taskMap['createdOn'] = sembast.Timestamp.fromDateTime(
          (taskMap['createdOn'] as Timestamp).toDate(),
        );

        if (taskMap['modifiedOn'] == null) {
          taskMap['modifiedOn'] = sembast.Timestamp.now();
        } else {
          taskMap['modifiedOn'] = sembast.Timestamp.fromDateTime(
            (taskMap['modifiedOn'] as Timestamp).toDate(),
          );
        }

        // final match = _regExp.firstMatch(queryDocSnapshot.reference.path);

        // if (match == null) {
        //   continue;
        // }

        // if (match.groupCount != 2) {
        //   // groups should be -> [full path, parentId, queryDocSnapshot.id]
        //   continue;
        // }

        // String groupId = match.group(1)!;

        final operationStatus = await TasksDao().insertOrUpdateTask(
          Task.fromMapOfDatabase(
            taskMap
              ..['id'] = queryDocSnapshot.id
              // ..['groupId'] = groupId
              // ! Initially created db thinking to use firestore rules as filter
              // ! (Firestore doesn't support that)
              // ..['isDeleted'] = false
              ..['isSynced'] = true,
          ),
        );

        List<String> _membersList =
            (taskMap['assignedTo'] as List).map((e) => e.toString()).toList();
        _membersList.add(taskMap['modifiedBy']);
        _membersList.add(taskMap['createdBy']);
        print("for memberList in task: $_membersList");
        UsersDao _usersDao = UsersDao();
        // _membersList.forEach((memberUID) async {
        for (final memberUID in _membersList) {
          if (await _usersDao.getUserFromUserID(userIDtoSearch: memberUID) ==
              null) {
            // Adding a temporary user so that we have something to show the current user
            await _usersDao.insertOrUpdateUser(
              Person(
                uid: memberUID,
                name: "Unknown User",
                updatedOn: DateTimeExtensions.invalid,
                isSynced: false,
              ),
            );
          }
        }

        if (operationStatus.databaseInsertStatus ==
                DatabaseInsertStatus.createdNew &&
            (MyNavigator.context!).read<SyncCubit>().state.lastChatSyncTime !=
                DateTimeExtensions.invalid) {
          print("New task found, fetching old chats");
          (MyNavigator.context!).read<SyncQueuesCubit>().addItemToQueue(
                taskId: queryDocSnapshot.id,
              );
        }

        // print("taskMap : $taskMap ");
      }
      return true;
    } catch (exception) {
      print("taskQuerySnapshotHandler exception: $exception");
      return false;
    }
  }

  Future<bool> downloadTaskUpdatesFromCloudOneByOne({
    required DateTime lastUpdatedTime,
    List<String>? listOfGroupsToFetchFrom,
  }) async {
    print(
        "downloadTaskUpdatesFromCloudOneByOne called with listOfGroupsToFetchFrom:\n $listOfGroupsToFetchFrom ");
    if (listOfGroupsToFetchFrom == null) {
      listOfGroupsToFetchFrom = List.from(groupIdList);
      if (listOfGroupsToFetchFrom.isEmpty) {
        print("listOfGroupsToFetchFrom List is empty");
        listOfGroupsToFetchFrom =
            (await GroupsDao().findAllGroups().first).map((e) => e.id).toList();
        print("listOfGroupsToFetchFrom ID list: $listOfGroupsToFetchFrom");
      }
    }
    // for (final groupId in listOfGroupsToFetchFrom) {
    for (int index = 0; index < listOfGroupsToFetchFrom.length; index++) {
      final groupId = listOfGroupsToFetchFrom.elementAt(index);
      try {
        final querySnapshot = await _instance
            //  .collection(taskCollectionName)
            .collectionGroup(taskCollectionName)
            .where(
              'modifiedOn',
              isGreaterThanOrEqualTo: Timestamp.fromDate(lastUpdatedTime),
            )
            .where(
              'groupId',
              // whereIn: [
              //   'fA4d18696F50D84b4f06D01F5284aF',
              //   'd50Ed11eb2665897f85eF5b78491c0',
              // ],
              // whereIn: List<String>.from(_subGroupList),
              // whereIn: _subGroupList,
              isEqualTo: groupId,
            )
            .orderBy('modifiedOn', descending: true)
            .get(GetOptions(source: Source.server));
        bool wasAbleToSave = await taskQuerySnapshotHandler(querySnapshot);
        if (!wasAbleToSave) {
          return wasAbleToSave;
        }
      } on FirebaseException catch (firebaseException) {
        if (firebaseException.plugin == 'cloud_firestore' &&
            firebaseException.code == 'permission-denied') {
          // This shall happen only if you are no longer part of the groupId which
          // you are referring to, so DELETE the group
          await GroupsDao().leaveFromGroup(groupId: groupId);
          (MyNavigator.context!).read<SyncCubit>().reinitialize();
          (MyNavigator.context!).read<SideDrawerCubit>().reinitialize();
          // groupIdList.removeWhere((element) => element == groupId);
          // listOfGroupsToFetchFrom.removeWhere((element) => element == groupId);
          // if((MyNavigator.context!).read<SideDrawerCubit>().state.selectID == groupId){

          // }
          String selectedId =
              (MyNavigator.context!).read<SideDrawerCubit>().state.selectID;

          if (selectedId == groupId) {
            Navigator.of((MyNavigator.context!)).pushNamedAndRemoveUntil(
              AppRouter.dashboard,
              (route) => true,
            );
          }
          continue;
        } else {
          throw firebaseException;
        }
      } catch (exception) {
        throw exception;
      }
    }
    return true;
  }

  Future<bool> downloadTaskUpdatesFromCloud({
    required DateTime lastUpdatedTime,
  }) async {
    print("downloadTaskUpdatesFromCloud lastUpdatedTime: $lastUpdatedTime");
    try {
      if (groupIdList.isEmpty) {
        print("Group List is empty");
        groupIdList =
            (await GroupsDao().findAllGroups().first).map((e) => e.id).toList();
        print("Group ID list: $groupIdList");
      }

      int _groupListLength = groupIdList.length;

      for (int i = 0; i < _groupListLength / 10; i++) {
        // ? Why 10?
        // * Because firestore supports upto 10 in "whereIn" query, so we divide our list by 10
        int startIndex = 10 * i;
        int endIndex = _groupListLength - startIndex > 10
            ? 10 * (i + 1)
            : _groupListLength;
        final _subGroupList = groupIdList.sublist(startIndex, endIndex);
        // _subGroupList.removeAt(0);

        try {
          final querySnapshot = await _instance
              //  .collection(taskCollectionName)
              .collectionGroup(taskCollectionName)
              .where(
                'modifiedOn',
                isGreaterThanOrEqualTo: Timestamp.fromDate(lastUpdatedTime),
              )
              .where(
                'groupId',
                // whereIn: [
                //   'fA4d18696F50D84b4f06D01F5284aF',
                //   'd50Ed11eb2665897f85eF5b78491c0',
                // ],
                // whereIn: List<String>.from(_subGroupList),
                whereIn: _subGroupList,
                // isEqualTo: 'fA4d18696F50D84b4f06D01F5284aF',
              )
              .orderBy('modifiedOn', descending: true)
              .get(GetOptions(source: Source.server));
          bool wasAbleToSave = await taskQuerySnapshotHandler(querySnapshot);
          if (!wasAbleToSave) {
            return wasAbleToSave;
          }
        } on FirebaseException catch (firebaseException) {
          print('''
          FirebaseException: $firebaseException\n
          firebaseException.code: ${firebaseException.code}\n
          firebaseException.message: ${firebaseException.message}\n
          firebaseException.plugin: ${firebaseException.plugin}\n
          firebaseException.runtimeType: ${firebaseException.runtimeType}\n
          firebaseException.stackTrace: ${firebaseException.stackTrace}\n
          ''');
          if (firebaseException.plugin == 'cloud_firestore' &&
              firebaseException.code == 'permission-denied') {
            bool wasAbleToSave = await downloadTaskUpdatesFromCloudOneByOne(
              lastUpdatedTime: lastUpdatedTime,
              listOfGroupsToFetchFrom: _subGroupList,
            );
            if (!wasAbleToSave) {
              return wasAbleToSave;
            }
          } else {
            throw firebaseException;
          }
        }
      }
      return true;
    } catch (exception) {
      print("exception type: ${exception.runtimeType}");
      print("downloadTaskUpdatesFromCloud exception: $exception");
      groupIdList.clear();
      return false;
    }
  }

  Future<bool> chatQuerySnapshotHandler(
    QuerySnapshot<Map<String, dynamic>> querySnapshot,
  ) async {
    try {
      print("querySnapshot.length : ${querySnapshot.size}");

      print("Got the chats from server, now updating local db");

      for (final queryDocSnapshot in querySnapshot.docs) {
        print(
            "for chat queryDocSnapshot:-\n id: ${queryDocSnapshot.id} \n path: ${queryDocSnapshot.reference.path} \n data: ${queryDocSnapshot.data()}");

        Map<String, dynamic> chatMap = Map.from(queryDocSnapshot.data());
        // print("chatMap['time'] ")
        if (chatMap['time'] == null) {
          chatMap['time'] = sembast.Timestamp.now();
        } else {
          chatMap['time'] = sembast.Timestamp.fromDateTime(
            (chatMap['time'] as Timestamp).toDate(),
          );
        }

        // final match = _regExp.firstMatch(queryDocSnapshot.reference.path);

        // if (match == null) {
        //   continue;
        // }

        // if (match.groupCount != 2) {
        //   // groups should be -> [full path, parentId, queryDocSnapshot.id]
        //   continue;
        // }

        // String refId = match.group(1)!;

        taskIdToGroupId[chatMap['refId']] = chatMap['groupId'];
        // Because refID is essentially a taskId

        await ChatsDao().insertOrUpdateChat(
          Chat.fromMapOfDatabase(
            chatMap
              ..remove('groupId')
              // This was added to query online data

              ..['id'] = queryDocSnapshot.id
              ..['isSeen'] = false
              // ..['refId'] = refId
              // ! Initially created db thinking to use firestore rules as filter
              // ! (Firestore doesn't support that)
              ..['isDeleted'] = false
              ..['isSynced'] = true,
          ),
        );

        // print("taskMap : $taskMap ");
      }
      return true;
    } catch (exception) {
      print("chatQuerySnapshotHandler exception: $exception");
      return false;
    }
  }

  Future<bool> downloadChatUpdatesFromCloudOneByOne({
    required DateTime lastUpdatedTime,
    required List<String> listOfTasksToFetchFrom,
  }) async {
    print(
        "downloadChatUpdatesFromCloudOneByOne called with listOfTasksToFetchFrom:\n $listOfTasksToFetchFrom");

    // if (listOfTasksToFetchFrom == null) {
    //   listOfTasksToFetchFrom = List.from(groupIdList);
    //   if (listOfTasksToFetchFrom.isEmpty) {
    //     print("listOfTasksToFetchFrom List is empty");
    if (groupIdList.isEmpty) {
      groupIdList =
          (await GroupsDao().findAllGroups().first).map((e) => e.id).toList();
      print("Group ID list: $groupIdList");
    }
    //   }
    // }

    // for (final groupId in listOfTasksToFetchFrom) {
    for (int index = 0; index < listOfTasksToFetchFrom.length; index++) {
      final taskId = listOfTasksToFetchFrom.elementAt(index);
      print("For taskId: $taskId, getting chats");
      try {
        final querySnapshot = await _instance
            //  .collection(taskCollectionName)
            .collectionGroup(chatCollectionName)
            .where(
              'refId',
              // whereIn: [
              //   'fA4d18696F50D84b4f06D01F5284aF',
              //   'd50Ed11eb2665897f85eF5b78491c0',
              // ],
              // whereIn: List<String>.from(_subGroupList),
              // whereIn: [taskId],
              isEqualTo: taskId,
            )
            .where(
              'groupId',
              whereIn: groupIdList,
            )
            .where(
              'time',
              isGreaterThanOrEqualTo: Timestamp.fromDate(lastUpdatedTime),
            )
            .orderBy('time', descending: true)
            .get(GetOptions(source: Source.server));

        print("got the chat for taskId: $taskId");
        bool wasAbleToSave = await chatQuerySnapshotHandler(querySnapshot);
        if (!wasAbleToSave) {
          return wasAbleToSave;
        }
      }
      // on FirebaseException catch (firebaseException) {
      //   if (firebaseException.plugin == 'cloud_firestore' &&
      //       firebaseException.code == 'permission-denied') {
      //     // This shall happen only if you are no longer part of the groupId which
      //     // you are referring to, so DELETE the group
      //     // await GroupsDao().leaveFromGroup(groupId: taskId);
      //     // (MyNavigator.context!).read<SyncCubit>().reinitialize();
      //     // (MyNavigator.context!).read<SideDrawerCubit>().reinitialize();
      //     // groupIdList.removeWhere((element) => element == groupId);
      //     // listOfTasksToFetchFrom.removeWhere((element) => element == groupId);
      //     // if((MyNavigator.context!).read<SideDrawerCubit>().state.selectID == groupId){

      //     // }
      //     // String selectedId =
      //     //     (MyNavigator.context!).read<SideDrawerCubit>().state.selectID;

      //     // if (selectedId == taskId) {
      //     //   Navigator.of((MyNavigator.context!)).pushNamedAndRemoveUntil(
      //     //     AppRouter.dashboard,
      //     //     (route) => true,
      //     //   );
      //     // }
      //     continue;
      //   } else {
      //     throw firebaseException;
      //   }
      // }
      catch (exception) {
        throw exception;
      }
    }
    return true;
  }

  Future<bool> downloadChatUpdatesFromCloud({
    required DateTime lastUpdatedTime,
  }) async {
    try {
      // List TasksDao().getAllTasks()

      if (groupIdList.isEmpty) {
        groupIdList =
            (await GroupsDao().findAllGroups().first).map((e) => e.id).toList();
        print("Group ID list: $groupIdList");
      }
      int _groupListLength = groupIdList.length;

      for (int i = 0; i < _groupListLength / 10; i++) {
        // ? Why 10?
        // * Because firestore supports upto 10 in "whereIn" query, so we divide our list by 10
        int startIndex = 10 * i;
        int endIndex = _groupListLength - startIndex > 10
            ? 10 * (i + 1)
            : _groupListLength;
        final _subGroupList = groupIdList.sublist(startIndex, endIndex);
        // _subGroupList.removeAt(0);

        final querySnapshot = await _instance
            .collectionGroup(chatCollectionName)
            .where(
              'time',
              isGreaterThanOrEqualTo: Timestamp.fromDate(lastUpdatedTime),
            )
            .where('groupId', whereIn: _subGroupList)
            .orderBy('time', descending: true)
            .get(GetOptions(source: Source.server));

        bool wasAbleToSave = await chatQuerySnapshotHandler(querySnapshot);
        if (!wasAbleToSave) {
          return wasAbleToSave;
        }
      }

      return true;
    } catch (exception) {
      print(exception);
      // if (exception.toString() ==
      //     "[cloud_firestore/failed-precondition] Operation was rejected because the system is not in a state required for the operation's execution. If performing a query, ensure it has been indexed via the Firebase console.") {
      //   return true;
      // }
      print("downloadChatUpdatesFromCloud exception: $exception");
      return false;
    }
  }

  Future<bool> userDocumentSnapshotHandler(
      DocumentSnapshot<Map<String, dynamic>> docSnapshot) async {
    try {
      print("userMap: ${docSnapshot.data()}");
      Map<String, dynamic> userMap = Map.from(docSnapshot.data()!);
      // userMap['updatedOn'] = sembast.Timestamp.fromDateTime(
      //   (userMap['updatedOn'] as Timestamp).toDate(),
      // );

      Person toInsert = Person.fromMapOfDatabase(
        userMap
          ..['uid'] = docSnapshot.id
          ..['updatedOn'] = sembast.Timestamp.now()
          ..['isSynced'] = true,
      );

      await UsersDao().insertOrUpdateUser(toInsert);

      return true;
    } catch (exception) {
      print("userDocumentSnapshotHandler exception: $exception");
      return false;
    }
  }

  // Future<bool> userQuerySnapshotHandler(
  //   QuerySnapshot<Map<String, dynamic>> querySnapshot,
  // ) async {
  //   try {
  //     print("querySnapshot.length : ${querySnapshot.size}");

  //     print("Got the users from server, now updating local db");

  //     for (final queryDocSnapshot in querySnapshot.docs) {
  //       print(
  //           "for chat queryDocSnapshot:-\n id: ${queryDocSnapshot.id} \n path: ${queryDocSnapshot.reference.path} \n data: ${queryDocSnapshot.data()}");

  //       Map<String, dynamic> userMap = Map.from(queryDocSnapshot.data());
  //       userMap['updatedOn'] = sembast.Timestamp.fromDateTime(
  //         (userMap['updatedOn'] as Timestamp).toDate(),
  //       );

  //       // await ChatsDao().insertOrUpdateChat(
  //       //   Chat.fromMapOfDatabase(
  //       //     userMap
  //       //       ..remove('groupId')
  //       //       // This was added to query online data

  //       //       ..['id'] = queryDocSnapshot.id
  //       //       ..['isSeen'] = false
  //       //       // ..['refId'] = refId
  //       //       // ! Initially created db thinking to use firestore rules as filter
  //       //       // ! (Firestore doesn't support that)
  //       //       ..['isSynced'] = true,
  //       //   ),
  //       // );

  //       await UsersDao().insertOrUpdateUser(
  //         Person.fromMapOfDatabase(
  //           userMap
  //             ..['updatedOn'] = DateTime.now()
  //             ..['isSynced'] = true,
  //         ),
  //       );

  //       // print("taskMap : $taskMap ");
  //     }
  //     return true;
  //   } catch (exception) {
  //     print("chatQuerySnapshotHandler exception: $exception");
  //     return false;
  //   }
  // }

  Future<bool> downloadUserUpdateFromCloud(String userUID) async {
    try {
      final docSnapshot =
          await _instance.collection(usersCollectionName).doc(userUID).get();

      return (await userDocumentSnapshotHandler(docSnapshot));
    } catch (exception) {
      print("downloadUserUpdateFromCloud exception: $exception");
      return false;
    }
  }

  Future<bool> downloadUsersUpdatesFromCloud() async {
    try {
      List<String> _userIdList = [];

      (await UsersDao().getUsersToBeDownloaded()).forEach((user) {
        _userIdList.add(user.uid);
      });

      int _userLength = _userIdList.length;
      print("getUsersToBeDownloaded length: $_userLength");

      for (int i = 0; i < _userLength; i++) {
        final docSnapshot = await _instance
            .collection(usersCollectionName)
            .doc(_userIdList.elementAt(i))
            // .where('uid', whereIn: _subUserIdList)
            // .orderBy('updatedOn', descending: true)
            .get();

        if (docSnapshot.exists) {
          bool wasAbleToSave = (await userDocumentSnapshotHandler(docSnapshot));
          if (!wasAbleToSave) {
            return wasAbleToSave;
          }
        }
      }

      return true;
    } catch (exception) {
      print("downloadUserUpdatesFromCloud exception: $exception");
      return false;
    }
  }

  Future<bool> uploadTaskToCloud(Task taskToUpload) async {
    try {
      taskIdToGroupId[taskToUpload.id] = taskToUpload.groupId;
      await _instance
          .collection(groupCollectionName)
          .doc(taskToUpload.groupId)
          .collection(taskCollectionName)
          .doc(taskToUpload.id)
          .set(
            taskToUpload.toMapForDatabase()
              // ..remove('groupId')
              // ! Initially created db thinking to use firestore rules as filter
              // ! (Firestore doesn't support that)
              ..remove('id')
              ..remove('isSynced')
              ..remove(
                  'recursionTill') // for some reason, not accepting without removing
              ..['time'] = taskToUpload.time.toUtc()
              ..['createdOn'] = taskToUpload.createdOn.toUtc()
              ..['recursionTill'] = taskToUpload.recursionTill.toUtc()
              ..['modifiedBy'] = FirebaseAuthFunctions.getCurrentUser!.uid
              ..['modifiedOn'] = FieldValue.serverTimestamp(),
            SetOptions(merge: true),
          );

      print("Task uploaded to cloud");

      await TasksDao().insertOrUpdateTask(
        taskToUpload.copyWith(
          modifiedOn: DateTime.now(),
          isSynced: true,
        ),
      );
      print("Task updated in db local");

      return true;
    } catch (exception) {
      print("uploadTaskToCloud exception: $exception");
      return false;
    }
  }

  Future<bool> uploadGroupToCloud(Group groupToUpload) async {
    try {
      await _instance.collection(groupCollectionName).doc(groupToUpload.id).set(
            groupToUpload.toMapForDatabase()
              ..remove('id')
              ..remove('isSynced')
              ..['createdOn'] = groupToUpload.createdOn.toUtc()
              ..['updatedOn'] = FieldValue.serverTimestamp(),
            SetOptions(merge: true),
          );

      print("Group Uploaded");

      await GroupsDao().insertOrUpdateGroups(groupToUpload.copyWith(
        isSynced: true,
      ));

      print("local group db updated");
      return true;
    } catch (exception) {
      print("Group exception: $exception");
      return false;
    }
  }

  Future<bool> uploadPersonToCloud(Person personToUpload) async {
    try {
      await _instance
          .collection(usersCollectionName)
          .doc(personToUpload.uid)
          .set(
            personToUpload.toMapForDatabase()
              ..remove('uid')
              ..remove('isSynced')
              ..['updatedOn'] = FieldValue.serverTimestamp(),
            SetOptions(merge: true),
          );

      await UsersDao().insertOrUpdateUser(personToUpload.copyWith(
        updatedOn: DateTime.now(),
        isSynced: true,
      ));

      return true;
    } catch (exception) {
      print(
          "uploadPersonToCloud exception: $exception, person: $personToUpload ");
      return false;
    }
  }

  Future<bool> uploadChatToCloud(Chat chatToUpload) async {
    try {
      String? groupId = taskIdToGroupId[chatToUpload.refId];
      if (groupId == null) {
        final task = await TasksDao()
            .getSingleTaskDetailsStream(taskId: chatToUpload.refId)
            .first;
        if (task == null) {
          return false;
        }
        groupId = task.groupId;
        taskIdToGroupId[chatToUpload.refId] = groupId;
      }

      print("Chat to Upload: $chatToUpload");

      await _instance
          .collection(groupCollectionName)
          .doc(groupId)
          .collection(taskCollectionName)
          .doc(chatToUpload.refId)
          .collection(chatCollectionName)
          .doc(chatToUpload.id)
          .set(
              chatToUpload.toMapForDatabase()
                ..remove('id')
                ..remove('isSeen')
                ..remove('time')
                // ..remove('refId')
                // ! Initially created db thinking to use firestore rules as filter
                // ! (Firestore doesn't support that)

                ..remove('isSynced')
                ..['groupId'] = groupId
                // This additional parameter is meant for online db,
                // to make querying possible

                ..['time'] = FieldValue.serverTimestamp(),
              SetOptions(
                merge: false,
              ));

      await ChatsDao().insertOrUpdateChat(chatToUpload.copyWith(
        isSynced: true,
        time: DateTime.now(),
      ));

      return true;
    } catch (exception) {
      print("uploadChatToCloud exception: $exception");
      return false;
    }
  }
}
