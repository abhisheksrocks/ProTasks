import 'dart:async';
import 'dart:convert';

// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:async/async.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/data/data_providers/chats_dao.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/chat.dart';
import 'package:protasks/data/models/group.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/cubit/root_cubits/premium_checker_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/firebase_fstore_functions.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:meta/meta.dart';

part 'sync_state.dart';

class SyncCubit extends HydratedCubit<SyncState> {
  StreamSubscription? _intenetSubscription;
  StreamSubscription? _usersSubscription;
  StreamSubscription? _groupsDownloadSubscription;
  StreamSubscription? _tasksDownloadSubscription;
  StreamSubscription? _chatsDownloadSubscription;
  StreamSubscription? _usersDownloadSubscription;

  StreamSubscription? _groupsUploadSubscription;
  StreamSubscription? _tasksUploadSubscription;
  StreamSubscription? _chatsUploadSubscription;
  StreamSubscription? _usersUploadSubscription;

  StreamSubscription? _loginCubitSubscription;

  CancelableOperation? _nextUpdateCancelableOperation;
  CancelableOperation? _userDownloadCancelableOperation;

  InternetConnectionChecker _internetConnectionChecker =
      InternetConnectionChecker()..checkInterval = Duration(seconds: 1);

  final LoginCubit loginCubit;
  final PremiumCheckerCubit premiumCheckerCubit;

  int internetCheckerCalled = 0;
  int minutesToWait = 1;

  DateTime? nextUpdateTime;

  static const Duration freeUserUpdateInterval = Duration(minutes: 15);

  final FirebaseFstoreFunctions _firebaseFstoreFunctions =
      FirebaseFstoreFunctions();
  final GroupsDao _groupsDao = GroupsDao();
  final TasksDao _tasksDao = TasksDao();
  final ChatsDao _chatsDao = ChatsDao();
  final UsersDao _usersDao = UsersDao();

  // Upload/Download ORDER:
  // 1. Group
  // 2. Task
  // 3. Chat
  // 4. Users (this is generally not relevant)

  SyncCubit({
    required this.loginCubit,
    required this.premiumCheckerCubit,
  }) : super(SyncState(
          currentSyncState: CurrentSyncState.initialized,
          lastGroupSyncTime: DateTimeExtensions.invalid,
          lastChatSyncTime: DateTimeExtensions.invalid,
          lastTaskSyncTime: DateTimeExtensions.invalid,
          lastUserSyncTime: DateTimeExtensions.invalid,
        )) {
    // initializeUploadForFreeUsers();
    // initializeDownloadForFreeUsers();
    loginCubitInitialize();
    premiumCheckerStateListener();
  }

  /// To Do after deleting groups
  void reinitialize() {
    print("Reinitializing syncCubit");
    FirebaseFstoreFunctions.groupIdList.clear();
    FirebaseFstoreFunctions.taskIdToGroupId.clear();

    ChatsDao.taskUnreadCount.clear();
    GroupsDao.groupIdToName.clear();
    TasksDao.taskSubtasksCount.clear();
    UsersDao.usersIdToName.clear();

    _nextUpdateCancelableOperation?.cancel();

    _intenetSubscription?.cancel();
    _usersSubscription?.cancel();

    _groupsDownloadSubscription?.cancel();
    _tasksDownloadSubscription?.cancel();
    _chatsDownloadSubscription?.cancel();

    _groupsUploadSubscription?.cancel();
    _tasksUploadSubscription?.cancel();
    _chatsUploadSubscription?.cancel();
    // loginCubitInitialize();
    internetCheckerCalled = 0;
    minutesToWait = 1;
    nextUpdateTime = null;
  }

  // void performActionBasedOnPremium(
  //     {required PremiumCheckerState premiumCheckerState}) {
  //   performActionsBasedOnLoginState(loginCubit.state);
  // }

  StreamSubscription? _premiumCubitSubscription;

  // CancelableOperation? _cancelableOperation;

  void premiumCheckerStateListener() {
    _premiumCubitSubscription?.cancel();
    _premiumCubitSubscription = premiumCheckerCubit.stream.listen((_) async {
      // performActionBasedOnPremium(premiumCheckerState: premiumCheckerState);
      nextUpdateTime = null;
      performActionsBasedOnLoginState(loginCubit.state);
      // _cancelableOperation?.cancel();
      // _cancelableOperation =
      //     CancelableOperation.fromFuture(Future.delayed(Duration(seconds: 5)));
      // _cancelableOperation?.value.then((_) {
      //   performActionsBasedOnLoginState(loginCubit.state);
      // });
    });
    // * WE NEED TO RESYNC ONLY WHEN THE PREMIUM CUBIT CHANGES, BECAUSE IT WILL
    // * ANYWAY CHECK FOR CURRENT PREMIUM STATE
    // performActionBasedOnPremium(premiumCheckerState: premiumCheckerCubit.state);
    // performActionsBasedOnLoginState(loginCubit.state);
  }

  // void storeAsyncFunctions() async {
  //   final response = FirebaseFunctions.instance.httpsCallable('name');

  //   var value = response('data');

  //   // response..
  // }

  void performActionsBasedOnLoginState(LoginState loginState) {
    switch (loginState.currentLoginState) {
      case CurrentLoginState.loggedIn:
        // Check the internet,
        // if connected:
        //    1. download the latest [Task/Group/Chat/Person] info from the cloud
        //    2. If premium:
        //          1. Start a streamListener for latest change in any info
        //       else:
        //          1. Download the latest info from cloud every 15 mins
        //             (and the device basically stays offline during this time)
        // !  this means that if two people made changes to the same [Task/Group] while offline,
        // !  then the guy who uploads the new info first wins on whose data will be set
        //    3. upload the unsynced [Task/Group/Chat/Person] to the cloud
        //    4. If premium:
        //          1. Upload any new info to the cloud straightaway
        //       else:
        //          1. Upload the changes every 15 mins, but only after download function finishes
        // else:
        //    1. wait while it connects

        // Alternate Approach:
        // listen for internet connection:
        // if connected:
        //    0. Cancel the internet listener
        //    1. Try to download the latest Group Info
        //    2. if fails:
        //        1. So the internet is not working, recall the internet checker
        //       else:
        //        1. update the lastGroupSyncTime
        //    3. try to upload any changes made by you while offline
        //       if fails:
        //        1. So the internet is not working, recall the internet checker
        //       else:
        //        1. update the lastGroupSyncTime
        //    4. if premium:
        //          1. create a listener for latest group info, and update the lastGroupSyncTime
        //             every time a new value is received
        //          2. upload any new info right as it is done
        //       else:
        //          1. download any new info every 15 mins, then upload any changes.
        //    5. Repeat for [Task/Chat]
        return internetChecker();
      // print("AndroidAlarmManager here");
      // break;
      case CurrentLoginState.loggedOut:
        emit(
          SyncState(
            currentSyncState: CurrentSyncState.initialized,
            lastGroupSyncTime: DateTimeExtensions.invalid,
            lastChatSyncTime: DateTimeExtensions.invalid,
            lastTaskSyncTime: DateTimeExtensions.invalid,
            lastUserSyncTime: DateTimeExtensions.invalid,
          ),
        );
        FirebaseFstoreFunctions.groupIdList.clear();
        FirebaseFstoreFunctions.taskIdToGroupId.clear();

        ChatsDao.taskUnreadCount.clear();
        GroupsDao.groupIdToName.clear();
        TasksDao.taskSubtasksCount.clear();
        UsersDao.usersIdToName.clear();
        // AndroidAlarmManager.cancel(1);

        _intenetSubscription?.cancel();
        _usersSubscription?.cancel();
        _nextUpdateCancelableOperation?.cancel();
        _userDownloadCancelableOperation?.cancel();

        _groupsDownloadSubscription?.cancel();
        _tasksDownloadSubscription?.cancel();
        _chatsDownloadSubscription?.cancel();
        _usersDownloadSubscription?.cancel();

        _groupsUploadSubscription?.cancel();
        _tasksUploadSubscription?.cancel();
        _chatsUploadSubscription?.cancel();
        _usersUploadSubscription?.cancel();

        internetCheckerCalled = 0;
        minutesToWait = 1;
        nextUpdateTime = null;
        // disable sync
        break;
      case CurrentLoginState.choseNotToLogIn:
        // disable sync
        emit(
          SyncState(
            currentSyncState: CurrentSyncState.initialized,
            lastGroupSyncTime: DateTimeExtensions.invalid,
            lastChatSyncTime: DateTimeExtensions.invalid,
            lastTaskSyncTime: DateTimeExtensions.invalid,
            lastUserSyncTime: DateTimeExtensions.invalid,
          ),
        );
        break;
    }
    print("CurrentLoginState from SyncCubit : $loginState");
  }

  void loginCubitInitialize() {
    _loginCubitSubscription?.cancel();
    _loginCubitSubscription = loginCubit.stream.listen((loginState) {
      performActionsBasedOnLoginState(loginState);
    });
    performActionsBasedOnLoginState(loginCubit.state);
  }

  List<Group> listOfGroupsToUpload = [];
  List<Person> listOfUsersToUpload = [];
  List<Chat> listOfChatsToUpload = [];
  List<Task> listOfTasksToUpload = [];

  void internetChecker({
    bool calledDueToError = false,
  }) async {
    print("internetChecker called with calledDueToError: $calledDueToError");
    // Cancel all subscriptions, because we will be calling them again anyway
    _intenetSubscription?.cancel();
    _usersSubscription?.cancel();
    _nextUpdateCancelableOperation?.cancel();
    _userDownloadCancelableOperation?.cancel();

    _groupsDownloadSubscription?.cancel();
    _tasksDownloadSubscription?.cancel();
    _chatsDownloadSubscription?.cancel();
    _usersDownloadSubscription?.cancel();

    _groupsUploadSubscription?.cancel();
    _tasksUploadSubscription?.cancel();
    _chatsUploadSubscription?.cancel();
    _usersUploadSubscription?.cancel();

    if (calledDueToError) {
      print("incrementing internetCheckerCalled");
      internetCheckerCalled += 1;
      if (internetCheckerCalled >= 5) {
        print("Lot's of error occurred");
        internetCheckerCalled = 0;
        minutesToWait = minutesToWait * 2;
        nextUpdateTime = DateTime.now().add(Duration(minutes: minutesToWait));
        emit(SyncState(
          currentSyncState: CurrentSyncState.serverError,
          lastGroupSyncTime: state.lastGroupSyncTime,
          lastTaskSyncTime: state.lastTaskSyncTime,
          lastChatSyncTime: state.lastChatSyncTime,
          lastUserSyncTime: state.lastUserSyncTime,
        ));
        _nextUpdateCancelableOperation = CancelableOperation.fromFuture(
          Future.delayed(Duration(minutes: minutesToWait)),
        );
        _nextUpdateCancelableOperation?.value.then((_) {
          nextUpdateTime = null;
          return internetChecker();
        });
        return;
      }
    }
    // emit(SyncState(
    //   currentSyncState: CurrentSyncState.inProgress,
    //   lastGroupSyncTime: state.lastGroupSyncTime,
    //   lastTaskSyncTime: state.lastTaskSyncTime,
    //   lastChatSyncTime: state.lastChatSyncTime,
    //   lastUserSyncTime: state.lastUserSyncTime,
    // ));
    _intenetSubscription?.cancel();
    _intenetSubscription =
        _internetConnectionChecker.onStatusChange.listen((currentStatus) {
      if (currentStatus == InternetConnectionStatus.connected) {
        // doSomething;
        _intenetSubscription?.cancel();
        emit(SyncState(
          currentSyncState: CurrentSyncState.inProgress,
          lastGroupSyncTime: state.lastGroupSyncTime,
          lastTaskSyncTime: state.lastTaskSyncTime,
          lastChatSyncTime: state.lastChatSyncTime,
          lastUserSyncTime: state.lastUserSyncTime,
        ));
        startSync();
      } else {
        print("Facing network issue");
        //i.e. disconnected
        // doSomethingElse;
        emit(SyncState(
          currentSyncState: CurrentSyncState.deviceOffline,
          lastGroupSyncTime: state.lastGroupSyncTime,
          lastTaskSyncTime: state.lastTaskSyncTime,
          lastChatSyncTime: state.lastChatSyncTime,
          lastUserSyncTime: state.lastUserSyncTime,
        ));
      }
    });
  }

  void startSync() async {
    bool isPremium = premiumCheckerCubit.state.currentPremiumState !=
        CurrentPremiumState.freeUser;
    _groupsDownloadSubscription?.cancel();
    _tasksDownloadSubscription?.cancel();
    _chatsDownloadSubscription?.cancel();
    _usersDownloadSubscription?.cancel();
    _groupsUploadSubscription?.cancel();
    _tasksUploadSubscription?.cancel();
    _chatsUploadSubscription?.cancel();
    _usersUploadSubscription?.cancel();
    _intenetSubscription?.cancel();
    print("Starting sync");
    if (state.lastGroupSyncTime
            .isBefore(DateTime.now().subtract(freeUserUpdateInterval)) ||
        isPremium) {
      if (await syncGroups()) {
        emit(SyncState(
          currentSyncState: state.currentSyncState,
          lastGroupSyncTime: DateTime.now().toUtc(),
          lastTaskSyncTime: state.lastTaskSyncTime,
          lastChatSyncTime: state.lastChatSyncTime,
          lastUserSyncTime: state.lastUserSyncTime,
        ));
      } else {
        // emit(SyncState(
        //   currentSyncState: CurrentSyncState.networkIssue,
        //   lastGroupSyncTime: state.lastGroupSyncTime,
        //   lastTaskSyncTime: state.lastTaskSyncTime,
        //   lastChatSyncTime: state.lastChatSyncTime,
        // ));
        print(
            "syncGroups faced error, calling internetChecker again with error");
        return internetChecker(calledDueToError: true);
      }
    }

    if (state.lastTaskSyncTime
            .isBefore(DateTime.now().subtract(freeUserUpdateInterval)) ||
        isPremium) {
      if (await syncTasks()) {
        emit(SyncState(
          currentSyncState: state.currentSyncState,
          lastGroupSyncTime: state.lastGroupSyncTime,
          lastTaskSyncTime: DateTime.now().toUtc(),
          lastChatSyncTime: state.lastChatSyncTime,
          lastUserSyncTime: state.lastUserSyncTime,
        ));
      } else {
        // emit(SyncState(
        //   currentSyncState: CurrentSyncState.networkIssue,
        //   lastGroupSyncTime: state.lastGroupSyncTime,
        //   lastTaskSyncTime: state.lastTaskSyncTime,
        //   lastChatSyncTime: state.lastChatSyncTime,
        // ));
        print("syncTasks faced error calling internet checker");
        return internetChecker(calledDueToError: true);
      }
    }

    if (state.lastChatSyncTime
            .isBefore(DateTime.now().subtract(freeUserUpdateInterval)) ||
        isPremium) {
      if (await syncChats()) {
        emit(SyncState(
          currentSyncState: state.currentSyncState,
          lastGroupSyncTime: state.lastGroupSyncTime,
          lastTaskSyncTime: state.lastTaskSyncTime,
          lastChatSyncTime: DateTime.now().toUtc(),
          lastUserSyncTime: state.lastUserSyncTime,
        ));
      } else {
        // emit(SyncState(
        //   currentSyncState: CurrentSyncState.networkIssue,
        //   lastGroupSyncTime: state.lastGroupSyncTime,
        //   lastTaskSyncTime: state.lastTaskSyncTime,
        //   lastChatSyncTime: state.lastChatSyncTime,
        // ));
        print("syncChats() faced error, calling internetchecker");
        return internetChecker(calledDueToError: true);
      }
    }

    if (state.lastUserSyncTime
            .isBefore(DateTime.now().subtract(freeUserUpdateInterval)) ||
        isPremium) {
      if (await syncUsers()) {
        emit(SyncState(
          currentSyncState: state.currentSyncState,
          lastGroupSyncTime: state.lastGroupSyncTime,
          lastTaskSyncTime: state.lastTaskSyncTime,
          lastChatSyncTime: state.lastChatSyncTime,
          lastUserSyncTime: DateTime.now().toUtc(),
        ));
      } else {
        print("syncUsers() faced error, calling internetchecker");
        return internetChecker(calledDueToError: true);
      }
    }

    _groupsDownloadSubscription?.cancel();
    _tasksDownloadSubscription?.cancel();
    _chatsDownloadSubscription?.cancel();
    _usersDownloadSubscription?.cancel();
    _groupsUploadSubscription?.cancel();
    _tasksUploadSubscription?.cancel();
    _chatsUploadSubscription?.cancel();
    _usersUploadSubscription?.cancel();
    _intenetSubscription?.cancel();
    if (isPremium) {
      emit(SyncState(
        currentSyncState: CurrentSyncState.complete,
        lastGroupSyncTime: state.lastGroupSyncTime,
        lastTaskSyncTime: state.lastTaskSyncTime,
        lastChatSyncTime: state.lastChatSyncTime,
        lastUserSyncTime: state.lastUserSyncTime,
      ));

      _groupsDownloadSubscription?.cancel();
      _groupsDownloadSubscription = _firebaseFstoreFunctions
          .getRealTimeLatestGroupUpdateFromCloud(
            lastUpdatedTime: state.lastGroupSyncTime,
          )
          .listen(
            (querySnapshot) async {
              if (querySnapshot.size > 0 &&
                  querySnapshot.metadata.isFromCache == false) {
                if (await _firebaseFstoreFunctions
                    .groupQuerySnapshotHandler(querySnapshot)) {
                  emit(SyncState(
                    currentSyncState: state.currentSyncState,
                    lastGroupSyncTime: DateTime.now().toUtc(),
                    lastTaskSyncTime: state.lastTaskSyncTime,
                    lastChatSyncTime: state.lastChatSyncTime,
                    lastUserSyncTime: state.lastUserSyncTime,
                  ));
                } else {
                  _groupsDownloadSubscription?.cancel();
                  print("error occurred while saving group data");
                  // because this should be an internal error, so better release a new version soon
                  // no point in wasting internet traffic
                }

                if (!FirebaseFstoreFunctions.groupIdList
                    .contains(querySnapshot.docs.first.id)) {
                  // A new group is added so better start listening for tasks
                  // and chat changes in that new group

                  FirebaseFstoreFunctions.groupIdList
                      .add(querySnapshot.docs.first.id);

                  _groupsDownloadSubscription?.cancel();
                  startSync();
                }
              }
            },
            cancelOnError: true,
            onError: (error) {
              print(
                  "getRealTimeLatestGroupUpdateFromCloud stream error: $error");
              // i.e. some network error has occurred
              FirebaseFstoreFunctions.groupIdList.clear();
              internetChecker(calledDueToError: true);
            },
          );

      _tasksDownloadSubscription?.cancel();
      _tasksDownloadSubscription = _firebaseFstoreFunctions
          .getRealTimeLatestTaskUpdateFromCloud(
            lastUpdatedTime: state.lastTaskSyncTime,
          )
          .listen(
            (querySnapshot) async {
              if (querySnapshot.size > 0
                  // && querySnapshot.metadata.isFromCache == false
                  ) {
                if (await _firebaseFstoreFunctions
                    .taskQuerySnapshotHandler(querySnapshot)) {
                  emit(SyncState(
                    currentSyncState: state.currentSyncState,
                    lastGroupSyncTime: state.lastGroupSyncTime,
                    lastTaskSyncTime: DateTime.now().toUtc(),
                    lastChatSyncTime: state.lastChatSyncTime,
                    lastUserSyncTime: state.lastUserSyncTime,
                  ));
                } else {
                  _tasksDownloadSubscription?.cancel();
                  print("error occurred while saving task data");
                  // because this should be an internal error, so better release a new version soon
                  // no point in wasting internet traffic
                }
              }
            },
            cancelOnError: true,
            onError: (error) {
              print(
                  "getRealTimeLatestTaskUpdateFromCloud stream error: $error");
              // i.e. some network error has occurred
              FirebaseFstoreFunctions.groupIdList.clear();
              internetChecker(calledDueToError: true);
            },
          );

      _chatsDownloadSubscription?.cancel();
      _chatsDownloadSubscription = _firebaseFstoreFunctions
          .getRealTimeLatestChatUpdateFromCloud(
            lastUpdatedTime: state.lastChatSyncTime,
          )
          .listen(
            (querySnapshot) async {
              if (querySnapshot.size > 0
                  // && querySnapshot.metadata.isFromCache == false
                  ) {
                if (await _firebaseFstoreFunctions
                    .chatQuerySnapshotHandler(querySnapshot)) {
                  emit(SyncState(
                    currentSyncState: state.currentSyncState,
                    lastGroupSyncTime: state.lastGroupSyncTime,
                    lastTaskSyncTime: state.lastTaskSyncTime,
                    lastChatSyncTime: DateTime.now().toUtc(),
                    lastUserSyncTime: state.lastUserSyncTime,
                  ));
                } else {
                  _chatsDownloadSubscription?.cancel();
                  print("error occurred while saving chat data");
                  // because this should be an internal error, so better release a new version soon
                  // no point in wasting internet traffic
                }
              }
            },
            cancelOnError: true,
            onError: (error) {
              print(
                  "getRealTimeLatestChatUpdateFromCloud stream error: $error");
              // i.e. some network error has occurred
              FirebaseFstoreFunctions.groupIdList.clear();
              internetChecker(calledDueToError: true);
            },
          );

      _usersDownloadSubscription?.cancel();
      _usersDownloadSubscription =
          _usersDao.getOldestPersonInLocalDatabase().listen(
                (user) async {
                  _userDownloadCancelableOperation?.cancel();
                  print("for user $user");
                  if (user.updatedOn
                      .isAfter(DateTime.now().subtract(Duration(days: 2)))) {
                    DateTime twoDaysBefore =
                        DateTime.now().subtract(Duration(days: 2));
                    Duration differenceDuration =
                        user.updatedOn.difference(twoDaysBefore);
                    // twoDaysBefore.difference(user.updatedOn);

                    // print("1st if");
                    print("differenceDuration $differenceDuration");
                    _userDownloadCancelableOperation =
                        CancelableOperation.fromFuture(
                      Future.delayed(differenceDuration),
                    );

                    _userDownloadCancelableOperation!.value.then((_) async {
                      print("downloading from cloud");
                      if (await _firebaseFstoreFunctions
                          .downloadUserUpdateFromCloud(user.uid)) {
                        emit(SyncState(
                          currentSyncState: state.currentSyncState,
                          lastGroupSyncTime: state.lastGroupSyncTime,
                          lastTaskSyncTime: state.lastTaskSyncTime,
                          lastChatSyncTime: state.lastChatSyncTime,
                          lastUserSyncTime: DateTime.now().toUtc(),
                        ));
                      }
                    });
                  } else {
                    print("2nd if");
                    if (await _firebaseFstoreFunctions
                        .downloadUserUpdateFromCloud(user.uid)) {
                      emit(SyncState(
                        currentSyncState: state.currentSyncState,
                        lastGroupSyncTime: state.lastGroupSyncTime,
                        lastTaskSyncTime: state.lastTaskSyncTime,
                        lastChatSyncTime: state.lastChatSyncTime,
                        lastUserSyncTime: DateTime.now().toUtc(),
                      ));
                    }
                  }
                },
                cancelOnError: true,
                onError: (error) {
                  print("getOldestPersonInLocalDatabase stream error: $error");
                },
              );

      _groupsUploadSubscription?.cancel();
      _groupsUploadSubscription =
          _groupsDao.getAllGroupsToBeUploaded(limit: 1).listen(
                (event) async {
                  if (event.isNotEmpty) {
                    final groupToUpload = event.first;
                    print(
                        "getAllGroupsToBeUploaded listener received group:\n $groupToUpload");
                    bool wasGroupUploadSuccessful =
                        await _firebaseFstoreFunctions
                            .uploadGroupToCloud(groupToUpload);

                    if (wasGroupUploadSuccessful) {
                      emit(SyncState(
                        currentSyncState: state.currentSyncState,
                        lastGroupSyncTime: DateTime.now().toUtc(),
                        lastTaskSyncTime: state.lastTaskSyncTime,
                        lastChatSyncTime: state.lastChatSyncTime,
                        lastUserSyncTime: state.lastUserSyncTime,
                      ));
                    } else {
                      print(
                          " _groupsDao.getAllGroupsToBeUploaded(limit: 1).listen faced error calling internetchecker");
                      internetChecker(calledDueToError: true);
                    }
                  }
                },
                cancelOnError: true,
                onError: (error) {
                  print("getAllGroupsToBeUploaded stream error: $error");
                  // i.e. some network error has occurred
                  internetChecker(calledDueToError: true);
                },
              );

      _tasksUploadSubscription?.cancel();
      _tasksUploadSubscription =
          _tasksDao.getAllTasksToBeUploaded(limit: 1).listen(
                (event) async {
                  if (event.isNotEmpty) {
                    final taskToUpload = event.first;
                    bool wasTaskUploadSuccessful =
                        await _firebaseFstoreFunctions
                            .uploadTaskToCloud(taskToUpload);

                    if (wasTaskUploadSuccessful) {
                      emit(SyncState(
                        currentSyncState: state.currentSyncState,
                        lastGroupSyncTime: state.lastGroupSyncTime,
                        lastTaskSyncTime: DateTime.now().toUtc(),
                        lastChatSyncTime: state.lastChatSyncTime,
                        lastUserSyncTime: state.lastUserSyncTime,
                      ));
                    } else {
                      print(
                          "_tasksDao.getAllTasksToBeUploaded(limit: 1).listen faced error calling internetChecker");
                      internetChecker(calledDueToError: true);
                    }
                  }
                },
                onDone: () {
                  print(" _tasksDao.getAllTasksToBeUploaded(limit: 1) closed");
                },
                cancelOnError: true,
                onError: (error) {
                  print("getAllTasksToBeUploaded stream error: $error");
                  // i.e. some network error has occurred
                  internetChecker(calledDueToError: true);
                },
              );

      _chatsUploadSubscription?.cancel();
      _chatsUploadSubscription =
          // _chatsDao.getRealtimeChatToBeUploaded().listen(
          //   (chatToUpload) async {
          _chatsDao.getAllChatsToBeUploaded(limit: 1).listen(
                (event) async {
                  // print("New chat to upload: $chatToUpload");
                  if (event.isNotEmpty) {
                    print("New chat to upload: ${event.first}");
                    final chatToUpload = event.first;
                    bool wasChatUploadSuccessful =
                        await _firebaseFstoreFunctions
                            .uploadChatToCloud(chatToUpload);

                    if (wasChatUploadSuccessful) {
                      emit(SyncState(
                        currentSyncState: state.currentSyncState,
                        lastGroupSyncTime: state.lastGroupSyncTime,
                        lastTaskSyncTime: state.lastTaskSyncTime,
                        lastChatSyncTime: DateTime.now().toUtc(),
                        lastUserSyncTime: state.lastUserSyncTime,
                      ));
                    } else {
                      print(
                          "getAllChatsToBeUploaded calling internet checker again with error");
                      internetChecker(calledDueToError: true);
                    }
                  }
                },
                onDone: () {
                  print("_chatsUploadSubscription closed");
                },
                cancelOnError: true,
                onError: (error) {
                  print("getAllChatsToBeUploaded stream error: $error");
                  // i.e. some network error has occurred
                  internetChecker(calledDueToError: true);
                },
              );

      _usersUploadSubscription?.cancel();
      _usersUploadSubscription = _usersDao.getUserToBeUploaded().listen(
            (user) async {
              if (user != null) {
                if (await _firebaseFstoreFunctions.uploadPersonToCloud(user)) {
                  emit(SyncState(
                    currentSyncState: state.currentSyncState,
                    lastGroupSyncTime: state.lastGroupSyncTime,
                    lastTaskSyncTime: state.lastTaskSyncTime,
                    lastChatSyncTime: state.lastChatSyncTime,
                    lastUserSyncTime: DateTime.now().toUtc(),
                  ));
                }
              }
            },
            cancelOnError: true,
            onError: (error) {
              print("uploadPersonToCloud stream error: $error");
              // i.e. some network error has occurred
              internetChecker(calledDueToError: true);
            },
          );

      // Firestore doesn't throw error on device Offline
      _intenetSubscription?.cancel();
      _intenetSubscription =
          _internetConnectionChecker.onStatusChange.listen((currentStatus) {
        if (currentStatus == InternetConnectionStatus.disconnected) {
          print("Internet is disconnected");
          _intenetSubscription?.cancel();
          // WILL BE CANCELLED ANYWAY IN internetChecker();

          internetChecker();
        }
      });
    } else {
      DateTime smallestTime =
          state.lastGroupSyncTime.isBefore(state.lastTaskSyncTime)
              ? state.lastGroupSyncTime
              : state.lastTaskSyncTime;
      smallestTime = smallestTime.isBefore(state.lastChatSyncTime)
          ? smallestTime
          : state.lastChatSyncTime;

      nextUpdateTime = smallestTime.add(freeUserUpdateInterval);

      emit(SyncState(
        currentSyncState: CurrentSyncState.waiting,
        lastGroupSyncTime: state.lastGroupSyncTime,
        lastTaskSyncTime: state.lastTaskSyncTime,
        lastChatSyncTime: state.lastChatSyncTime,
        lastUserSyncTime: state.lastUserSyncTime,
      ));

      // The reason we need CancelableOperation here, because the user may
      // be a free user initially and become a pro during the session,
      // or for a generally case, the function may be called multiple times, then
      // we won't want the internet checker to be called multiple times, as
      // there is no way to cancel a Future
      print(
          "Since last update time was: ${smallestTime.toLocal()} .\nNext update time is: ${nextUpdateTime!.toLocal()}");

      _nextUpdateCancelableOperation = CancelableOperation.fromFuture(
        Future.delayed(nextUpdateTime!.difference(DateTime.now().toUtc())),
      );
      _nextUpdateCancelableOperation?.value.then((_) {
        nextUpdateTime = null;
        internetChecker();
      });
    }
  }

  Future<bool> syncGroups() async {
    bool wasGroupDownloadSuccessful =
        await _firebaseFstoreFunctions.downloadGroupUpdatesFromCloud(
      lastUpdatedTime: state.lastGroupSyncTime,
    );

    if (wasGroupDownloadSuccessful) {
      final listOfGroupsToUpload =
          await _groupsDao.getAllGroupsToBeUploaded().first;

      for (final groupToUpload in listOfGroupsToUpload) {
        bool wasGroupUploadSuccessful =
            await _firebaseFstoreFunctions.uploadGroupToCloud(groupToUpload);

        if (!wasGroupUploadSuccessful) {
          return false;
        }
      }
      return true;
    }

    return false;
  }

  Future<bool> syncTasks() async {
    bool wasTaskDownloadSuccessful =
        await _firebaseFstoreFunctions.downloadTaskUpdatesFromCloud(
      lastUpdatedTime: state.lastTaskSyncTime,
    );

    if (wasTaskDownloadSuccessful) {
      final listOfTasksToUpload =
          await _tasksDao.getAllTasksToBeUploaded().first;

      for (final taskToUpload in listOfTasksToUpload) {
        bool wasTaskUploadSuccessful =
            await _firebaseFstoreFunctions.uploadTaskToCloud(taskToUpload);

        if (!wasTaskUploadSuccessful) {
          return false;
        }
      }
      return true;
    }

    return false;
  }

  Future<bool> syncChats() async {
    bool wasChatDownloadSuccessful =
        await _firebaseFstoreFunctions.downloadChatUpdatesFromCloud(
      lastUpdatedTime: state.lastChatSyncTime,
    );

    if (wasChatDownloadSuccessful) {
      final listOfChatsToUpload =
          await _chatsDao.getAllChatsToBeUploaded().first;

      for (final chatToUpload in listOfChatsToUpload) {
        bool wasChatUploadSuccessful =
            await _firebaseFstoreFunctions.uploadChatToCloud(chatToUpload);

        if (!wasChatUploadSuccessful) {
          return wasChatUploadSuccessful;
        }
      }
      return true;
    }

    return false;
  }

  Future<bool> syncUsers() async {
    bool wasUserDownloadSuccessful =
        await _firebaseFstoreFunctions.downloadUsersUpdatesFromCloud();
    if (wasUserDownloadSuccessful) {
      final userToUpload = await _usersDao.getUserToBeUploaded().first;
      if (userToUpload != null) {
        bool wasUserUploadSuccessful =
            await _firebaseFstoreFunctions.uploadPersonToCloud(userToUpload);

        if (!wasUserUploadSuccessful) {
          print("user upload unsuccessful");
          return wasUserUploadSuccessful;
        }
      }
      return true;
    }
    print("user download unsuccessful");
    return false;
  }

  @override
  Future<void> close() {
    _loginCubitSubscription?.cancel();
    _nextUpdateCancelableOperation?.cancel();

    _intenetSubscription?.cancel();
    _usersSubscription?.cancel();

    _groupsDownloadSubscription?.cancel();
    _tasksDownloadSubscription?.cancel();
    _chatsDownloadSubscription?.cancel();

    _groupsUploadSubscription?.cancel();
    _tasksUploadSubscription?.cancel();
    _chatsUploadSubscription?.cancel();
    return super.close();
  }

  @override
  SyncState? fromJson(Map<String, dynamic> json) {
    return SyncState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SyncState state) {
    return state.toMap();
  }
}
