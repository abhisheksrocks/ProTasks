import 'dart:math';

import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/premium_checker_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/side_drawer_cubit.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:protasks/presentation/screens/add_new_group_modal_sheet/add_new_group_modal_sheet.dart';
import 'package:protasks/presentation/screens/side_drawer/widgets/drawer_element.dart';
import 'package:protasks/presentation/screens/side_drawer/widgets/my_drawer_header.dart';
import 'package:flutter/material.dart';
import 'package:protasks/core/themes/app_theme.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({Key? key}) : super(key: key);

  List<DrawerElement> buildGroups(BuildContext context) {
    List<DrawerElement> _listToReturn = [];
    context.read<SideDrawerCubit>().groupsIdToName.forEach((key, value) {
      _listToReturn.add(DrawerElement(
        id: key,
        icon: Icon(
          Icons.layers,
          color: Theme.of(context).primaryTextColor.withOpacity(0.5),
        ),
        label: value,
        level: 1,
        onTap: () async {
          if (context.read<SideDrawerCubit>().state.selectID != key) {
            Navigator.of(context).pushReplacementNamed(
              AppRouter.groupTasks,
              arguments: SingleGroupTasksArguments(groupId: key),
            );
          } else {
            Navigator.of(context).pop();
          }
        },
      ));
    });
    _listToReturn.add(DrawerElement(
      icon: Icon(
        Icons.add,
        color: Theme.of(context).primaryTextColor.withOpacity(0.5),
      ),
      label: 'Create group',
      level: 1,
      onTap: () {
        Navigator.of(context).pop();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          enableDrag: false,
          builder: (context) => AddNewGroupModalSheetProvider(),
        );
      },
    ));
    return _listToReturn;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SideDrawerCubit, SideDrawerState>(
      builder: (context, state) {
        return Drawer(
          child: Material(
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: [
                MyDrawerHeader(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    children: [
                      DrawerElement(
                        id: SideDrawerCubit.dashboardScreenId,
                        icon: Icon(
                          Icons.dashboard,
                          color: Theme.of(context).accentColor,
                        ),
                        label: 'Dashboard',
                        onTap: () async {
                          String dashboardScreenId =
                              SideDrawerCubit.dashboardScreenId;
                          if (context.read<SideDrawerCubit>().state.selectID !=
                              '$dashboardScreenId') {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRouter.dashboard);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      InkWell(
                        onTap: () {
                          context.read<SideDrawerCubit>().changeGroupView();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.group_work,
                                color: Theme.of(context).accentColor,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Groups',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                state.showGroups
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.showGroups) ...buildGroups(context),
                      DrawerElement(
                        id: '${SideDrawerCubit.settingsScreenId}',
                        icon: Icon(
                          Icons.settings,
                          color: Theme.of(context).accentColor,
                        ),
                        label: 'Settings',
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(AppRouter.settings);
                        },
                      ),
                      DrawerElement(
                        id: '${SideDrawerCubit.completedTasksScreenId}',
                        icon: Icon(
                          Icons.check_circle,
                          color: Theme.of(context).accentColor,
                        ),
                        label: 'Completed Tasks',
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed(AppRouter.completedTasks);
                        },
                      ),
                      if (context.watch<LoginCubit>().state.currentLoginState ==
                          CurrentLoginState.loggedIn)
                        context
                                    .watch<PremiumCheckerCubit>()
                                    .state
                                    .currentPremiumState !=
                                CurrentPremiumState.freeUser
                            ? DrawerElement(
                                id: '4',
                                icon: Icon(
                                  FontAwesomeIcons.crown,
                                  color:
                                      Theme.of(context).highPriorityBannerColor,
                                ),
                                label: 'Premium Stats',
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(AppRouter.freeToPro);
                                },
                              )
                            : Builder(
                                builder: (context) {
                                  bool alternate = Random().nextBool();
                                  return DrawerElement(
                                    id: '3',
                                    icon: Icon(
                                      Icons.whatshot,
                                      color: Colors.orange,
                                    ),
                                    label: alternate
                                        ? 'Get Premium (Free!)'
                                        : 'Remove ads (Free!)',
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed(AppRouter.freeToPro);
                                    },
                                  );
                                },
                              ),
                      DrawerElement(
                        id: '${SideDrawerCubit.deletedTasksScreenId}',
                        icon: Icon(
                          FontAwesomeIcons.trashAlt,
                          color: Theme.of(context).errorColor.withOpacity(0.7),
                        ),
                        label: 'Recycle Bin',
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed(AppRouter.deletedTasks);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
