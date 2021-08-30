import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/data_providers/app_database.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

class UsersDao {
  static const String tableName = 'users';
  final _databaseTable = intMapStoreFactory.store(tableName);

  Future<Database> get _database async => await AppDatabase.instance.database;

  static Map<String, String?> usersIdToName = {};

  Future<void> insertOrUpdateUser(Person user) async {
    try {
      Finder _finder = Finder(filter: Filter.equals('uid', user.uid));
      final _recordSnapshot =
          await _databaseTable.findFirst(await _database, finder: _finder);

      if (_recordSnapshot == null) {
        await _databaseTable.add(
          await _database,
          user.toMapForDatabase(),
        );
        print("Creating new user: $user");
        return;
      }

      await _databaseTable.update(
        await _database,
        user.toMapForDatabase(),
        finder: _finder,
      );
      print("Updating old user: $user");
    } catch (exception) {
      print("insertOrUpdateUser exception: $exception");
      throw Exception("$exception");
    }
  }

  // Stream<List<Person>> getAllUsersToBeUploaded() async* {
  //   final _queryRef = _databaseTable.query(
  //     finder: Finder(filter: Filter.equals('isSynced', false)),
  //   );

  //   yield* _queryRef.onSnapshots(await _database).map((listOfRecordSnapshots) =>
  //       listOfRecordSnapshots
  //           .map((recordSnapshot) =>
  //               Person.fromMapOfDatabase(recordSnapshot.value))
  //           .toList());
  // }

  Stream<Person> getOldestPersonInLocalDatabase() async* {
    final _queryRef = _databaseTable.query(
      finder: Finder(
        sortOrders: [
          SortOrder(
            'updatedOn',
          ),
        ],
        limit: 1,
      ),
    );

    yield* _queryRef.onSnapshot(await _database).map(
        (recordSnapshot) => Person.fromMapOfDatabase(recordSnapshot!.value));
  }

  Future<List<Person>> getUsersToBeDownloaded() async {
    final _queryRef = _databaseTable.query(
      finder: Finder(
        filter: Filter.lessThanOrEquals(
          'updatedOn',
          Timestamp.fromDateTime(
            DateTime.now().toUtc().subtract(Duration(days: 2)),
          ),
        ),
      ),
    );

    final _recordSnapshotList = await _queryRef.getSnapshots(await _database);
    return _recordSnapshotList
        .map((_recordSnapshot) =>
            Person.fromMapOfDatabase(_recordSnapshot.value))
        .toList();
  }

  Stream<Person?> getUserToBeUploaded() async* {
    final _queryRef = _databaseTable.query(
      finder: Finder(
        filter: Filter.equals('isSynced', false) &
            Filter.equals('uid', FirebaseAuthFunctions.getCurrentUser!.uid),
      ),
    );

    yield* _queryRef.onSnapshot(await _database).map((recordSnapshot) {
      if (recordSnapshot == null) {
        return null;
      }
      return Person.fromMapOfDatabase(recordSnapshot.value);
    });
  }

  Stream<List<Person>> getAllUsersStored() async* {
    final queryRef = _databaseTable.query();
    yield* queryRef.onSnapshots(await _database).map((recordSnapshots) =>
        recordSnapshots
            .map((singleRecordSnapshot) =>
                Person.fromMapOfDatabase(singleRecordSnapshot.value))
            .toList());
  }

  Future<void> updateDefaultUserWithNewUserInfo() async {
    // Person toUpdateWith = await getCurrentUser();
    final user = FirebaseAuthFunctions.getCurrentUser;
    // if (toUpdateWith.uid == Strings.defaultUserUID) {
    //   return;
    // }
    if (user == null) {
      return;
    }

    Person toUpdateWith = Person(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      updatedOn: DateTime.now(),
      isSynced: false,
    );

    await _databaseTable.update(
      await _database,
      toUpdateWith.toMapForDatabase(),
      finder: Finder(
        filter: Filter.equals(
          'uid',
          user.uid,
        ),
      ),
    );
  }

  static Person? currentUser;

  Future<Person> getCurrentUser({bool forceUpdate = false}) async {
    // TODO: Implement the logic such that after UID becomes available, it gets that ID

    // * IDEA : I think firestore plugin has a function that return the UID, and returns
    // * null otherwise(don't remember the name), so use that, like:
    // if(uid_from_firestore != null)
    //    return uid_from_firestore ;
    // else return default UID;
    if (currentUser == null || forceUpdate) {
      currentUser = await getUserFromUserID(
          userIDtoSearch: FirebaseAuthFunctions.getCurrentUser?.uid ??
              Strings.defaultUserUID);
    }

    return currentUser!;
  }

  Future<void> editProfileName(String newName) async {
    final currentUser = await getCurrentUser(forceUpdate: true);
    if (currentUser.uid != Strings.defaultUserUID) {
      await insertOrUpdateUser(currentUser.copyWith(
        name: newName,
      ));
    }
  }

  // ! MOST PROBABLY REMOVE/REMAKE THIS, AND USE [user] ONLY
  // * USED IN MODAL SHEET --------------------------------
  Future<List<String>> getUserNamesFromIDs(List<String> userIDList) async {
    List<String> usersNotFoundInMap = [];
    List<String> usersFoundInMap = [];
    userIDList.forEach((uid) {
      String? userName = usersIdToName[uid];
      if (userName == null) {
        usersNotFoundInMap.add(uid);
      } else {
        usersFoundInMap.add(uid);
      }
    });

    if (usersNotFoundInMap.isEmpty) {
      return usersFoundInMap;
    }

    Finder _finder = Finder(
      filter: Filter.custom(
        (record) {
          if (usersNotFoundInMap.contains(record.value['uid'] as String)) {
            return true;
          }
          return false;
        },
      ),
    );

    final listOfRecordSnapshots =
        await _databaseTable.find(await _database, finder: _finder);

    // listOfRecordSnapshots.map((recordSnapshot) {
    //   User generated = User.fromMap(recordSnapshot.value);
    //   usersIdToName[generated.uid] = generated.name;
    // }).toList();

    listOfRecordSnapshots.forEach((recordSnapshot) {
      Person user = Person.fromMapOfDatabase(recordSnapshot.value);
      // print("usersIdToName[${user.uid}] = ${user.name}");
      usersIdToName[user.uid] = user.name ?? user.email ?? user.uid;
      print("usersIdToName[${user.uid}] = ${usersIdToName[user.uid]}");
      usersFoundInMap.add(user.uid);
    });

    return usersFoundInMap;
  }
  // * ----------------------------------------------------

  Future<List<Person>> getUsersFromUserIDList({
    required List<String> userIDList,
  }) async {
    List<Person> _userListToReturn = [];
    userIDList.forEach((userId) async {
      Person? userToAdd = await getUserFromUserID(userIDtoSearch: userId);
      if (userToAdd != null) {
        _userListToReturn.add(userToAdd);
      }
    });
    return _userListToReturn;
  }

  // TODO: We need to implement a logic to search in the cloud, if userdata is not available locally
  Future<Person?> getUserFromUserID({required String userIDtoSearch}) async {
    print("For userID $userIDtoSearch");
    Finder _finder = Finder(
      filter: Filter.equals('uid', userIDtoSearch),
      limit: 1,
    );

    RecordSnapshot<int, Map<String, dynamic>>? userInfo =
        await _databaseTable.findFirst(await _database, finder: _finder);

    if (userInfo != null) {
      //User info found locally
      print("Found user already: $userInfo");
      return Person.fromMapOfDatabase(userInfo.value);
    } else {
      print("Found userID not found: $userInfo");
      // TODO: implement online search for UID
      // ! Not really required, since we are making sure to add some info during group adding
    }
  }

  // Stream<List<User>> getUserFromUserIDList({
  //   required List<String> userIdList,
  // }) async* {
  //   List<User> _listToReturn = [];
  //   List<String> _userIdsNotFoundLocally = userIdList;

  //   Finder _finder = Finder(
  //     filter: Filter.custom((record) {
  //       if (userIdList.contains(record.value['uid'] as String)) {
  //         _userIdsNotFoundLocally.remove(record.value['uid'] as String);
  //         return true;
  //       }
  //       return false;
  //     }),
  //   );
  //   List<RecordSnapshot<int, Map<String, dynamic>>> listOfUsers =
  //       await _databaseTable.find(await _database, finder: _finder);

  //   _listToReturn = listOfUsers.map((singleUser) {
  //     return User.fromMap(singleUser.value);
  //   }).toList();

  //   yield _listToReturn;
  //   // TODO: Implement logic to search the online database for the remaining users
  //   // Remaining users: _userIdsNotFoundLocally
  // }
}
