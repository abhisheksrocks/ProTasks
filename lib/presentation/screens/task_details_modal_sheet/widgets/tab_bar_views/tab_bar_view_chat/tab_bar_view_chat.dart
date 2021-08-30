import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/data/data_providers/chats_dao.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/chat.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/task_details_modal_sheet_specific/task_details_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/task_details_modal_sheet_specific/task_chat_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/widgets/user_name_widget.dart';
import 'package:flutter/material.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';

class TabBarViewChat extends StatefulWidget {
  @override
  _TabBarViewChatState createState() => _TabBarViewChatState();
}

class _TabBarViewChatState extends State<TabBarViewChat>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Duration _allAnimationDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    context
        .read<TextEditingControllerCubit>()
        .beginFetching(newTextEditingController: _textEditingController);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          context.read<MediaQueryCubit>().state.size.height) {
        context.read<TaskChatCubit>().startFetching();
      }
    });
    ChatsDao().markAllChatAsRead(taskId: context.read<TaskChatCubit>().taskID);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<TaskChatCubit, TaskChatState>(
      builder: (context, state) {
        final _taskChatCubit = context.read<TaskChatCubit>();
        ChatsDao()
            .markAllChatAsRead(taskId: context.read<TaskChatCubit>().taskID);
        List<Chat> _chatList = _taskChatCubit.chatToShow;
        return Column(
          children: [
            Expanded(
              child:
                  // Stack(
                  //   alignment: Alignment.topLeft,
                  //   children: [
                  ListView.builder(
                reverse: true,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: const AlwaysScrollableScrollPhysics(),
                ),
                itemCount: _chatList.length,
                itemBuilder: (context, index) {
                  Chat _currentChat = _chatList[index];
                  String _userID = _currentChat.fromUID;
                  bool _isMe = _userID ==
                      (FirebaseAuthFunctions.getCurrentUser?.uid ??
                          Strings.defaultUserUID);
                  double _maxWidth =
                      context.read<MediaQueryCubit>().state.size.width * 0.75;
                  bool _showDate = true;
                  bool _isLast = true;
                  bool _isFirst = true;
                  bool _showTime = false;

                  if (index > 0) {
                    if (_chatList[index - 1].fromUID != _currentChat.fromUID) {
                      _isLast = true;
                    } else {
                      _isLast = false;
                    }
                    if (_chatList[index]
                        .time
                        .add(Duration(minutes: 1))
                        .isBefore(_chatList[index - 1].time)) {
                      _showTime = true;
                    }
                  }
                  if (index < _chatList.length - 1) {
                    if (ExtraFunctions.findJustDateWithoutTime(
                            _currentChat.time) ==
                        ExtraFunctions.findJustDateWithoutTime(
                            _chatList[index + 1].time)) {
                      _showDate = false;
                    }
                    if (_currentChat.fromUID != _chatList[index + 1].fromUID) {
                      _isFirst = true;
                    } else {
                      _isFirst = false;
                    }
                  }

                  // -------- Border Radius for Reply(over normal) ---------
                  const Radius _replyOverNormalGeneralRadius =
                      const Radius.circular(8);
                  const BorderRadius _replyOverNormalChatBorderRadius =
                      BorderRadius.all(_replyOverNormalGeneralRadius);
                  // -------------------------------------------------------

                  // -------- Border Radius for General Chat ----------------
                  const Radius normalChatGeneralRadius =
                      const Radius.circular(16);
                  const Radius normalChatDifferentialRadius =
                      const Radius.circular(4);
                  final BorderRadius _normalChatBorderRadius =
                      BorderRadius.only(
                    topLeft: normalChatGeneralRadius,
                    topRight: normalChatGeneralRadius,
                    bottomLeft:
                        // _isLast
                        //     ?
                        _isMe
                            ? normalChatGeneralRadius
                            : normalChatDifferentialRadius
                    // : normalChatGeneralRadius
                    ,
                    bottomRight:
                        // _isLast
                        //     ?
                        _isMe
                            ? normalChatDifferentialRadius
                            : normalChatGeneralRadius
                    // : normalChatGeneralRadius
                    ,
                  );
                  // ------------------------------------------------

                  return Column(
                    children: [
                      if (_showDate)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            ExtraFunctions.findRelativeDateOnly(
                              date: _currentChat.time,
                              checkForToday: true,
                              checkForTomorrow: false,
                              checkForYesterday: true,
                            ),
                            // ExtraFunctions.findTodayTomorrowOrYesterday(
                            //       _currentChat.time,
                            //       checkForToday: true,
                            //       checkForTomorrow: false,
                            //       checkForYesterday: true,
                            //     ) ??
                            //     "${DateFormat("dd MMM y").format(_currentChat.time)}",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: Strings.primaryFontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // child: ExtraFunctions.findTodayTomorrowOrYesterday(),
                        ),
                      // Material(
                      //   color: _taskChatCubit.selectedChats
                      //           .contains(_currentChat.id)
                      //       ? Colors.grey.withOpacity(0.3)
                      //       : Colors.transparent,
                      //   // color: index % 2 == 0
                      //   //     ? Colors.transparent
                      //   //     : Colors.grey.withOpacity(0.3),
                      //   // child: InkWell(
                      //   //   onTap: () {
                      //   //     if (_taskChatCubit.selectedChats.isNotEmpty)
                      //   //       _taskChatCubit
                      //   //           .updateSelected(_currentChat.id);
                      //   //   },
                      //   //   onLongPress: () {
                      //   //     // if (_taskChatCubit.selectedChats.isEmpty)
                      //   //     _taskChatCubit.updateSelected(_currentChat.id);
                      //   //   },
                      //   child:
                      Column(
                        crossAxisAlignment: _isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          SwipeTo(
                            onRightSwipe: () {
                              _taskChatCubit.updateReplyingTo(_currentChat.id);
                              // showKeyboard(context);
                              context
                                  .read<KeyboardVisibilityWithFocusNodeCubit>()
                                  .showKeyboard();
                            },
                            child: Align(
                              alignment: _isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,

                              // LEFT - RIGHT SPACE BETWEEN THE EDGES
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 2,
                                      top: 2,
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Material(
                                      color: _isMe
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .chatBackgroundColor,
                                      borderRadius: _normalChatBorderRadius,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: _maxWidth,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: _normalChatBorderRadius,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // MESSAGE SENDING USER
                                            if ((_isFirst) &&
                                                // if ((_isFirst || _showTime) &&
                                                !_isMe)
                                              FutureBuilder<List<String>>(
                                                  future: UsersDao()
                                                      .getUserNamesFromIDs(
                                                          [_userID]),
                                                  builder: (context, snapshot) {
                                                    return AutoSizeText(
                                                      '${UsersDao.usersIdToName[_userID] ?? 'Loading⌛'}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: Strings
                                                            .primaryFontFamily,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  }),

                                            // REPLY MESSAGE FETCHER
                                            if (_currentChat.replyToChatId !=
                                                Strings.noChatID)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 4,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      _replyOverNormalChatBorderRadius,
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      border: Border(
                                                        left: BorderSide(
                                                          width: 4,
                                                          color: _isMe
                                                              ? Colors.white
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                    ),

                                                    // width: double.infinity,
                                                    child: FutureBuilder<Chat?>(
                                                      future: _taskChatCubit
                                                          .fetchChatFromID(
                                                              _currentChat
                                                                  .replyToChatId),
                                                      builder:
                                                          (context, snapshot) {
                                                        Chat? chatToShow =
                                                            _taskChatCubit
                                                                        .replyChatMap[
                                                                    _currentChat
                                                                        .replyToChatId] ??
                                                                snapshot.data;
                                                        if (snapshot.connectionState ==
                                                                ConnectionState
                                                                    .waiting &&
                                                            chatToShow ==
                                                                null) {
                                                          return const Text(
                                                              'Loading⌛');
                                                        }
                                                        if (chatToShow !=
                                                            null) {
                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // REPLY MESSAGE USERNAME
                                                              UserNameWidget(
                                                                userUID:
                                                                    chatToShow
                                                                        .fromUID,
                                                                textScaleFactor:
                                                                    0.9,
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      Strings
                                                                          .primaryFontFamily,
                                                                  fontWeight: chatToShow
                                                                              .fromUID ==
                                                                          (FirebaseAuthFunctions.getCurrentUser?.uid ??
                                                                              Strings
                                                                                  .defaultUserUID)
                                                                      ? FontWeight
                                                                          .w800
                                                                      : FontWeight
                                                                          .w500,
                                                                  color: _isMe
                                                                      ? Colors
                                                                          .white
                                                                      : Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyText1!
                                                                          .color,
                                                                ),
                                                              ),

                                                              // REPLY MESSAGE CONTENT
                                                              Text(
                                                                chatToShow
                                                                    .messageContent,
                                                                textScaleFactor:
                                                                    0.9,
                                                                style:
                                                                    TextStyle(
                                                                  color: _isMe
                                                                      ? Colors
                                                                          .white
                                                                      : Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyText1!
                                                                          .color,
                                                                  fontFamily:
                                                                      Strings
                                                                          .secondaryFontFamily,
                                                                  fontSize: 16,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 2,
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'INVALID_USER',
                                                              textScaleFactor:
                                                                  0.9,
                                                            ),
                                                            const Text(
                                                                'iNVALID_MESSAGE'),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            // MAIN MESSAGE CONTENT
                                            Text(
                                              _currentChat.messageContent,
                                              style: TextStyle(
                                                color: _isMe
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .textTheme
                                                        .bodyText1!
                                                        .color,
                                                fontFamily:
                                                    Strings.secondaryFontFamily,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isMe)
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      switchInCurve: Curves.easeOut,
                                      switchOutCurve: Curves.easeOut,
                                      transitionBuilder: (child, animation) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: Offset(1, 0),
                                            end: Offset(0, 0),
                                          ).animate(animation),
                                          child: child,
                                        );
                                      },
                                      child: _currentChat.isSynced
                                          ? SizedBox()
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 2,
                                                right: 2,
                                              ),
                                              child: Icon(
                                                Icons.access_time,
                                                size: 16,
                                              ),
                                            ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_isLast || _showTime)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 4,
                                left: 8,
                                right: 8,
                              ),
                              child: Text(
                                DateFormat("HH:mm a").format(_currentChat.time),
                              ),
                            ),
                        ],
                      ),
                      // ),
                      // ),
                    ],
                  );
                },
              ),
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: AnimatedSwitcher(
              //         duration: _allAnimationDuration,
              //         transitionBuilder: (child, animation) {
              //           return ScaleTransition(
              //             // TODO: NOTE THE [end], MAYBE CHANGE THE ICON SIZE ONLY
              //             scale: Tween<double>(begin: 0, end: 1)
              //                 .chain(CurveTween(curve: Curves.easeInOut))
              //                 .animate(animation),
              //             child: child,
              //           );
              //         },
              //         child: _taskChatCubit.selectedChats.length != 0
              //             ? ClipRRect(
              //                 borderRadius: BorderRadius.circular(4),
              //                 child: Material(
              //                   color: Theme.of(context).primaryColor,
              //                   type: MaterialType.button,
              //                   child: IconButton(
              //                     icon: Icon(
              //                       Icons.copy_rounded,
              //                       color: Colors.white,
              //                     ),
              //                     // TODO: Copy the selected chat messages
              //                     onPressed: () {},
              //                   ),
              //                 ),
              //               )
              //             : SizedBox(),
              //       ),
              //     ),
              //   ],
              // ),
            ),
            Container(
              color: Theme.of(context).chatTextFieldColor,
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      final _taskChatCubit = context.read<TaskChatCubit>();
                      Chat? _replyingToChat = _taskChatCubit.replyingToChat;
                      return AnimatedSwitcher(
                        // TODO: DO CHECK WITH MULTIPLE release.apk THAT THIS DURATION SEEMS OKAY OR TOO MUCH, 600 SEEMS A TAD BIT MUCH
                        duration: const Duration(milliseconds: 600),
                        reverseDuration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return SizeFadeTransition(
                            animation: animation,
                            curve: Curves.easeInOut,
                            sizeFraction: 0.3,
                            child: child,
                          );
                        },
                        child: _replyingToChat != null
                            ? Container(
                                margin: const EdgeInsets.only(
                                  top: 8,
                                  left: 8,
                                  right: 8,
                                  bottom: 4,
                                ),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  border: Border(
                                    left: const BorderSide(
                                      width: 4,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          UserNameWidget(
                                            userUID: _replyingToChat.fromUID,
                                            textScaleFactor: 0.9,
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontFamily:
                                                  Strings.primaryFontFamily,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color,
                                            ),
                                          ),
                                          Text(
                                            _replyingToChat.messageContent,
                                            textScaleFactor: 0.9,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color,
                                              fontFamily:
                                                  Strings.secondaryFontFamily,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Material(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color!
                                          .withOpacity(0.12),
                                      child: IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          _taskChatCubit.removeReplyingTo();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                      );
                    },
                  ),
                  AbsorbPointer(
                    absorbing: (context.read<SingleTaskDetailsCubit>().state
                            as SingleTaskDetailsLoaded)
                        .currentTask
                        .isDeleted,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                // top: 8,
                                // bottom: 14,
                                left: 12,
                                right: 8,
                              ),
                              child: Align(
                                child: TextField(
                                  focusNode: context
                                      .read<
                                          KeyboardVisibilityWithFocusNodeCubit>()
                                      .getFocusNode,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: _textEditingController,
                                  scrollPhysics: BouncingScrollPhysics(),
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 6,
                                  style: TextStyle(
                                    fontFamily: Strings.secondaryFontFamily,
                                  ),
                                  decoration: InputDecoration.collapsed(
                                    hintText: "Write the message...",
                                    hintStyle: TextStyle(
                                      fontFamily: Strings.secondaryFontFamily,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Material(
                            type: MaterialType.button,
                            color: Colors.grey.withOpacity(0.2),
                            child: BlocBuilder<TextEditingControllerCubit,
                                TextEditingControllerState>(
                              // ******* THIS CUBIT ONLY CHECKS IF field text IS EMPTY *******

                              builder: (context, state) {
                                return InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Icon(
                                      Icons.send,
                                      size: 32,
                                      color: state.textString.isEmpty
                                          ? Theme.of(context).disabledColor
                                          : null,
                                      key: ValueKey("send"),
                                    ),
                                  ),
                                  onTap: state.textString.isEmpty
                                      ? null
                                      : () async {
                                          String messageToSend =
                                              _textEditingController.text
                                                  .trim();

                                          print(
                                            "Message to send: $messageToSend",
                                          );

                                          await _taskChatCubit
                                              .addNewChatMessage(
                                            messageType: MessageType.text,
                                            messageContent: messageToSend,
                                          );
                                          _taskChatCubit.removeReplyingTo();
                                          _textEditingController.clear();
                                        },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
