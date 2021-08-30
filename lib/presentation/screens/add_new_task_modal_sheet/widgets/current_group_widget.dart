import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_group_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/group_search_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';

import 'package:flutter/material.dart';

import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentGroupWidget extends StatefulWidget {
  const CurrentGroupWidget({Key? key}) : super(key: key);

  @override
  _CurrentGroupWidgetState createState() => _CurrentGroupWidgetState();
}

class _CurrentGroupWidgetState extends State<CurrentGroupWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext groupWidgetContext) {
    return BlocBuilder<CurrentGroupCubit, CurrentGroupState>(
      builder: (context, state) {
        bool isEnabled = false;
        String nameToShow = "No Groups Created";
        if (state is CurrentGroupLoaded) {
          isEnabled = true;
          nameToShow = state.currentGroup.name;
        }
        return IntrinsicWidth(
          child: Material(
            color: Theme.of(context).taskGroupColor,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: isEnabled &&
                      context.read<CurrentGroupCubit>().isGroupChangeAllowed
                  ? () async {
                      showDialog(
                        context: groupWidgetContext,
                        builder: (context) {
                          final TextEditingController
                              _groupSearchTextEditingController =
                              new TextEditingController();

                          final BorderRadius _contentBorderRadius =
                              BorderRadius.circular(4);

                          final BorderRadius _dialogBorderRadius =
                              BorderRadius.circular(4);

                          final double mediaQueryHeight =
                              context.read<MediaQueryCubit>().state.size.height;

                          final double mediaQueryWidth =
                              context.read<MediaQueryCubit>().state.size.width;

                          final double maxScreenHeight =
                              (mediaQueryHeight > mediaQueryWidth)
                                  ? mediaQueryHeight
                                  : mediaQueryWidth;

                          return MultiBlocProvider(
                            providers: [
                              BlocProvider<TextEditingControllerCubit>(
                                create: (context) =>
                                    TextEditingControllerCubit()
                                      ..beginFetching(
                                        newTextEditingController:
                                            _groupSearchTextEditingController,
                                        newStateEveryCharacter: true,
                                      ),
                              ),
                              BlocProvider<GroupSearchCubit>(
                                create: (context) => GroupSearchCubit(),
                              ),
                            ],
                            child: Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: _dialogBorderRadius,
                              ),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  borderRadius: _dialogBorderRadius,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                constraints: BoxConstraints(
                                  maxHeight: maxScreenHeight * 0.6,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SELECT GROUP',
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    IntrinsicHeight(
                                      child: ClipRRect(
                                        borderRadius: _contentBorderRadius,
                                        child: Material(
                                          color: Theme.of(context)
                                              .primaryTextColor
                                              .withOpacity(0.1),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                        ),
                                                        child:
                                                            Icon(Icons.search),
                                                      ),
                                                      Expanded(
                                                        child: TextField(
                                                          controller:
                                                              _groupSearchTextEditingController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          style: TextStyle(
                                                            fontFamily: Strings
                                                                .secondaryFontFamily,
                                                          ),
                                                          decoration:
                                                              InputDecoration
                                                                  .collapsed(
                                                            hintText:
                                                                "Search...",
                                                            hintStyle:
                                                                TextStyle(
                                                              fontFamily: Strings
                                                                  .secondaryFontFamily,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.filter_list,
                                                ),
                                                onPressed: () {},
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Expanded(
                                      child: BlocBuilder<
                                          TextEditingControllerCubit,
                                          TextEditingControllerState>(
                                        builder: (context, state) {
                                          final _groupSearchCubit =
                                              context.watch<GroupSearchCubit>();

                                          _groupSearchCubit.searchGroup(
                                            searchQuery:
                                                _groupSearchTextEditingController
                                                    .text,
                                          );

                                          final currentGroupCubitState =
                                              groupWidgetContext
                                                  .read<CurrentGroupCubit>()
                                                  .state;
                                          return ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            itemCount: _groupSearchCubit
                                                .state.groupToShow.length,
                                            itemBuilder: (context, index) {
                                              bool selected = false;

                                              if (currentGroupCubitState
                                                  is CurrentGroupLoaded) {
                                                selected = _groupSearchCubit
                                                        .state.groupToShow
                                                        .elementAt(index)
                                                        .id ==
                                                    currentGroupCubitState
                                                        .currentGroup.id;
                                              }

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 2.0,
                                                ),
                                                child: Material(
                                                  color: selected
                                                      ? Theme.of(context)
                                                          .accentColor
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      _contentBorderRadius,
                                                  child: ListTile(
                                                    title: Text(
                                                      _groupSearchCubit
                                                          .state.groupToShow
                                                          .elementAt(index)
                                                          .name,
                                                      style: TextStyle(
                                                        color: selected
                                                            ? Colors.white
                                                            : Theme.of(context)
                                                                .primaryTextColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      if (!selected) {
                                                        groupWidgetContext
                                                            .read<
                                                                CurrentGroupCubit>()
                                                            .changeCurrentGroup(
                                                              newGroup:
                                                                  _groupSearchCubit
                                                                      .state
                                                                      .groupToShow
                                                                      .elementAt(
                                                                          index),
                                                              isForced: true,
                                                            );
                                                      }
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          _contentBorderRadius,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  : null,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        '$nameToShow',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
