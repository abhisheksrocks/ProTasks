import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/data/models/person.dart';
import 'package:protasks/logic/cubit/root_cubits/premium_checker_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MyDrawerHeader extends StatelessWidget {
  const MyDrawerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumCheckerCubit, PremiumCheckerState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            left: 32,
            right: 32,
            top: 24 + context.watch<MediaQueryCubit>().state.padding.top,
            bottom: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: (context.read<LoginCubit>().state.currentLoginState ==
                  CurrentLoginState.loggedIn)
              ? Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Person>(
                              future: UsersDao().getCurrentUser(),
                              builder: (context, snapshot) {
                                Person? user = snapshot.data;
                                return AutoSizeText(
                                  user?.name ?? user?.email ?? "You",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: Strings.secondaryFontFamily,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            state.currentPremiumState !=
                                    CurrentPremiumState.freeUser
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).accentColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Pro User',
                                      style: TextStyle(
                                        fontFamily: Strings.primaryFontFamily,
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Free User',
                                    style: TextStyle(
                                      fontFamily: Strings.primaryFontFamily,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(
                          child: AutoSizeText(
                            "ProTasks",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      ]),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          return Row(children: [
                            Expanded(
                              child: AutoSizeText(
                                "v${snapshot.data?.version}",
                              ),
                            ),
                          ]);
                        },
                      )
                    ],
                  ),
                ),
        );
      },
    );
  }
}
