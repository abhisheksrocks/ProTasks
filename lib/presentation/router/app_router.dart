import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/version_checker_cubit.dart';
import 'package:protasks/presentation/screens/about_screen/about_screen.dart';
import 'package:protasks/presentation/screens/completed_tasks_screen/completed_tasks_screen.dart';
import 'package:protasks/presentation/screens/dashboard_screen/dashboard_screen.dart';
import 'package:protasks/presentation/screens/deleted_tasks_screen/deleted_tasks_screen.dart';
import 'package:protasks/presentation/screens/edit_group_screen/edit_group_screen_new.dart';
import 'package:protasks/presentation/screens/force_update_screen/force_update_screen.dart';
import 'package:protasks/presentation/screens/membership_screen/membership_screen.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/onboard_and_login_screen.dart';
import 'package:protasks/presentation/screens/plans_screen/plans_screen.dart';
import 'package:protasks/presentation/screens/settings_screen/settings_screen.dart';
import 'package:protasks/presentation/screens/settings_screen/sub-settings/sync_screen/sync_screen.dart';
import 'package:protasks/presentation/screens/settings_screen/sub-settings/theme_select_screen/theme_select_screen.dart';
import 'package:protasks/presentation/screens/single_group_tasks_screen/single_group_tasks_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions/route_exception.dart';

class SingleGroupTasksArguments {
  final String groupId;

  SingleGroupTasksArguments({
    required this.groupId,
  });
}

class EditGroupArguments {
  final String groupId;

  EditGroupArguments({
    required this.groupId,
  });
}

class AppRouter {
  static const String dashboard = '/';

  static const String groupTasks = '/groupTasks';

  static const String onboardLogin = '/onboardLogin';

  static const String settings = '/settings';

  static const String syncScreen = '/syncScreen';

  static const String themeSelect = '/themeSelect';

  static const String editProfile = '/editProfile';

  static const String editGroup = '/editGroup';

  static const String completedTasks = '/completedTasks';

  static const String deletedTasks = '/deletedTasks';

  static const String freeToPro = '/freeToPro';

  static const String plansScreen = '/plansScreen';

  static const String aboutScreen = '/aboutScreen';

  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (context) {
        // return PremiumMakerScreen();
        if (context.watch<VersionCheckerCubit>().state.needsUpdate) {
          Navigator.of(context).popUntil((route) => true);
          return ForceUpdateScreen();
        }
        return BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            if (state.currentLoginState == CurrentLoginState.loggedOut) {
              return OnboardAndLoginScreenProvider();
            }
            switch (routeSettings.name) {
              case aboutScreen:
                return AboutScreen();
              case completedTasks:
                return CompletedTasksProvider();
              case dashboard:
                return DashboardScreenProvider();
              case deletedTasks:
                return DeletedTasksProvider();
              case editGroup:
                final arguments = routeSettings.arguments as EditGroupArguments;
                return EditGroupScreenProvider(
                  groupId: arguments.groupId,
                );
              case freeToPro:
                return MembershipScreen();
              case groupTasks:
                final arguments =
                    routeSettings.arguments as SingleGroupTasksArguments;
                return SingleGroupTasksScreenProvider(
                  groupID: arguments.groupId,
                );
              case onboardLogin:
                return OnboardAndLoginScreenProvider();
              //   return MaterialPageRoute(
              //     builder: (context) => OnboardAndLoginScreenProvider(),
              //   );
              case plansScreen:
                return PlansScreen();
              case themeSelect:
                return ThemeSelectScreen();
              case settings:
                return SettingsScreen();
              case syncScreen:
                return SyncScreen();
              default:
                throw const RouteException('Route not found!');
            }
            // return DashboardScreenProvider();
          },
        );
      },
    );
    // switch (settings.name) {
    //   case dashboard:
    //     return MaterialPageRoute(
    //       builder: (_) => DashboardScreenProvider(),
    //       // builder: (_) => HomeScreen(
    //       //   title: Strings.homeScreenTitle,
    //       // ),
    //     );
    //   case groupTasks:
    //     return MaterialPageRoute(
    //       builder: (context) => SingleGroupTasksScreenProvider(
    //         groupID: settings.arguments as String,
    //       ),
    //     );
    //   // case onboardLogin:
    //   //   return MaterialPageRoute(
    //   //     builder: (context) => OnboardAndLoginScreenProvider(),
    //   //   );
    //   default:
    //     throw const RouteException('Route not found!');
    // }
  }
}
