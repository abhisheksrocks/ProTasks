import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/data_providers/chats_dao.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/modal_sheet_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/task_details_modal_sheet_specific/task_chat_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/task_details_modal_sheet_specific/task_details_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/task_details_modal_sheet_specific/task_sub_tasks_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/widgets/tab_bar_tab.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/widgets/tab_bar_views/tab_bar_view_chat/tab_bar_view_chat.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/widgets/tab_bar_views/tab_bar_view_details/tab_bar_view_details.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/widgets/tab_bar_views/tab_bar_view_stats/tab_bar_view_stats.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/widgets/tab_bar_views/tab_bar_view_sub_tasks/tab_bar_view_sub_tasks.dart';
// import 'package:protasks/presentation/screens/task_details_modal_sheet/widgets/tab_bar_views/tab_bar_view_attachments/tab_bar_view_attachments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskDetailsModalSheetProvider extends StatefulWidget {
  final Task task;
  const TaskDetailsModalSheetProvider({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  _TaskDetailsModalSheetProviderState createState() =>
      _TaskDetailsModalSheetProviderState();
}

class _TaskDetailsModalSheetProviderState
    extends State<TaskDetailsModalSheetProvider> {
  // TODO: USE "with SingleTickerProviderStateMixin" when using TabController
  // with SingleTickerProviderStateMixin {

  // late TabController _tabController;

  @override
  void initState() {
    // TODO: MAKE THE LENGTH DYNAMIC WHEN INTRODUCED ATTACHMENTS
    // _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }
  // USE THIS WHEN USING ATTACHMENTS

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ** USE THIS AFTER ADDING ATTACHMENT **
        // BlocProvider<TabControllerCubit>(
        //   create: (context) => TabControllerCubit(
        //     tabController: _tabController,
        //   ),
        // ),
        // *******************************************

        BlocProvider<TextEditingControllerCubit>(
          create: (context) => TextEditingControllerCubit(),
        ),

        BlocProvider<KeyboardVisibilityWithFocusNodeCubit>(
          create: (context) => KeyboardVisibilityWithFocusNodeCubit(),
        ),

        BlocProvider<SingleTaskDetailsCubit>(
          create: (context) => SingleTaskDetailsCubit(task: widget.task),
          lazy: false,
        ),
        BlocProvider<ModalSheetCubit>(
          create: (context) => ModalSheetCubit(),
          lazy: false,
        ),
        BlocProvider<TaskChatCubit>(
          create: (context) => TaskChatCubit(
            taskID: widget.task.id,
          ),
          lazy: false,
        ),
        BlocProvider<TaskSubTasksCubit>(
          create: (context) => TaskSubTasksCubit(
            taskID: widget.task.id,
          ),
          lazy: false,
        ),
      ],
      child: TaskDetailsModalSheetEntry(
        taskId: widget.task.id,
      ),
    );
  }
}

class TaskDetailsModalSheetEntry extends StatelessWidget {
  final String taskId;
  const TaskDetailsModalSheetEntry({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  final Duration animationDuration = const Duration(milliseconds: 500);
  final Curve animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        bool isExpanded = context.watch<ModalSheetCubit>().state.isExpanded;
        double screenSize = context.watch<MediaQueryCubit>().state.size.height;
        double paddingTop = context.read<MediaQueryCubit>().state.padding.top;
        final ChatsDao chatsDaoObject = ChatsDao();
        final TasksDao tasksDaoObject = TasksDao();
        return AnimatedContainer(
          duration: animationDuration,
          curve: animationCurve,
          height: isExpanded ? screenSize : screenSize * 0.6,
          color: Theme.of(context).backgroundColor,
          child: DefaultTabController(
            // TODO: REMOVE THIS WIDGET WHEN INTRODUCING ATTACHMENT TAB AND USE WHOLE(INCLUDING PARENT WIDGET AT TOP) FILE'S COMMENTED CODES INSTEAD
            length: 4,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: animationDuration,
                  curve: animationCurve,
                  padding: EdgeInsets.only(
                    top: isExpanded ? paddingTop : 0,
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          // controller:
                          //     context.read<TabControllerCubit>().tabController,
                          // ************************************
                          // FOR INDICATOR AS BACKGROUND
                          // ************************************
                          // labelPadding: EdgeInsets.symmetric(
                          //   horizontal: kTabLabelPadding.left,
                          //   vertical: kTabLabelPadding.left - 3,
                          // ),
                          // indicatorWeight: 0,
                          // indicator: BoxDecoration(
                          //   color: Theme.of(context).backgroundColor,
                          // ),
                          // ************************************
                          isScrollable: true,

                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorColor: Colors.white,
                          physics: BouncingScrollPhysics(),
                          tabs: [
                            const TabBarTab(tabName: Strings.tabDetails),
                            Row(
                              children: [
                                (context
                                            .watch<LoginCubit>()
                                            .state
                                            .currentLoginState ==
                                        CurrentLoginState.loggedIn)
                                    ? const TabBarTab(tabName: Strings.tabChat)
                                    : const TabBarTab(
                                        tabName: Strings.tabChatAlternate),
                                StreamBuilder<int>(
                                    stream: chatsDaoObject
                                        .findUnreadChatCount(taskId),
                                    initialData:
                                        ChatsDao.taskUnreadCount[taskId],
                                    builder: (context, snapshot) {
                                      if (snapshot.data == null ||
                                          snapshot.data == 0) {
                                        return const SizedBox();
                                      }
                                      return Container(
                                        constraints:
                                            const BoxConstraints(maxHeight: 16),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        child: Center(
                                            child: Text(" ${snapshot.data} ")),
                                      );
                                    })
                              ],
                            ),
                            Row(
                              children: [
                                const TabBarTab(tabName: Strings.tabSubTasks),
                                StreamBuilder<int>(
                                    stream:
                                        tasksDaoObject.findSubtaskCount(taskId),
                                    initialData:
                                        TasksDao.taskSubtasksCount[taskId],
                                    builder: (context, snapshot) {
                                      if (snapshot.data == null ||
                                          snapshot.data == 0) {
                                        return const SizedBox();
                                      }
                                      return Container(
                                        constraints:
                                            const BoxConstraints(maxHeight: 16),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        child: Center(
                                          child: Text(" ${snapshot.data} "),
                                        ),
                                      );
                                    })
                              ],
                            ),
                            // const TabBarTab(tabName: Strings.tabAttachments),
                            const TabBarTab(tabName: Strings.tabStats),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Theme.of(context).backgroundColor,
                                width: 2,
                              ),
                            ),
                            color: Colors.transparent,
                          ),
                          child: IconButton(
                            icon: AnimatedSwitcher(
                              duration: animationDuration,
                              child: isExpanded
                                  ? Icon(
                                      Icons.transit_enterexit_rounded,
                                      color: Colors.white,
                                      key: ValueKey('Icon1'),
                                    )
                                  : Icon(
                                      Icons.open_in_new_rounded,
                                      color: Colors.white,
                                      key: ValueKey('Icon2'),
                                    ),
                            ),
                            onPressed: () {
                              context.read<ModalSheetCubit>().changeExpanded();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: BouncingScrollPhysics(),

                    // controller:
                    //     context.read<TabControllerCubit>().tabController,
                    children: [
                      TabBarViewDetails(),
                      TabBarViewChat(),
                      // Center(
                      //   child: Text('3'),
                      // ),
                      // TabBarViewAttachments(),
                      TabBarViewSubTasks(),
                      TabBarViewStats(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
