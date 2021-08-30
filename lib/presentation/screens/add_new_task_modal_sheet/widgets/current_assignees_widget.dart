import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/assigness_search_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_assignees_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_group_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/select_people/dialog_search_bar.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/select_people/person_icon.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/select_people/person_name.dart';
import 'package:protasks/presentation/common_widgets/my_button.dart';
import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentAssigneesWidget extends StatelessWidget {
  const CurrentAssigneesWidget({
    Key? key,
    required this.buttonIconSize,
  }) : super(key: key);

  final double buttonIconSize;

  @override
  Widget build(BuildContext assigneesContext) {
    return BlocBuilder<CurrentAssigneesCubit, CurrentAssigneesState>(
      builder: (context, state) {
        return MyButton(
          icon: Icon(
            Icons.alternate_email,
            size: buttonIconSize,
            color: const Color(0xFFFFFFFF),
          ),
          label: (state is CurrentAssigneesLoaded &&
                  state.currentAssigness.isNotEmpty)
              ? FutureBuilder<Person?>(
                  future: UsersDao().getUserFromUserID(
                    userIDtoSearch: state.currentAssigness.elementAt(0),
                  ),
                  builder: (context, snapshot) {
                    String textToShow;
                    if (state.currentAssigness
                        .contains(FirebaseAuthFunctions.getCurrentUser!.uid)) {
                      textToShow = "You";
                      if (state.currentAssigness.length > 1) {
                        textToShow =
                            "$textToShow + ${ExtraFunctions.stringToAppendWith(unitValue: state.currentAssigness.length - 1, unitString: "other")}";
                      }
                    } else {
                      if (snapshot.hasData) {
                        textToShow =
                            '${snapshot.data?.name ?? snapshot.data?.email ?? snapshot.data?.uid}';
                        if (state.currentAssigness.length > 1) {
                          textToShow =
                              "$textToShow + ${ExtraFunctions.stringToAppendWith(unitValue: state.currentAssigness.length - 1, unitString: "other")}";
                        }
                      } else {
                        textToShow =
                            "${ExtraFunctions.stringToAppendWith(unitValue: state.currentAssigness.length, unitString: "assignee")}";
                      }
                    }

                    return Text(
                      "$textToShow",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFFFFFF),
                      ),
                    );
                  },
                )
              : null,
          onTap: (state is CurrentAssigneesLoaded)
              ? () async {
                  final CurrentAssigneesState _currentAssigneesState =
                      assigneesContext.read<CurrentAssigneesCubit>().state;

                  List<String> _listOfDefaultAssignees = [];

                  if (_currentAssigneesState is CurrentAssigneesLoaded) {
                    _listOfDefaultAssignees =
                        _currentAssigneesState.currentAssigness;
                  }
                  
                  
                  
                  final CurrentAssigneesState? newAssignessState =
                      await showDialog<CurrentAssigneesState?>(
                    context: assigneesContext,
                    builder: (context) {
                      
                      

                      final TextEditingController
                          _assigneesSearchTextEditingController =
                          TextEditingController();

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
                          BlocProvider<AssignessSearchCubit>(
                            create: (context) => AssignessSearchCubit(
                              currentGroupCubit:
                                  assigneesContext.read<CurrentGroupCubit>(),
                            ),
                          ),
                          BlocProvider<TextEditingControllerCubit>(
                            create: (context) => TextEditingControllerCubit()
                              ..beginFetching(
                                newTextEditingController:
                                    _assigneesSearchTextEditingController,
                                newStateEveryCharacter: true,
                              ),
                          ),
                          BlocProvider<CurrentAssigneesCubit>(
                            create: (context) => CurrentAssigneesCubit(
                              currentGroupCubit:
                                  assigneesContext.read<CurrentGroupCubit>(),
                            )..updateAssigneesWithUserIDList(
                                _listOfDefaultAssignees),
                          ),
                        ],
                        child: Dialog(
                          backgroundColor: Theme.of(context).backgroundColor,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            constraints: BoxConstraints(
                              maxHeight: maxScreenHeight * 0.6,
                            ),
                            width: double.infinity,
                            child: BlocBuilder<TextEditingControllerCubit,
                                TextEditingControllerState>(
                              builder: (context, state) {
                                final _assignessSearchCubit =
                                    context.watch<AssignessSearchCubit>();
                                

                                final currentAssigneesCubit =
                                    
                                    context.watch<CurrentAssigneesCubit>();

                                late CurrentAssigneesLoaded
                                    currentAssigneesLoadedState;

                                if (currentAssigneesCubit.state
                                    is CurrentAssigneesLoading) {
                                  Navigator.of(context).pop();
                                } else {
                                  currentAssigneesLoadedState =
                                      (currentAssigneesCubit.state
                                          as CurrentAssigneesLoaded);
                                }

                                _assignessSearchCubit.searchAssignees(
                                  searchQuery:
                                      _assigneesSearchTextEditingController
                                          .text,
                                );

                                List<Person> usersToShow =
                                    _assignessSearchCubit.state.usersToShow;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SELECT ASSIGNEES',
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    DialogSearchBar(
                                      textEditingController:
                                          _assigneesSearchTextEditingController,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: usersToShow.length,
                                        itemBuilder: (context, index) {
                                          bool _isMe = usersToShow
                                                  .elementAt(index)
                                                  .uid ==
                                              (FirebaseAuthFunctions
                                                      .getCurrentUser?.uid ??
                                                  Strings.defaultUserUID);
                                          return Row(
                                            children: [
                                              PersonIcon(),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (_isMe)
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: AutoSizeText(
                                                              "You",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontFamily: Strings
                                                                    .secondaryFontFamily,
                                                                
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (usersToShow
                                                                .elementAt(
                                                                    index)
                                                                .name !=
                                                            null &&
                                                        !_isMe)
                                                      PersonName(
                                                          stringToShow:
                                                              usersToShow
                                                                  .elementAt(
                                                                      index)
                                                                  .name!),
                                                    if (usersToShow
                                                            .elementAt(index)
                                                            .email !=
                                                        null)
                                                      PersonName(
                                                          stringToShow:
                                                              usersToShow
                                                                  .elementAt(
                                                                      index)
                                                                  .email!),
                                                    if (usersToShow
                                                                .elementAt(
                                                                    index)
                                                                .email ==
                                                            null &&
                                                        usersToShow
                                                                .elementAt(
                                                                    index)
                                                                .name ==
                                                            null)
                                                      PersonName(
                                                        stringToShow:
                                                            "User ${usersToShow.elementAt(index).uid}",
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              MyCircularCheckBox(
                                                value:
                                                    currentAssigneesLoadedState
                                                        .currentAssigness
                                                        .contains(
                                                  usersToShow
                                                      .elementAt(index)
                                                      .uid,
                                                ),
                                                onChanged: (value) {
                                                  currentAssigneesCubit
                                                      .updateAssginees(
                                                    usersToShow
                                                        .elementAt(index)
                                                        .uid,
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(CurrentAssigneesLoaded(
                                              currentGroupID: "DOESN'T MATTER",
                                              currentAssigness: [],
                                            ));
                                          },
                                          child: Text('Clear'),
                                        ),
                                        Spacer(),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(context
                                                  .read<CurrentAssigneesCubit>()
                                                  .state);
                                            },
                                            child: Text('OK')),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );

                  if (newAssignessState != null) {
                    if (newAssignessState is CurrentAssigneesLoaded) {
                      assigneesContext
                          .read<CurrentAssigneesCubit>()
                          .updateAssigneesWithUserIDList(
                            newAssignessState.currentAssigness,
                          );
                    }
                  }
                }
              : null,
        );
      },
    );
  }
}
