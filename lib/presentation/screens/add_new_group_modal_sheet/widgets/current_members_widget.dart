import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_group_modal_sheet_specific/current_members_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_group_modal_sheet_specific/members_search_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:protasks/logic/firebase_fstore_functions.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/select_people/dialog_search_bar.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/select_people/person_icon.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/select_people/person_name.dart';
import 'package:protasks/presentation/common_widgets/my_button.dart';
import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:protasks/logic/extra_extensions.dart';

import 'package:share_plus/share_plus.dart';

class CurrentMembersWidget extends StatelessWidget {
  const CurrentMembersWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext membersContext) {
    return BlocBuilder<CurrentMembersCubit, CurrentMembers>(
      builder: (context, state) {
        return MyButton(
          icon: Icon(
            Icons.person_add,
            size: 16,
            color: const Color(0xFFFFFFFF),
          ),
          label: state.members.isEmpty
              ? null
              : Builder(
                  builder: (context) {
                    String textToShow = state.members.first.name ??
                        state.members.first.email ??
                        'Unknown User';
                    if (state.members.length > 1) {
                      textToShow +=
                          ' + ${ExtraFunctions.stringToAppendWith(unitValue: state.members.length - 1, unitString: "other")}';
                    }
                    return Text(
                      "$textToShow",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFFFFFF),
                      ),
                    );
                  },
                ),
          onTap: () async {
            List<Person> _currentlySelectedMembers =
                membersContext.read<CurrentMembersCubit>().state.members;
            print("initiallySelectedMembers: ");
            CurrentMembers? returnedOutput = await showDialog(
              context: membersContext,
              builder: (context) {
                final TextEditingController
                    _membersSearchTextEditingController =
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
                    BlocProvider<MembersSearchCubit>(
                      create: (context) => MembersSearchCubit(),
                    ),
                    BlocProvider<TextEditingControllerCubit>(
                      create: (context) => TextEditingControllerCubit()
                        ..beginFetching(
                          newTextEditingController:
                              _membersSearchTextEditingController,
                          newStateEveryCharacter: true,
                        ),
                    ),
                    BlocProvider<CurrentMembersCubit>(
                      create: (context) => CurrentMembersCubit()
                        ..updateMembersWithList(
                            membersList: _currentlySelectedMembers),
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
                          final _membersSearchCubit =
                              context.watch<MembersSearchCubit>();

                          final currentMembersCubit =
                              context.watch<CurrentMembersCubit>();

                          _membersSearchCubit.searchWithQuery(
                            _membersSearchTextEditingController.text,
                          );

                          List<Person> usersToShow =
                              _membersSearchCubit.state.usersToShow;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SELECT MEMBERS',
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
                                    _membersSearchTextEditingController,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Expanded(
                                child: usersToShow.length > 0
                                    ? ListView.builder(
                                        itemCount: usersToShow.length,
                                        itemBuilder: (context, index) {
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
                                                    if (usersToShow
                                                            .elementAt(index)
                                                            .name !=
                                                        null)
                                                      PersonName(
                                                        stringToShow:
                                                            usersToShow
                                                                .elementAt(
                                                                    index)
                                                                .name!
                                                                .capitalize,
                                                      ),
                                                    if (usersToShow
                                                            .elementAt(index)
                                                            .email !=
                                                        null)
                                                      PersonName(
                                                        stringToShow:
                                                            usersToShow
                                                                .elementAt(
                                                                    index)
                                                                .email!
                                                                .toLowerCase(),
                                                      ),
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
                                                value: currentMembersCubit
                                                    .state.members
                                                    .contains(
                                                  usersToShow.elementAt(index),
                                                ),
                                                onChanged: (value) {
                                                  currentMembersCubit
                                                      .updateMember(
                                                    user: usersToShow
                                                        .elementAt(index),
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    : Builder(builder: (context) {
                                        if (context
                                                .read<LoginCubit>()
                                                .state
                                                .currentLoginState ==
                                            CurrentLoginState.loggedIn) {
                                          return FutureBuilder<List<Person>>(
                                            future: FirebaseFstoreFunctions()
                                                .findEmailOnCloud(
                                                    _membersSearchTextEditingController
                                                        .text
                                                        .trim()),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                print(
                                                    "snapshot.data: ${snapshot.data}");
                                                print("ConnectionState.done");
                                                if (snapshot.hasData &&
                                                    snapshot.data!.isNotEmpty) {
                                                  return ListView.builder(
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Row(
                                                        children: [
                                                          PersonIcon(),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                if (snapshot
                                                                        .data!
                                                                        .elementAt(
                                                                            index)
                                                                        .name !=
                                                                    null)
                                                                  PersonName(
                                                                    stringToShow: snapshot
                                                                        .data!
                                                                        .elementAt(
                                                                            index)
                                                                        .name!
                                                                        .capitalize,
                                                                  ),
                                                                if (snapshot
                                                                        .data!
                                                                        .elementAt(
                                                                            index)
                                                                        .email !=
                                                                    null)
                                                                  PersonName(
                                                                    stringToShow: snapshot
                                                                        .data!
                                                                        .elementAt(
                                                                            index)
                                                                        .email!
                                                                        .toLowerCase(),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                          MyCircularCheckBox(
                                                            value:
                                                                currentMembersCubit
                                                                    .state
                                                                    .members
                                                                    .contains(
                                                              snapshot.data!
                                                                  .elementAt(
                                                                      index),
                                                            ),
                                                            onChanged:
                                                                (value) async {
                                                              UsersDao()
                                                                  .insertOrUpdateUser(
                                                                snapshot.data!
                                                                    .elementAt(
                                                                        index),
                                                              );
                                                              currentMembersCubit
                                                                  .updateMember(
                                                                user: snapshot
                                                                    .data!
                                                                    .elementAt(
                                                                        index),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                                String text =
                                                    _membersSearchTextEditingController
                                                        .text
                                                        .trim();

                                                if (text.isValidEmail &&
                                                    text !=
                                                        FirebaseAuthFunctions
                                                            .getCurrentUser!
                                                            .email!) {
                                                  return ListView(
                                                    children: [
                                                      ListTile(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        title: Text(
                                                            "Invite $text"),
                                                        subtitle: Text(
                                                            "User isn't registered"),
                                                        onTap: () async {
                                                          Share.share(
                                                              "https://links.protasks.in/directShare");
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                }
                                              }
                                              return ListView(
                                                children: [
                                                  ListTile(
                                                    leading:
                                                        CircularProgressIndicator(),
                                                    title: Text(
                                                        'Searching registered users'),
                                                    subtitle: Text(
                                                        'Tip: Type whole email ID'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }

                                        return ListView(
                                          children: [
                                            ListTile(
                                              title:
                                                  Text('Limited Functionality'),
                                              subtitle: Text(
                                                  "Must be registered to search registered users"),
                                            ),
                                          ],
                                        );
                                      }),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(CurrentMembers(members: []));
                                    },
                                    child: Text('Clear'),
                                  ),
                                  Spacer(),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(
                                          context
                                              .read<CurrentMembersCubit>()
                                              .state,
                                        );
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
            if (returnedOutput != null) {
              print("returnedOutput.members: ${returnedOutput.members}");
              membersContext
                  .read<CurrentMembersCubit>()
                  .updateMembersWithList(membersList: returnedOutput.members);
            }
          },
        );
      },
    );
  }
}
