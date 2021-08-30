import 'dart:async';

import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/data_providers/chats_dao.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/chat.dart';
import 'package:protasks/data/models/group.dart';
import 'package:protasks/data/models/recursion_interval.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
// import 'package:sembast_cloud_firestore_type_adapters/type_adapters.dart';

import 'groups_dao.dart';
import 'tasks_dao.dart';

class AppDatabase {
  static final AppDatabase _singleton = AppDatabase._();

  static const String _databaseFileName = "AppDatabase.db";

  static AppDatabase get instance => _singleton;

  AppDatabase._();

  Completer<Database>? _databaseOpenCompleter;

  Future<Database> get database async {
    if (_databaseOpenCompleter == null) {
      _databaseOpenCompleter = Completer();
      _openDatabase();
    }

    return _databaseOpenCompleter!.future;
  }

  Future deleteDatabase() async {
    // * TECHNICALLY, we can leave whole [users] database, because that anyway
    // * has all public information, and hence can be kept

    // Get the [Directory] object for app location
    final _appDirectory = await getApplicationDocumentsDirectory();

    // Make sure the folder exists
    // await _appDirectory.create(recursive: true);

    // Store the whole app path in a [String]
    String _databasePath = "${_appDirectory.path}/$_databaseFileName";

    print("Database Path: $_databasePath");

    await databaseFactoryIo.deleteDatabase(_databasePath);
    _databaseOpenCompleter = null;
  }

  Future initializeDatabaseForUser({
    bool makeTasks = true,
    bool makeGroups = true,
    bool makeChats = true,
    bool makeUsers = true,
  }) async {
    // We can't have chats without tasks

    if (makeChats) {
      makeTasks = true;
    }

    // We can't have tasks without group
    if (makeTasks) {
      makeGroups = true;
    }

    // We can't have task, group, chat without users
    if (makeGroups) {
      makeUsers = true;
    }

    //
    Person? currentUser;
    final currentAuthUser = FirebaseAuthFunctions.getCurrentUser;
    if (currentAuthUser != null) {
      currentUser = Person(
        uid: currentAuthUser.uid,
        email: currentAuthUser.email,
        name: currentAuthUser.displayName,
        updatedOn: DateTimeExtensions.invalid,
        isSynced: false,
      );
    }

    DateTime _dateTimeNow = DateTime.now().toLocal();
    String _personalGroupUID = ExtraFunctions.createId;
    String _workGroupUID = ExtraFunctions.createId;

    String _taskId1 = ExtraFunctions.createId;
    String _taskId2 = ExtraFunctions.createId;
    String _taskId3 = ExtraFunctions.createId;
    String _taskId4 = ExtraFunctions.createId;
    String _taskId5 = ExtraFunctions.createId;
    String _taskId6 = ExtraFunctions.createId;
    String _taskId7 = ExtraFunctions.createId;
    String _taskId8 = ExtraFunctions.createId;

    String _protasksDevUID = Strings.defaultProTasksUID;
    String _protasksDevEmail = Strings.defaultProTasksEmail;

    String _userUID = Strings.defaultUserUID;

    Database db = await database;
    if (makeUsers) {
      String _usersTableName = UsersDao.tableName;
      final _usersTable = intMapStoreFactory.store(_usersTableName);

      String _protasksDevName = Strings.defaultProTasksName;
      String _userName = Strings.defaultUserName;

      await _usersTable.add(
        db,
        Person(
          name: _protasksDevName,
          uid: _protasksDevUID,
          email: _protasksDevEmail,
          updatedOn: _dateTimeNow,
          isSynced: true, // Doesn't matter
        ).toMapForDatabase(),
      );

      await _usersTable.add(
        db,
        currentUser?.toMapForDatabase() ??
            Person(
              name: _userName,
              uid: _userUID,
              updatedOn: DateTimeExtensions.invalid,
              isSynced: false,
            ).toMapForDatabase(),
      );
    }

    if (makeGroups) {
      String _groupsTableName = GroupsDao.tableName;
      final _groupsTable = intMapStoreFactory.store(_groupsTableName);

      String _personalGroupName = 'Personal🧑';
      String _workGroupName = 'Work💼';

      await _groupsTable.add(
        db,
        Group(
          id: _personalGroupUID,
          name: _personalGroupName,
          members: [currentUser?.uid ?? _userUID, _protasksDevUID],
          admins: [currentUser?.uid ?? _userUID],
          parentGroupId: Strings.noGroupID,
          createdOn: _dateTimeNow,
          updatedOn: _dateTimeNow,
          isSynced: false,
        ).toMapForDatabase(),
      );

      await _groupsTable.add(
        db,
        Group(
          id: _workGroupUID,
          name: _workGroupName,
          members: [currentUser?.uid ?? _userUID, _protasksDevUID],
          admins: [currentUser?.uid ?? _userUID],
          parentGroupId: Strings.noGroupID,
          createdOn: _dateTimeNow,
          updatedOn: _dateTimeNow,
          isSynced: false,
        ).toMapForDatabase(),
      );
    }

    if (makeTasks) {
      String _tasksTableName = TasksDao.tableName;
      final _tasksTable = intMapStoreFactory.store(_tasksTableName);

      // DateTime taskTime

      await _tasksTable.add(
        db,
        Task(
          id: _taskId1,
          createdBy: _protasksDevUID,
          createdOn: _dateTimeNow,
          description: 'Create your first task📔',
          isCompleted: false,
          isSynced: false,
          modifiedBy: _protasksDevUID,
          modifiedOn: _dateTimeNow,
          recursionInterval: RecursionInterval.zero,
          time: DateTime(
            _dateTimeNow.year,
            _dateTimeNow.month,
            _dateTimeNow.day,
            19,
            59,
          ).isAfter(_dateTimeNow) //Including reminder time
              ? DateTime(
                  _dateTimeNow.year,
                  _dateTimeNow.month,
                  _dateTimeNow.day,
                  23,
                  59,
                )
              : DateTime(
                  _dateTimeNow.year,
                  _dateTimeNow.month,
                  _dateTimeNow.day,
                  23,
                  59,
                ).add(Duration(days: 1)),
          isBy: true,
          recursionTill: DateTimeExtensions.invalid,
          remindTimer: Duration(hours: 4),
          taskPriority: TaskPriority.high,
          groupId: _workGroupUID,
          parentTaskId: Strings.noTaskID,
          assignedTo: [currentUser?.uid ?? _userUID],
          isDeleted: false,
        ).toMapForDatabase(),
      );

      await _tasksTable.add(
        db,
        Task(
          id: _taskId2,
          createdBy: _protasksDevUID,
          createdOn: _dateTimeNow,
          description: 'Create your first group🤝🏻',
          isCompleted: false,
          isSynced: false,
          modifiedBy: _protasksDevUID,
          modifiedOn: _dateTimeNow,
          recursionInterval: RecursionInterval.zero,
          time: DateTime(
            _dateTimeNow.year,
            _dateTimeNow.month,
            _dateTimeNow.day,
            23,
            59,
          ),
          isBy: true,
          recursionTill: DateTimeExtensions.invalid,
          remindTimer: Duration.zero,
          taskPriority: TaskPriority.low,
          groupId: _workGroupUID,
          parentTaskId: Strings.noTaskID,
          assignedTo: [currentUser?.uid ?? _userUID],
          isDeleted: false,
        ).toMapForDatabase(),
      );

      if (currentAuthUser != null) {
        await _tasksTable.add(
          db,
          Task(
            id: _taskId3,
            createdBy: _protasksDevUID,
            createdOn: _dateTimeNow,
            description: "Invite a friend🧔🏻 to your group👥",
            isCompleted: false,
            isSynced: false,
            modifiedBy: _protasksDevUID,
            modifiedOn: _dateTimeNow,
            recursionInterval: RecursionInterval.zero,
            time: DateTime(
              _dateTimeNow.year,
              _dateTimeNow.month,
              _dateTimeNow.day,
              23,
              59,
            ).add(Duration(days: 1)),
            isBy: true,
            recursionTill: _dateTimeNow,
            remindTimer: Duration.zero,
            taskPriority: TaskPriority.low,
            groupId: _workGroupUID,
            parentTaskId: _taskId2,
            assignedTo: [currentUser?.uid ?? _userUID],
            isDeleted: false,
          ).toMapForDatabase(),
        );

        await _tasksTable.add(
          db,
          Task(
            id: _taskId4,
            createdBy: _protasksDevUID,
            createdOn: _dateTimeNow,
            description: 'Assign a task✅ to your friend',
            isCompleted: false,
            isSynced: false,
            modifiedBy: currentUser?.uid ?? _userUID,
            modifiedOn: _dateTimeNow,
            recursionInterval: RecursionInterval.zero,
            time: DateTime(
              _dateTimeNow.year,
              _dateTimeNow.month,
              _dateTimeNow.day,
              23,
              59,
            ).add(Duration(days: 1)),
            isBy: true,
            recursionTill: DateTimeExtensions.invalid,
            remindTimer: Duration.zero,
            taskPriority: TaskPriority.low,
            groupId: _workGroupUID,
            parentTaskId: _taskId2,
            assignedTo: [currentUser?.uid ?? _userUID],
            isDeleted: false,
          ).toMapForDatabase(),
        );
      }

      await _tasksTable.add(
        db,
        Task(
          id: _taskId5,
          createdBy: _protasksDevUID,
          createdOn: _dateTimeNow,
          description: 'Drink 2 L of water💧 daily',
          isCompleted: false,
          isSynced: false,
          modifiedBy: _protasksDevUID,
          modifiedOn: _dateTimeNow,
          recursionInterval: RecursionInterval(days: 1),
          time: DateTime(
            _dateTimeNow.year,
            _dateTimeNow.month,
            _dateTimeNow.day,
            20,
            59,
          ).isAfter(_dateTimeNow) // Including reminder time
              ? DateTime(
                  _dateTimeNow.year,
                  _dateTimeNow.month,
                  _dateTimeNow.day,
                  23,
                  59,
                )
              : DateTime(
                  _dateTimeNow.year,
                  _dateTimeNow.month,
                  _dateTimeNow.day,
                  23,
                  59,
                ).add(Duration(days: 1)),
          isBy: true,
          recursionTill: DateTimeExtensions.invalid,
          remindTimer: Duration(hours: 4),
          taskPriority: TaskPriority.high,
          groupId: _personalGroupUID,
          parentTaskId: Strings.noTaskID,
          assignedTo: [currentUser?.uid ?? _userUID],
          isDeleted: false,
        ).toMapForDatabase(),
      );

      await _tasksTable.add(
        db,
        Task(
          id: _taskId6,
          createdBy: _protasksDevUID,
          createdOn: _dateTimeNow,
          description: 'Exercise🏋🏻‍♂️ daily',
          isCompleted: false,
          isSynced: false,
          modifiedBy: _protasksDevUID,
          modifiedOn: _dateTimeNow,
          recursionInterval: RecursionInterval(days: 1),
          time: DateTime(
            _dateTimeNow.year,
            _dateTimeNow.month,
            _dateTimeNow.day,
            17,
            50,
          ).isAfter(_dateTimeNow) // Including reminder time
              ? DateTime(
                  _dateTimeNow.year,
                  _dateTimeNow.month,
                  _dateTimeNow.day,
                  18,
                  0,
                )
              : DateTime(
                  _dateTimeNow.year,
                  _dateTimeNow.month,
                  _dateTimeNow.day,
                  18,
                  0,
                ).add(Duration(days: 1)),
          isBy: false,
          recursionTill: DateTimeExtensions.invalid,
          remindTimer: Duration(minutes: 10),
          taskPriority: TaskPriority.medium,
          groupId: _personalGroupUID,
          parentTaskId: Strings.noTaskID,
          assignedTo: [currentUser?.uid ?? _userUID],
          isDeleted: false,
        ).toMapForDatabase(),
      );

      await _tasksTable.add(
        db,
        Task(
          id: _taskId7,
          createdBy: _protasksDevUID,
          createdOn: _dateTimeNow,
          description: 'Talk📞 to a long lost friend',
          isCompleted: false,
          isSynced: false,
          modifiedBy: _protasksDevUID,
          modifiedOn: _dateTimeNow,
          recursionInterval: RecursionInterval(months: 1),
          time: DateTime(
            _dateTimeNow.year,
            _dateTimeNow.month,
            _dateTimeNow.day,
            19,
            50,
          ).isAfter(_dateTimeNow) // Including reminder tim
              ? DateTime(
                  _dateTimeNow.year,
                  _dateTimeNow.month,
                  _dateTimeNow.day,
                  20,
                  0,
                )
              : DateTime(
                  _dateTimeNow.year,
                  _dateTimeNow.month,
                  _dateTimeNow.day,
                  20,
                  0,
                ).add(Duration(days: 1)),
          isBy: false,
          recursionTill: DateTimeExtensions.invalid,
          remindTimer: Duration(minutes: 10),
          taskPriority: TaskPriority.medium,
          groupId: _personalGroupUID,
          parentTaskId: Strings.noTaskID,
          assignedTo: [currentUser?.uid ?? _userUID],
          isDeleted: false,
        ).toMapForDatabase(),
      );

      await _tasksTable.add(
        db,
        Task(
          id: _taskId8,
          createdBy: _protasksDevUID,
          createdOn: _dateTimeNow,
          description: 'Give your feedback💬 to ProTasks developer👨🏻‍💻',
          isCompleted: false,
          isSynced: false,
          modifiedBy: _protasksDevUID,
          modifiedOn: _dateTimeNow,
          recursionInterval: RecursionInterval.zero,
          time: DateTime(
            _dateTimeNow.year,
            _dateTimeNow.month + 1,
            _dateTimeNow.day,
            20,
            0,
          ),
          isBy: false,
          recursionTill: DateTimeExtensions.invalid,
          remindTimer: Duration.zero,
          taskPriority: TaskPriority.low,
          groupId: _personalGroupUID,
          parentTaskId: Strings.noTaskID,
          assignedTo: [currentUser?.uid ?? _userUID],
          isDeleted: false,
        ).toMapForDatabase(),
      );
    }

    if (makeChats) {
      String _chatsTableName = ChatsDao.tableName;
      final _chatsTable = intMapStoreFactory.store(_chatsTableName);

      String _chatId1 = ExtraFunctions.createId;
      String _chatId2 = ExtraFunctions.createId;
      String _chatId3 = ExtraFunctions.createId;
      String _chatId4 = ExtraFunctions.createId;
      String _chatId5 = ExtraFunctions.createId;
      String _chatId6 = ExtraFunctions.createId;
      String _chatId7 = ExtraFunctions.createId;
      String _chatId8 = ExtraFunctions.createId;

      await _chatsTable.add(
        db,
        Chat(
          id: _chatId1,
          refId: _taskId1,
          time: _dateTimeNow.subtract(Duration(seconds: 5)),
          isSeen: false,
          messageType: MessageType.text,
          fromUID: _protasksDevUID,
          messageContent:
              'Hi There! Use this space for things like discussions🗨 or notes📝 related to task',
          replyToChatId: Strings.noChatID,
          isSynced: false,
        ).toMapForDatabase(),
      );

      await _chatsTable.add(
        db,
        Chat(
          id: _chatId2,
          refId: _taskId1,
          time: _dateTimeNow.subtract(Duration(seconds: 4)),
          isSeen: false,
          messageType: MessageType.text,
          fromUID: _protasksDevUID,
          messageContent:
              'We really appreciate you trying our app🙇🏻‍♂️. We hope you have a great time here❤.',
          replyToChatId: Strings.noChatID,
          isSynced: false,
        ).toMapForDatabase(),
      );

      await _chatsTable.add(
        db,
        Chat(
          id: _chatId3,
          refId: _taskId1,
          time: _dateTimeNow.subtract(Duration(seconds: 3)),
          isSeen: false,
          messageType: MessageType.text,
          fromUID: _protasksDevUID,
          messageContent:
              'BTW, you can also reply↩ to other messages. Just swipe right➡ on the message you want to reply to.',
          replyToChatId: _chatId2,
          isSynced: false,
        ).toMapForDatabase(),
      );

      await _chatsTable.add(
        db,
        Chat(
          id: _chatId4,
          refId: _taskId1,
          time: _dateTimeNow.subtract(Duration(seconds: 2)),
          isSeen: false,
          messageType: MessageType.text,
          fromUID: _protasksDevUID,
          messageContent:
              "TIP💡- Create your first Task by clicking the '➕' button, on the bottom right corner on the main screen",
          replyToChatId: Strings.noChatID,
          isSynced: false,
        ).toMapForDatabase(),
      );

      await _chatsTable.add(
        db,
        Chat(
          id: _chatId5,
          refId: _taskId2,
          time: _dateTimeNow.subtract(Duration(seconds: 10)),
          isSeen: false,
          messageType: MessageType.text,
          fromUID: _protasksDevUID,
          messageContent:
              "To create a new group👥:\n1️⃣ Open the Side Drawer Menu(swipe right➡ on main screen).\n2️⃣ Click on the 'Groups' section. A group list should appear on the screen✨\n3️⃣ Click on '+ Create group' button🖱.\n4️⃣ Give your group a name.📛\n5️⃣ (OPTIONAL) If you are a registered user, you can also add/invite your friends to the group😄",
          replyToChatId: Strings.noChatID,
          isSynced: false,
        ).toMapForDatabase(),
      );

      await _chatsTable.add(
        db,
        Chat(
          id: _chatId6,
          refId: _taskId3,
          time: _dateTimeNow.subtract(Duration(seconds: 10)),
          isSeen: false,
          messageType: MessageType.text,
          fromUID: _protasksDevUID,
          messageContent:
              "To invite a friend to the group:\n1️⃣ From the side drawer, select the group you want to add your friend to.(you must be admin👑 of that group)\n2️⃣ On the top right corner, click the '⋮' button🖱 and select group info.\n3️⃣ You can members on this screen.\n4.Hit 'SAVE'☑ after finishing to save your changes.",
          replyToChatId: Strings.noChatID,
          isSynced: false,
        ).toMapForDatabase(),
      );

      await _chatsTable.add(
        db,
        Chat(
          id: _chatId7,
          refId: _taskId8,
          time: _dateTimeNow.subtract(Duration(seconds: 10)),
          isSeen: false,
          messageType: MessageType.text,
          fromUID: _protasksDevUID,
          messageContent:
              "Your feedback📝 is really important to us. It helps us understand how good are we doing, or what more could we do to improve.",
          replyToChatId: Strings.noChatID,
          isSynced: false,
        ).toMapForDatabase(),
      );

      await _chatsTable.add(
        db,
        Chat(
          id: _chatId8,
          refId: _taskId8,
          time: _dateTimeNow.subtract(Duration(seconds: 9)),
          isSeen: false,
          messageType: MessageType.text,
          fromUID: _protasksDevUID,
          messageContent:
              "There are 3️⃣ ways to do it\n1️⃣ (Recommended) Mail📧 us at developer@protasks.in. This will easily help us to get back to you for more information/replies.\n2️⃣ Write a review on PlayStore▶\n3️⃣ Message💬 the developer on LinkedIn(visit the 'About the app' section📑 for more details)",
          replyToChatId: Strings.noChatID,
          isSynced: false,
        ).toMapForDatabase(),
      );

      // await _chatsTable.add(
      //   db,
      //   Chat(
      //     id: _chatId5,
      //     refId: _taskId1,
      //     time: _dateTimeNow.subtract(Duration(seconds: 397)),
      //     isSeen: false,
      //     messageType: MessageType.text,
      //     fromUID: currentUser?.uid ?? _userUID,
      //     messageContent: 'This is the reply to your message',
      //     replyToChatId: _chatId4,
      //     isSynced: false,
      //   ).toMapForDatabase(),
      // );

      // await _chatsTable.add(
      //   db,
      //   Chat(
      //     id: _chatId6,
      //     refId: _taskId1,
      //     time: _dateTimeNow.subtract(Duration(seconds: 200)),
      //     isSeen: false,
      //     messageType: MessageType.text,
      //     fromUID: _protasksDevUID,
      //     messageContent: 'This is us replying to your message',
      //     replyToChatId: _chatId4,
      //     isSynced: false,
      //   ).toMapForDatabase(),
      // );

      // await _chatsTable.add(
      //   db,
      //   Chat(
      //     id: _chatId7,
      //     refId: _taskId1,
      //     time: _dateTimeNow.subtract(Duration(seconds: 198)),
      //     isSeen: false,
      //     messageType: MessageType.text,
      //     fromUID: currentUser?.uid ?? _userUID,
      //     messageContent: 'This is you replying to our message',
      //     replyToChatId: _chatId6,
      //     isSynced: false,
      //   ).toMapForDatabase(),
      // );
    }
  }

  Future _openDatabase() async {
    // Get the [Directory] object for app location
    final _appDirectory = await getApplicationDocumentsDirectory();

    // Make sure the folder exists
    await _appDirectory.create(recursive: true);

    // Store the whole app path in a [String]
    String _databasePath = "${_appDirectory.path}/$_databaseFileName";

    print("Database Path: $_databasePath");

    // Open a new or existing database
    // final _database = await databaseFactoryIo.openDatabase(_databasePath);

    // Add some database values by default if the database is empty
    final _database = await databaseFactoryIo.openDatabase(
      _databasePath,
      // codec: sembastFirestoreCodec,
      version: 1,
      // onVersionChanged: (db, oldVersion, newVersion) async {

      // },
    );

    // complete the [Database] future
    _databaseOpenCompleter!.complete(_database);
  }
}
