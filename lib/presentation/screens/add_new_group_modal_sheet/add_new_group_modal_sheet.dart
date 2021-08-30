import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/group.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_group_modal_sheet_specific/current_members_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/presentation/common_widgets/my_button.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/my_will_pop_scope/confirmation_dialog.dart';
import 'package:protasks/presentation/common_widgets/dialog_related/my_will_pop_scope/my_will_pop_scope.dart';
import 'package:protasks/presentation/screens/add_new_group_modal_sheet/widgets/new_group_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/current_members_widget.dart';

class AddNewGroupModalSheetProvider extends StatelessWidget {
  const AddNewGroupModalSheetProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyWillPopScope(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TextEditingControllerCubit>(
            create: (context) => TextEditingControllerCubit(),
          ),
          BlocProvider<CurrentMembersCubit>(
            create: (context) => CurrentMembersCubit(),
          ),
        ],
        child: AddNewGroupModalSheet(),
      ),
    );
  }
}

class AddNewGroupModalSheet extends StatelessWidget {
  const AddNewGroupModalSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => ConfirmationDialog(),
              );
              if (confirm == true) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        Container(
          color: Theme.of(context).backgroundColor,
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
                left: 20,
                right: 20,
                top: 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 20,
                            ),
                            child: NewGroupTextField(),
                          ),
                        ),
                        if (context
                                .watch<LoginCubit>()
                                .state
                                .currentLoginState ==
                            CurrentLoginState.loggedIn)
                          CurrentMembersWidget()
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      bool canSubmit = true;
                      if (context
                          .watch<TextEditingControllerCubit>()
                          .state
                          .textString
                          .isEmpty) {
                        canSubmit = false;
                      }

                      return MyButton(
                        icon: Icon(
                          Icons.check,
                          size: 32,
                          color: const Color(0xFFFFFFFF),
                        ),
                        onTap: canSubmit
                            ? () async {
                                String groupName = context
                                    .read<TextEditingControllerCubit>()
                                    .textEditingController!
                                    .text
                                    .trim();

                                List<String> _userIdList = List.from(context
                                    .read<CurrentMembersCubit>()
                                    .state
                                    .members
                                    .map((e) => e.uid));

                                Person currentUser =
                                    await UsersDao().getCurrentUser();

                                _userIdList.add(currentUser.uid);

                                final Group groupToAdd = Group(
                                  id: ExtraFunctions.createId,
                                  parentGroupId: Strings.noGroupID,
                                  name: groupName,
                                  members: _userIdList,
                                  admins: [currentUser.uid],
                                  createdOn: DateTime.now().toUtc(),
                                  updatedOn: DateTime.now().toUtc(),
                                  isSynced: false,
                                );

                                print("Group to add: $groupToAdd");

                                await GroupsDao()
                                    .insertOrUpdateGroups(groupToAdd);

                                Navigator.of(context).pop();
                              }
                            : null,
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
