import 'dart:async';

import 'package:async/async.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/firebase_fstore_functions.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:meta/meta.dart';

import 'dart:convert';

part 'sync_queues_state.dart';

class SyncQueuesCubit extends HydratedCubit<SyncQueuesState> {
  SyncQueuesCubit()
      : super(SyncQueuesState(
          chatIdsToSync: [], // To be implemented
          groupIdsToSync: [], // Fetch all TASKS(not Group) where groupId is this
          taskIdsToSync: [], // Fetch all CHATS(not Task) where groupId is this
          userIdsToSync: [], // To be implemented
        )) {
    syncOldIdsFirst();
  }

  InternetConnectionChecker _internetConnectionChecker =
      InternetConnectionChecker();

  void syncOldIdsFirst() {
    _internetConnectionChecker.checkInterval = Duration(seconds: 1);
    checkForInternetAndFetch();
  }

  void addItemToQueue({
    String? groupId,
    String? taskId,
    String? chatId,
    String? userId,
  }) async {
    print("addItemToQueue called");
    final groupIdList = List<String>.from(state.groupIdsToSync);
    if (groupId != null) {
      print("adding group to queue");
      if (!groupIdList.contains(groupId)) {
        groupIdList.add(groupId);
      }
    }
    final taskIdList = List<String>.from(state.taskIdsToSync);
    if (taskId != null) {
      print("adding task to queue");
      if (!taskIdList.contains(groupId)) {
        taskIdList.add(taskId);
      }
    }
    final chatIdList = List<String>.from(state.chatIdsToSync);
    if (chatId != null) {
      print("adding chat to queue");
      if (!chatIdList.contains(groupId)) {
        chatIdList.add(chatId);
      }
    }
    final userIdList = List<String>.from(state.userIdsToSync);
    if (userId != null) {
      print("adding user to queue");
      if (!userIdList.contains(groupId)) {
        userIdList.add(userId);
      }
    }
    emit(SyncQueuesState(
      groupIdsToSync: groupIdList,
      taskIdsToSync: taskIdList,
      chatIdsToSync: chatIdList,
      userIdsToSync: userIdList,
    ));
    checkForInternetAndFetch();
  }

  StreamSubscription? _streamSubscription;
  CancelableOperation? _cancelableOperation;

  int errorCounter = 0;

  int minutesToWait = 1;

  void checkForInternetAndFetch({
    bool calledDueToError = false,
  }) async {
    print("checkForInternetAndFetch called");
    if (calledDueToError) {
      print("Incrementing Error counter");
      errorCounter += 1;
      if (errorCounter >= 5) {
        print("Sync Queue Error Occurred to many times");
        errorCounter = 0;
        minutesToWait = minutesToWait * 2;
        print("Waiting for $minutesToWait minutes before trying again");
        _cancelableOperation?.cancel();
        _cancelableOperation = CancelableOperation.fromFuture(
          Future.delayed(Duration(minutes: minutesToWait)),
        );
        _cancelableOperation?.value.then((_) {
          _cancelableOperation?.cancel();
          return checkForInternetAndFetch();
        });
        return;
      }
    }

    print("checking for internet");
    if (await _internetConnectionChecker.connectionStatus ==
        (InternetConnectionStatus.connected)) {
      print("Starting to fetch directly");
      startFetching();
    } else {
      _streamSubscription?.cancel();
      _streamSubscription =
          _internetConnectionChecker.onStatusChange.listen((status) {
        print("Intenet Status: $status");
        if (status == InternetConnectionStatus.connected) {
          print("internet connected");
          startFetching();
          _streamSubscription?.cancel();
        } else {
          print("internet disconnected");
        }
      });
    }
  }

  void startFetching() async {
    print("starting fetch sync_queues_cubit");
    if (state.groupIdsToSync.isNotEmpty) {
      List<String> _groupIdsList = List.from(state.groupIdsToSync);
      print("_groupIdsList: $_groupIdsList");
      print("starting group sync");
      // Fetch all the tasks of this group
      try {
        if (await FirebaseFstoreFunctions()
            .downloadTaskUpdatesFromCloudOneByOne(
          lastUpdatedTime: DateTimeExtensions.invalid,
          listOfGroupsToFetchFrom: state.groupIdsToSync,
        )) {
          print("downloaded tasks");
          // The reason I am emiting new state like this and not [] directly, is because
          // what if addItemToQueue() is called again cz of different groupid while this
          // is already executing
          emit(SyncQueuesState(
            groupIdsToSync: state.groupIdsToSync
              ..removeWhere((element) => _groupIdsList.contains(element)),
            taskIdsToSync: state.taskIdsToSync,
            chatIdsToSync: state.chatIdsToSync,
            userIdsToSync: state.userIdsToSync,
          ));
        } else {
          print("it seems that the data wasn't saved correctly");
          checkForInternetAndFetch(calledDueToError: true);
        }
      } catch (exception) {
        print("sync_queues_cubit startFetching group exception:\n $exception");
        checkForInternetAndFetch(calledDueToError: true);
      }
    } else {
      print("no groups to sync");
    }

    if (state.taskIdsToSync.isNotEmpty) {
      List<String> _taskIdsList = new List.from(state.taskIdsToSync);
      print("_taskIdsList: $_taskIdsList");
      print("starting task sync");
      // Fetch all the tasks of this task
      try {
        if (await FirebaseFstoreFunctions()
            .downloadChatUpdatesFromCloudOneByOne(
          lastUpdatedTime: DateTimeExtensions.invalid,
          listOfTasksToFetchFrom: state.taskIdsToSync,
        )) {
          print("downloaded chats");
          // The reason I am emiting new state like this and not [] directly, is because
          // what if addItemToQueue() is called again cz of different taskid while this
          // is already executing
          emit(SyncQueuesState(
            groupIdsToSync: state.taskIdsToSync,
            taskIdsToSync: state.taskIdsToSync
              ..removeWhere((element) => _taskIdsList.contains(element)),
            chatIdsToSync: state.chatIdsToSync,
            userIdsToSync: state.userIdsToSync,
          ));
        } else {
          print("it seems that the data wasn't saved correctly");
          checkForInternetAndFetch(calledDueToError: true);
        }
      } catch (exception) {
        print("sync_queues_cubit startFetching task exception:\n $exception");
        checkForInternetAndFetch(calledDueToError: true);
      }
    } else {
      print("no tasks to sync");
    }
  }

  @override
  SyncQueuesState? fromJson(Map<String, dynamic> json) {
    return SyncQueuesState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SyncQueuesState state) {
    return state.toMap();
  }
}
