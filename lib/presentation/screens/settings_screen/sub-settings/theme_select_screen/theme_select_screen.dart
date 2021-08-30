import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/logic/cubit/root_cubits/status_nav_bar_cubit.dart';
import 'package:protasks/presentation/common_widgets/my_sliver_appbar.dart';
import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeSelectScreen extends StatelessWidget {
  ThemeSelectScreen({Key? key}) : super(key: key);

  final BorderRadius borderRadius = BorderRadius.circular(8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MySliverAppBar(
            title: 'Select Theme',
            actions: [],
            leading: BackButton(),
          ),
          SliverToBoxAdapter(
            child: Material(
              color: Theme.of(context).backgroundColor,
              child: BlocBuilder<StatusNavBarCubit, StatusNavBar>(
                builder: (context, state) {
                  bool allowChange = state.allowChange;
                  ThemeMode currentTheme = state.themeMode;
                  return Wrap(
                    runSpacing: 20,
                    spacing: 20,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Material(
                          color: AppTheme.darkBackgroundColor,
                          borderOnForeground: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: borderRadius,
                            side: BorderSide(
                              color: AppTheme.darkDividerColor,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              context
                                  .read<StatusNavBarCubit>()
                                  .updateStatusAndNavigationBar(
                                    brightnessToSet: Brightness.dark,
                                    forceChange: true,
                                  );
                            },
                            borderRadius: borderRadius,
                            child: Column(
                              children: [
                                Ink(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkPrimaryColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Container(
                                    child: Text(
                                      'Dark Theme',
                                      style: TextStyle(
                                        fontFamily: Strings.primaryFontFamily,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        unselectedWidgetColor:
                                            Colors.white.withOpacity(0.7),
                                      ),
                                      child: AbsorbPointer(
                                        child: MyCircularCheckBox(
                                          value: (!allowChange &&
                                              currentTheme == ThemeMode.dark),
                                          onChanged: (_) {},
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 20,
                                            color: Colors.white12,
                                            margin: EdgeInsets.only(right: 16),
                                            width: double.infinity,
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Container(
                                            height: 20,
                                            color: Colors.white12,
                                            margin: EdgeInsets.only(right: 16),
                                            width: 200,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Material(
                          color: AppTheme.lightBackgroundColor,
                          borderOnForeground: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: borderRadius,
                            side: BorderSide(
                              color: AppTheme.lightDividerColor,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              context
                                  .read<StatusNavBarCubit>()
                                  .updateStatusAndNavigationBar(
                                    brightnessToSet: Brightness.light,
                                    forceChange: true,
                                  );
                            },
                            borderRadius: borderRadius,
                            child: Column(
                              children: [
                                Ink(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightPrimaryColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Container(
                                    child: Text(
                                      'Light Theme',
                                      style: TextStyle(
                                        fontFamily: Strings.primaryFontFamily,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        unselectedWidgetColor:
                                            Colors.black.withOpacity(0.5),
                                      ),
                                      child: AbsorbPointer(
                                        child: MyCircularCheckBox(
                                          value: (!allowChange &&
                                              currentTheme == ThemeMode.light),
                                          onChanged: (_) {},
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 20,
                                            color: Colors.black12,
                                            margin: EdgeInsets.only(right: 16),
                                            width: double.infinity,
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Container(
                                            height: 20,
                                            color: Colors.black12,
                                            margin: EdgeInsets.only(right: 16),
                                            width: 200,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        selected: allowChange,
                        selectedTileColor:
                            Theme.of(context).primaryTextColor.withOpacity(0.1),
                        onTap: () {
                          context
                              .read<StatusNavBarCubit>()
                              .updateStatusAndNavigationBar(
                                forceChange: true,
                              );
                        },
                        leading: AbsorbPointer(
                          child: MyCircularCheckBox(
                            value: allowChange,
                            onChanged: (_) {},
                          ),
                        ),
                        title: Text(
                          'System Theme',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: Strings.primaryFontFamily,
                            color: Theme.of(context).primaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
