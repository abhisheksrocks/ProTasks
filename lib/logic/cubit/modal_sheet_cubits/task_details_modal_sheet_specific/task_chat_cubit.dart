import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/models/chat.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:meta/meta.dart';

import 'package:protasks/data/data_providers/chats_dao.dart';

part 'task_chat_state.dart';

class TaskChatCubit extends Cubit<TaskChatState> {
  final String taskID;
  final ChatsDao _chatsDao = ChatsDao();
  StreamSubscription? _streamSubscription;
  bool _canLoadMoreOldMessages = true;
  List<Chat> chatToShow = [];
  Map<String, Chat?> replyChatMap = {};
  List<String> selectedChats = [];
  Chat? replyingToChat;
  int limit = 10;

  // INTERNAL
  bool isLoading = false;

  // final Duration _updateInterval = Duration(seconds: 10);
  TaskChatCubit({
    required this.taskID,
  }) : super(TaskChatLoading()) {
    startFetching();
    fetchLatestMessageAsStream();
    // periodicallyFetchLatestChatMessage();
  }

  void fetchLatestMessageAsStream() {
    _streamSubscription = _chatsDao
        .fetchLatestChatStreamFromTaskIDs(taskID: taskID, limit: 1)
        .listen((listOfChat) {
      print("New element adding");
      _addNewListAndSort(listOfChat);
      emit(TaskChatLoaded());
    });
  }

  void _addNewListAndSort(List<Chat> newListToAdd) {
    newListToAdd.forEach((element) {
      chatToShow.removeWhere((chatElement) => chatElement.id == element.id);
      chatToShow.add(element);
    });
    // print("newListToAdd: $newListToAdd");
    // print("old chatToShow length: ${chatToShow.length}");
    // print("new chatToShow length: ${chatToShow.length}");
    // print(chatToShow);

    // chatToShow.insertAll(
    //   insertToFront ? 0 : chatToShow.length,
    //   newListToAdd,
    // );
    chatToShow.sort((a, b) {
      return b.time.compareTo(a.time);
    });
  }

  void startFetching() async {
    if (!_canLoadMoreOldMessages) {
      return;
    }
    if (isLoading) {
      return;
    }

    isLoading = true;
    List<Chat> _chatList = [];

    if (chatToShow.isEmpty) {
      _chatList = await _chatsDao.fetchChatsFromTaskID(
        taskID: taskID,
        limit: limit,
      );
    } else {
      _chatList = await _chatsDao.fetchChatsFromTaskID(
        taskID: taskID,
        findMore: true,
        limit: limit,
      );
    }
    isLoading = false;
    if (_chatList.length < 10) {
      print("Can't load any more old messages");
      _canLoadMoreOldMessages = false;
    }
    if (_chatList.isNotEmpty) {
      _addNewListAndSort(_chatList);
      emit(TaskChatLoaded());
      return;
    }
    if (state is TaskChatLoading) {
      emit(TaskChatLoaded());
    }
  }

  // Future fetchLatestMessages() async {
  //   List<Chat> _chatList =
  //       await _chatsDao.fetchLatestChatFromTaskIDs(taskID: taskID);
  //   if (_chatList.isNotEmpty) {
  //     print("New message detected");
  //     _addNewListAndSort(_chatList, true);
  //     emit(TaskChatLoaded());
  //   }
  // }

  // void periodicallyFetchLatestChatMessage() async {
  //   Timer.periodic(_updateInterval, (_) async {
  //     await fetchLatestMessages();
  //   });
  // }

  Future<Chat?> fetchChatFromID(String chatID) async {
    try {
      Chat chat = chatToShow.firstWhere((element) => element.id == chatID);
      replyChatMap[chatID] = chat;
      return chat;
    } on Exception catch (_) {
      print("ChatID not found in current list. Looking in Database");
    }

    Chat? chat = await _chatsDao.findChatFromChatID(chatID);
    if (chat == null) {
      return null;
    }
    replyChatMap[chatID] = chat;
    return chat;
  }

  void updateSelected(String chatID) {
    if (selectedChats.contains(chatID)) {
      selectedChats.remove(chatID);
    } else {
      selectedChats.add(chatID);
    }
    emit(TaskChatLoaded());
  }

  void removeReplyingTo() {
    if (replyingToChat != null) {
      replyingToChat = null;
      emit(TaskChatLoaded());
    }
  }

  void updateReplyingTo(String chatID) {
    if (replyingToChat != null) {
      if (replyingToChat!.id == chatID) {
        return;
      }
    }
    replyingToChat = chatToShow.firstWhere((eachChat) => eachChat.id == chatID);

    emit(TaskChatLoaded());
  }

  Future addNewChatMessage({
    required MessageType messageType,
    required String messageContent,
  }) async {
    Chat _chatMessageToAdd = Chat(
      id: ExtraFunctions.createId,
      refId: taskID,
      time: DateTime.now(),
      isSeen: true,
      messageType: messageType,
      fromUID:
          FirebaseAuthFunctions.getCurrentUser?.uid ?? Strings.defaultUserUID,
      messageContent: messageContent,
      replyToChatId: replyingToChat?.id ?? Strings.noChatID,
      isSynced: false,
    );
    // _addNewListAndSort([_chatMessageToAdd], true);
    chatToShow.insert(0, _chatMessageToAdd);
    await _chatsDao.insertOrUpdateChat(_chatMessageToAdd);
    emit(new TaskChatLoaded());
    // chatToShow.remove(_chatMessageToAdd);
    // await fetchLatestMessages();
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
