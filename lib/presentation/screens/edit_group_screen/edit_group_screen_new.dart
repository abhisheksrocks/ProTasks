import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/cubit/button_states_cubit.dart';
import 'package:protasks/logic/cubit/edit_group_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_group_modal_sheet_specific/current_members_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_group_modal_sheet_specific/members_search_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/side_drawer_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/sync_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:protasks/logic/firebase_cfunction_handler.dart';
import 'package:protasks/logic/firebase_fstore_functions.dart';
import 'package:protasks/logic/my_navigator.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/my_will_pop_scope/confirmation_dialog.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/my_will_pop_scope/my_will_pop_scope.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/select_people/dialog_search_bar.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/select_people/person_icon.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/select_people/person_name.dart';
import 'package:protasks/presentation/common_widgets/my_sliver_appbar.dart';
import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:protasks/presentation/common_widgets/detail_maker.dart';
import 'package:protasks/presentation/common_widgets/detail_title.dart';
import 'package:protasks/presentation/common_widgets/detail_value.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:protasks/logic/extra_extensions.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:share_plus/share_plus.dart';

class EditGroupScreenProvider extends StatelessWidget {
  const EditGroupScreenProvider({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EditGroupCubit>(
          create: (context) => EditGroupCubit(groupId: groupId),
        ),
        BlocProvider<TextEditingControllerCubit>(
          create: (context) => TextEditingControllerCubit(),
        ),
        BlocProvider<CurrentMembersCubit>(
          create: (context) => CurrentMembersCubit(),
        ),
      ],
      child: EditGroupScreenNew(),
    );
  }
}

class EditGroupScreenNew extends StatefulWidget {
  const EditGroupScreenNew({
    Key? key,
  }) : super(key: key);

  @override
  _EditGroupScreenNewState createState() => _EditGroupScreenNewState();
}

class _EditGroupScreenNewState extends State<EditGroupScreenNew> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    context.read<TextEditingControllerCubit>()
      ..beginFetching(
        newTextEditingController: _textEditingController,
        newStateEveryCharacter: true,
      );

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // final state = context.watch<EditGroupCubit>().state;
    // if (state is EditGroupLoaded) {
    //   final currentMembers = context
    //       .read<CurrentMembersCubit>()
    //       .state
    //       .members
    //       .map((e) => e.uid)
    //       .toList();
    //   if (!listEquals(state.updatedGroup.members, currentMembers)) {
    //     context.read<CurrentMembersCubit>().updateMembersWithUIDList(
    //           membersUIDList: state.updatedGroup.members,
    //         );
    //   }
    // }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext editGroupScreenContext) {
    return Scaffold(
      body: BlocBuilder<EditGroupCubit, EditGroupState>(
        builder: (context, state) {
          if (state is EditGroupLoaded) {
            if (state.updatedGroup.name != _textEditingController.text.trim()) {
              _textEditingController.text = state.updatedGroup.name;
              _textEditingController.selection = TextSelection.fromPosition(
                TextPosition(offset: _textEditingController.text.length),
              );
            }

            final currentMembersInCubit = context
                .read<CurrentMembersCubit>()
                .state
                .members
                .map((e) => e.uid)
                .toList();
            if (!listEquals(
                state.updatedGroup.members, currentMembersInCubit)) {
              context.read<CurrentMembersCubit>().updateMembersWithUIDList(
                    membersUIDList: state.updatedGroup.members,
                  );
            }

            bool userIsAdmin = state.groupToEdit.admins.contains(
              FirebaseAuthFunctions.getCurrentUser?.uid ??
                  Strings.defaultUserUID,
            );

            List<Person> membersList =
                context.watch<CurrentMembersCubit>().state.members;

            return WillPopScope(
              onWillPop: () async {
                if (userIsAdmin) {
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (context) {
                      return ConfirmationDialog(
                        actionText: 'Confirm',
                      );
                    },
                  );

                  if (confirm == true) {
                    return true;
                  }
                  return false;
                }
                return true;
              },
              child: CustomScrollView(
                slivers: [
                  MySliverAppBar(
                    title: 'Group Info',
                    actions: [
                      Builder(
                        builder: (context) {
                          if (!userIsAdmin) {
                            return SizedBox();
                          }
                          bool canSubmit = true;

                          context.watch<TextEditingControllerCubit>().state;

                          // if (state.groupToEdit.name ==
                          //     _textEditingController.text.trim()) {
                          //   canSubmit = false;
                          // }
                          context.read<EditGroupCubit>().updateGroupInfo(
                                newName: _textEditingController.text.trim(),
                              );

                          if (!state.hasChanged) {
                            canSubmit = false;
                          }

                          return InkWell(
                            onTap: canSubmit
                                ? () async {
                                    Navigator.of(context).pop();
                                    await GroupsDao().insertOrUpdateGroups(
                                      state.updatedGroup
                                        ..isSynced = false
                                        ..updatedOn = DateTime.now().toUtc(),
                                    );
                                    (MyNavigator.context!)
                                        .read<SideDrawerCubit>()
                                        .reinitialize();
                                  }
                                : null,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Opacity(
                                  opacity: canSubmit ? 1 : 0.3,
                                  child: Text(
                                    'SAVE',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: Strings.primaryFontFamily,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    leading: BackButton(),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: TextFormField(
                            autovalidateMode: AutovalidateMode.always,
                            controller: _textEditingController,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 25,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            enabled: userIsAdmin,
                            validator: (input) {
                              if (input != null) {
                                if (input.isEmpty) {
                                  return "Can't be empty";
                                }
                              }
                            },
                            keyboardType: TextInputType.name,
                            style: TextStyle(
                              color: Theme.of(context).primaryTextColor,
                              fontFamily: Strings.secondaryFontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              counter: const SizedBox(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              prefixIcon: Icon(
                                Icons.layers,
                              ),
                              fillColor: Colors.pink,
                              focusColor: Colors.orange,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).accentColor,
                                  width: 2,
                                ),
                                gapPadding: 0,
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .primaryTextColor
                                      .withOpacity(0.3),
                                  width: 2,
                                ),
                                gapPadding: 0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).accentColor,
                                  width: 2,
                                ),
                                gapPadding: 0,
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              hintText: "Group name",
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).errorColor,
                                ),
                                gapPadding: 0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                                gapPadding: 0,
                              ),
                              hintStyle: TextStyle(
                                fontFamily: Strings.secondaryFontFamily,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .primaryTextColor
                                    .withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          color: Theme.of(context).accentColor.withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  'MEMBERS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                              if (context
                                      .read<LoginCubit>()
                                      .state
                                      .currentLoginState ==
                                  CurrentLoginState.loggedIn)
                                Builder(
                                  builder: (context) {
                                    return AbsorbPointer(
                                      absorbing: !userIsAdmin,
                                      child: Opacity(
                                        opacity: userIsAdmin ? 1 : 0,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.group_add_outlined,
                                          ),
                                          onPressed: () async {
                                            List<Person>
                                                _currentlySelectedMembers =
                                                editGroupScreenContext
                                                    .read<CurrentMembersCubit>()
                                                    .state
                                                    .members;
                                            print("initiallySelectedMembers: ");
                                            CurrentMembers? returnedOutput =
                                                await showDialog(
                                              context: editGroupScreenContext,
                                              builder: (context) {
                                                final TextEditingController
                                                    _membersSearchTextEditingController =
                                                    TextEditingController();

                                                final double mediaQueryHeight =
                                                    context
                                                        .read<MediaQueryCubit>()
                                                        .state
                                                        .size
                                                        .height;

                                                final double mediaQueryWidth =
                                                    context
                                                        .read<MediaQueryCubit>()
                                                        .state
                                                        .size
                                                        .width;

                                                final double maxScreenHeight =
                                                    (mediaQueryHeight >
                                                            mediaQueryWidth)
                                                        ? mediaQueryHeight
                                                        : mediaQueryWidth;
                                                return MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider<
                                                        MembersSearchCubit>(
                                                      create: (context) =>
                                                          MembersSearchCubit(),
                                                    ),
                                                    BlocProvider<
                                                        TextEditingControllerCubit>(
                                                      create: (context) =>
                                                          TextEditingControllerCubit()
                                                            ..beginFetching(
                                                              newTextEditingController:
                                                                  _membersSearchTextEditingController,
                                                              newStateEveryCharacter:
                                                                  true,
                                                            ),
                                                    ),
                                                    BlocProvider<
                                                        CurrentMembersCubit>(
                                                      create: (context) =>
                                                          CurrentMembersCubit()
                                                            ..updateMembersWithList(
                                                                membersList:
                                                                    _currentlySelectedMembers),
                                                    ),
                                                  ],
                                                  child: Dialog(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .backgroundColor,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 24,
                                                        vertical: 16,
                                                      ),
                                                      constraints:
                                                          BoxConstraints(
                                                        maxHeight:
                                                            maxScreenHeight *
                                                                0.6,
                                                      ),
                                                      width: double.infinity,
                                                      child: BlocBuilder<
                                                          TextEditingControllerCubit,
                                                          TextEditingControllerState>(
                                                        builder:
                                                            (context, state) {
                                                          final _membersSearchCubit =
                                                              context.watch<
                                                                  MembersSearchCubit>();

                                                          final currentMembersCubit =
                                                              // context.read<CurrentAssigneesCubit>();
                                                              context.watch<
                                                                  CurrentMembersCubit>();

                                                          _membersSearchCubit
                                                              .searchWithQuery(
                                                            _membersSearchTextEditingController
                                                                .text,
                                                          );

                                                          List<Person>
                                                              usersToShow =
                                                              _membersSearchCubit
                                                                  .state
                                                                  .usersToShow;

                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Text(
                                                                'SELECT MEMBERS',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  letterSpacing:
                                                                      2,
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
                                                                child: usersToShow
                                                                            .length >
                                                                        0
                                                                    ? ListView
                                                                        .builder(
                                                                        itemCount:
                                                                            usersToShow.length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          return Row(
                                                                            children: [
                                                                              PersonIcon(),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    if (usersToShow.elementAt(index).name != null)
                                                                                      PersonName(
                                                                                        stringToShow: usersToShow.elementAt(index).name!.capitalize,
                                                                                      ),
                                                                                    // TODO: Change this text to something usable
                                                                                    if (usersToShow.elementAt(index).email != null)
                                                                                      PersonName(
                                                                                        stringToShow: usersToShow.elementAt(index).email!.toLowerCase(),
                                                                                      ),
                                                                                    if (usersToShow.elementAt(index).email == null && usersToShow.elementAt(index).name == null)
                                                                                      PersonName(
                                                                                        stringToShow: "User ${usersToShow.elementAt(index).uid}",
                                                                                      ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              MyCircularCheckBox(
                                                                                value: currentMembersCubit.state.members.contains(
                                                                                  usersToShow.elementAt(index),
                                                                                ),
                                                                                onChanged: (value) {
                                                                                  currentMembersCubit.updateMember(
                                                                                    user: usersToShow.elementAt(index),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      )
                                                                    : Builder(
                                                                        builder:
                                                                            (context) {
                                                                        if (context.read<LoginCubit>().state.currentLoginState ==
                                                                            CurrentLoginState.loggedIn) {
                                                                          return FutureBuilder<
                                                                              List<Person>>(
                                                                            future:
                                                                                FirebaseFstoreFunctions().findEmailOnCloud(_membersSearchTextEditingController.text.trim()),
                                                                            builder:
                                                                                (context, snapshot) {
                                                                              if (snapshot.connectionState == ConnectionState.done) {
                                                                                print("snapshot.data: ${snapshot.data}");
                                                                                print("ConnectionState.done");
                                                                                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                                                                  return ListView.builder(
                                                                                    itemCount: snapshot.data!.length,
                                                                                    itemBuilder: (context, index) {
                                                                                      return Row(
                                                                                        children: [
                                                                                          PersonIcon(),
                                                                                          Expanded(
                                                                                            child: Column(
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                if (snapshot.data!.elementAt(index).name != null)
                                                                                                  PersonName(
                                                                                                    stringToShow: snapshot.data!.elementAt(index).name!.capitalize,
                                                                                                  ),
                                                                                                if (snapshot.data!.elementAt(index).email != null)
                                                                                                  PersonName(
                                                                                                    stringToShow: snapshot.data!.elementAt(index).email!.toLowerCase(),
                                                                                                  ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          MyCircularCheckBox(
                                                                                            value: currentMembersCubit.state.members.contains(
                                                                                              snapshot.data!.elementAt(index),
                                                                                            ),
                                                                                            onChanged: (value) async {
                                                                                              UsersDao().insertOrUpdateUser(
                                                                                                snapshot.data!.elementAt(index),
                                                                                              );
                                                                                              currentMembersCubit.updateMember(
                                                                                                user: snapshot.data!.elementAt(index),
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                }
                                                                                String text = _membersSearchTextEditingController.text.trim();

                                                                                if (text.isValidEmail && text != FirebaseAuthFunctions.getCurrentUser!.email!) {
                                                                                  return ListView(
                                                                                    children: [
                                                                                      ListTile(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(4),
                                                                                        ),
                                                                                        title: Text("Invite $text"),
                                                                                        subtitle: Text("User isn't registered"),
                                                                                        onTap: () async {
                                                                                          Share.share("https://links.protasks.in/directShare");
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                }
                                                                              }
                                                                              return ListView(
                                                                                children: [
                                                                                  ListTile(
                                                                                    leading: CircularProgressIndicator(),
                                                                                    title: Text('Searching registered users'),
                                                                                    subtitle: Text('Tip: Type whole email ID'),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                        }

                                                                        return ListView(
                                                                          children: [
                                                                            ListTile(
                                                                              title: Text('Limited Functionality'),
                                                                              subtitle: Text("Must be registered to search registered users"),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      }),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Spacer(),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(
                                                                          context
                                                                              .read<CurrentMembersCubit>()
                                                                              .state,
                                                                        );
                                                                      },
                                                                      child: Text(
                                                                          'OK')),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                        'Cancel'),
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
                                              print(
                                                  "returnedOutput.members: ${returnedOutput.members}");
                                              editGroupScreenContext
                                                  .read<EditGroupCubit>()
                                                  .updateGroupInfo(
                                                    newMembers: returnedOutput
                                                        .members
                                                        .map((e) => e.uid)
                                                        .toList(),
                                                  );
                                            }
                                          },
                                          color: Theme.of(context).accentColor,
                                          disabledColor: Theme.of(context)
                                              .accentColor
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        Person currentEntry = membersList.elementAt(index);
                        bool _isMe = currentEntry.uid ==
                            (FirebaseAuthFunctions.getCurrentUser?.uid ??
                                Strings.defaultUserUID);
                        bool _isAdmin = state.updatedGroup.admins
                            .contains(currentEntry.uid);
                        return InkWell(
                          onTap: _isMe
                              ? null
                              : userIsAdmin
                                  ? () {
                                      // This is to remove keyboard after user clicks on something else
                                      // other than TextField
                                      FocusScope.of(context).unfocus();

                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Material(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryTextColor
                                                        .withOpacity(0.1),
                                                  ),
                                                  child: Text(
                                                    "${currentEntry.name ?? currentEntry.email ?? ('User ${currentEntry.uid}')}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: Strings
                                                          .primaryFontFamily,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Material(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    _isAdmin
                                                        ? ListTile(
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            onTap: () {
                                                              context
                                                                  .read<
                                                                      EditGroupCubit>()
                                                                  .updateGroupInfo(
                                                                    newAdmins: state
                                                                        .updatedGroup
                                                                        .admins
                                                                      ..remove(
                                                                          currentEntry
                                                                              .uid),
                                                                  );
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            title: DetailValue(
                                                              stringToShow:
                                                                  "Dismiss As Admin",
                                                            ),
                                                          )
                                                        : ListTile(
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            onTap: () {
                                                              context
                                                                  .read<
                                                                      EditGroupCubit>()
                                                                  .updateGroupInfo(
                                                                    newAdmins: state
                                                                        .updatedGroup
                                                                        .admins
                                                                      ..add(currentEntry
                                                                          .uid),
                                                                  );
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            title: DetailValue(
                                                                stringToShow:
                                                                    "Make Admin"),
                                                          ),
                                                    ListTile(
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      onTap: () {
                                                        List<String>
                                                            newMembers =
                                                            List.from(state
                                                                .updatedGroup
                                                                .members);
                                                        newMembers.removeWhere(
                                                            (element) =>
                                                                element ==
                                                                currentEntry
                                                                    .uid);
                                                        context
                                                            .read<
                                                                EditGroupCubit>()
                                                            .updateGroupInfo(
                                                                newMembers:
                                                                    newMembers);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      title: DetailValue(
                                                        stringToShow:
                                                            "Remove from Group",
                                                        textStyle: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .errorColor,
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
                                  : null,
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 6,
                              left: 8,
                              right: 8,
                              top: 6,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                PersonIcon(
                                  backgroundColor: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.2),
                                  foregroundColor:
                                      Theme.of(context).accentColor,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
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
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: Strings
                                                      .secondaryFontFamily,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (currentEntry.name != null &&
                                          currentEntry.name!.isNotEmpty &&
                                          !_isMe)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AutoSizeText(
                                                currentEntry.name!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: Strings
                                                      .secondaryFontFamily,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (currentEntry.email != null)
                                        PersonName(
                                          stringToShow: currentEntry.email!,
                                        ),
                                      if (currentEntry.email == null &&
                                          currentEntry.name == null)
                                        PersonName(
                                            stringToShow:
                                                "User ${currentEntry.uid}"),
                                    ],
                                  ),
                                ),
                                if (_isAdmin)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).accentColor,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Admin',
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: membersList.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: BlocProvider(
                                  create: (context) => ButtonStatesCubit(
                                    initialButtonState:
                                        CurrentButtonState.normal,
                                  ),
                                  child: BlocBuilder<ButtonStatesCubit,
                                      ButtonState>(
                                    builder: (context, buttonState) {
                                      if (buttonState.currentButtonState ==
                                          CurrentButtonState.normal) {
                                        return Builder(
                                          builder: (context) {
                                            if (context
                                                    .read<LoginCubit>()
                                                    .state
                                                    .currentLoginState ==
                                                CurrentLoginState
                                                    .choseNotToLogIn) {
                                              return TextButton(
                                                onPressed: () async {
                                                  bool? confirm =
                                                      await showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        ConfirmationDialog(
                                                      actionText: 'Leave Group',
                                                      content:
                                                          'Are you sure you want to leave this group? All your data will be lost.',
                                                    ),
                                                  );
                                                  if (confirm == true) {
                                                    await GroupsDao()
                                                        .leaveFromGroup(
                                                      groupId:
                                                          state.groupToEdit.id,
                                                    );
                                                    context
                                                        .read<SyncCubit>()
                                                        .reinitialize();
                                                    context
                                                        .read<SideDrawerCubit>()
                                                        .reinitialize();
                                                    Navigator.of(MyNavigator
                                                            .context!)
                                                        .pushNamedAndRemoveUntil(
                                                      AppRouter.dashboard,
                                                      (route) => true,
                                                    );
                                                  }
                                                },
                                                style: Theme.of(context)
                                                    .errorTextButtonStyle,
                                                child: Text('Leave Group'),
                                              );
                                            }
                                            return TextButton(
                                              onPressed: state
                                                      .groupToEdit.isSynced
                                                  ? () async {
                                                      bool? confirm =
                                                          await showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            ConfirmationDialog(
                                                          actionText:
                                                              'Leave Group',
                                                          content:
                                                              'Are you sure you want to leave this group?',
                                                        ),
                                                      );
                                                      if (confirm == true) {
                                                        bool internetWorking =
                                                            await InternetConnectionChecker()
                                                                .hasConnection;
                                                        if (internetWorking) {
                                                          context
                                                              .read<
                                                                  ButtonStatesCubit>()
                                                              .changeState(
                                                                newState:
                                                                    CurrentButtonState
                                                                        .loading,
                                                              );

                                                          if (await FirebaseCFunctionHandler
                                                              .leaveFromGroup(
                                                            groupId: state
                                                                .groupToEdit.id,
                                                          )) {
                                                            print("Left Group");

                                                            await GroupsDao()
                                                                .leaveFromGroup(
                                                              groupId: state
                                                                  .groupToEdit
                                                                  .id,
                                                            );
                                                            (MyNavigator
                                                                    .context!)
                                                                .read<
                                                                    SyncCubit>()
                                                                .reinitialize();
                                                            (MyNavigator
                                                                    .context!)
                                                                .read<
                                                                    SideDrawerCubit>()
                                                                .reinitialize();
                                                            Navigator.of(
                                                                    MyNavigator
                                                                        .context!)
                                                                .pushNamedAndRemoveUntil(
                                                              AppRouter
                                                                  .dashboard,
                                                              (route) => true,
                                                            );
                                                          } else {
                                                            print(
                                                                "Couldn't Leave");
                                                            Fluttertoast
                                                                .showToast(
                                                              msg:
                                                                  "Couldn't leave the group",
                                                            );
                                                            context
                                                                .read<
                                                                    ButtonStatesCubit>()
                                                                .changeState(
                                                                    newState:
                                                                        CurrentButtonState
                                                                            .normal);
                                                          }
                                                        } else {
                                                          // Fluttertoast.showToast(
                                                          //   msg:
                                                          //       "This function requires active internet",
                                                          // );
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    'No Internet'),
                                                                content:
                                                                    SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child: Text(
                                                                      "Check your phone's internet connection and try again."),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                        'OK'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      }
                                                    }
                                                  : null,
                                              style: Theme.of(context)
                                                  .errorTextButtonStyle,
                                              child: Text('Leave Group'),
                                            );
                                          },
                                        );
                                      }
                                      if (buttonState.currentButtonState ==
                                          CurrentButtonState.loading) {
                                        return Opacity(
                                          opacity: 0.7,
                                          child: Stack(
                                            alignment: Alignment.centerRight,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: TextButton(
                                                  onPressed: null,
                                                  style: Theme.of(context)
                                                      .errorTextButtonStyle,
                                                  child: Text('Leave Group'),
                                                ),
                                              ),
                                              Container(
                                                height: 20,
                                                padding:
                                                    EdgeInsets.only(right: 12),
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        if (context
                                .read<LoginCubit>()
                                .state
                                .currentLoginState ==
                            CurrentLoginState.loggedIn)
                          DetailMaker(
                            firstWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DetailTitle(title: "SYNC STATUS"),
                                state.groupToEdit.isSynced
                                    ? DetailValue(
                                        stringToShow: "COMPLETE",
                                        textStyle: TextStyle(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          DetailValue(
                                            stringToShow: "INCOMPLETE ",
                                          ),
                                          Icon(Icons.error)
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        if (!state.groupToEdit.isSynced &&
                            context
                                    .read<LoginCubit>()
                                    .state
                                    .currentLoginState ==
                                CurrentLoginState.loggedIn)
                          Container(
                            color: Theme.of(context)
                                .primaryTextColor
                                .withOpacity(0.1),
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "CAUTION",
                                  // textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Strings.primaryFontFamily,
                                  ),
                                ),
                                Text(
                                  "You can leave a group only after sync is complete\n(plus it needs an active internet connection)",
                                  style: TextStyle(
                                    fontFamily: Strings.secondaryFontFamily,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
