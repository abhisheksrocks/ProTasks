import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/services.dart';
import 'package:protasks/core/constants/notifications.dart';
import 'package:protasks/logic/cubit/root_cubits/ads_handler_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/premium_checker_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/status_nav_bar_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/side_drawer_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/version_checker_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/sync_queues_cubit.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';
import 'package:protasks/logic/firebase_dlink_handler.dart';
import 'package:protasks/logic/my_navigator.dart';
import 'package:protasks/logic/notification_handler.dart';
import 'package:protasks/logic/package_info_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/constants/strings.dart';
import 'core/themes/app_theme.dart';
import 'logic/cubit/root_cubits/sync_cubit.dart';
import 'logic/debug/app_bloc_observer.dart';
import 'presentation/router/app_router.dart';

// DONE: SET THE TIME TO LOCALISED TIME EVERYWHERE
// ? WHY?
// Let's say this app is being used by a team with members from different countries,
// If someone sets up a meeting at some time, then we should show the corresponding
// time w.r.t the other people's time zone.

// TODO: Both Members and Assignees Widget are almost same, pick up the common widgets

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await PackageInfoHandler.initialize();

  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  FirebaseCrashlytics.instance.setUserIdentifier(
    FirebaseAuthFunctions.getCurrentUser?.uid ?? Strings.defaultUserUID,
  );
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  Bloc.observer = AppBlocObserver();
  AwesomeNotifications().initialize(
    null,
    [
      Notifications.lowPriorityReminderNotificationChannel,
      Notifications.mediumPriorityReminderNotificationChannel,
      Notifications.highPriorityReminderNotificationChannel,
    ],
    debug: true,
  );

  NotificationHandler.initializeAllTasksReminder();
  runApp(AppProvider());
}

class AppProvider extends StatelessWidget {
  @override
  Widget build(BuildContext appProviderContext) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (context) => LoginCubit(),
          lazy: false,
        ),
        BlocProvider<VersionCheckerCubit>(
          create: (context) => VersionCheckerCubit(),
          lazy: false,
        ),
        BlocProvider<SyncQueuesCubit>(
          create: (context) => SyncQueuesCubit(),
          lazy: false,
        ),
        BlocProvider<PremiumCheckerCubit>(
          create: (context) => PremiumCheckerCubit(
            loginCubit: context.read<LoginCubit>(),
          ),
          lazy: false,
        ),
        BlocProvider<SideDrawerCubit>(
          create: (context) => SideDrawerCubit(
            loginCubit: context.read<LoginCubit>(),
          ),
          lazy: false,
        ),
        BlocProvider<StatusNavBarCubit>(
          create: (context) => StatusNavBarCubit(),
          lazy: false,
        ),
        BlocProvider<MediaQueryCubit>(
          create: (context) => MediaQueryCubit(),
          lazy: false,
        ),
        BlocProvider<SyncCubit>(
          create: (context) => SyncCubit(
            loginCubit: context.read<LoginCubit>(),
            premiumCheckerCubit: context.read<PremiumCheckerCubit>(),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => AdsHandlerCubit(
            loginCubit: context.read<LoginCubit>(),
            premiumCheckerCubit: context.read<PremiumCheckerCubit>(),
          ),
          lazy: false,
        )
      ],
      child: AppEntry(),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({
    Key? key,
  }) : super(key: key);

  @override
  _AppEntryState createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  void initState() {
    MyNavigator.initialize(navigatorKey);
    WidgetsBinding.instance?.addObserver(this);
    context.read<StatusNavBarCubit>().updateStatusAndNavigationBar();
    NotificationHandler.initialiseNotificationListener();

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    await FirebaseDLinkHandler.handleDynamicLinks();
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangePlatformBrightness() {
    context.read<StatusNavBarCubit>().updateStatusAndNavigationBar();
    super.didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    AwesomeNotifications().createdSink.close();
    AwesomeNotifications().displayedSink.close();
    AwesomeNotifications().actionSink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: PackageInfoHandler.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.dashboard,
      themeMode: context.watch<StatusNavBarCubit>().state.themeMode,
      onGenerateRoute: AppRouter.onGenerateRoute,
      navigatorKey: navigatorKey,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: false,
        ),
        child: child!,
      ),
    );
  }
}
