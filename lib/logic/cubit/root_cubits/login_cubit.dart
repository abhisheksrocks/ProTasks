import 'dart:convert';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/data/data_providers/app_database.dart';
import 'package:protasks/data/data_providers/chats_dao.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import '../../notification_handler.dart';

part 'login_state.dart';

class LoginCubit extends HydratedCubit<LoginState> {
  static String? loginEmail;
  static UserCredential? userCredential;
  LoginCubit()
      : super(LoginState(currentLoginState: CurrentLoginState.loggedOut)) {
    changeStateBasedOnAuthChanges();
  }

  void changeStateBasedOnAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        if (state.currentLoginState == CurrentLoginState.loggedIn) {
          // emit(LoginState(currentLoginState: CurrentLoginState.notLoggedIn));
          userLoggedOut();
        }
        // else if (state.currentLoginState ==
        //     CurrentLoginState.choseNotToLogIn) {
        //   emit(
        //       LoginState(currentLoginState: CurrentLoginState.choseNotToLogIn));
        // }
      } else {
        userLoggedIn(user);
      }
    });
  }

  void userLoggedIn(User newUser) async {
    if (state.currentLoginState != CurrentLoginState.loggedIn) {
      await Future.delayed(Duration(milliseconds: 300));
      if (userCredential!.additionalUserInfo!.isNewUser) {
        if (state.currentLoginState == CurrentLoginState.choseNotToLogIn) {
          // i.e. the user initially tried the app without logging in, then decided
          // to login, so we should carry forward his pre-existing data
          TasksDao().updateAllTasksWithNewUserInfo();
          ChatsDao().updateAllChatsWithNewUserInfo();
          GroupsDao().updateAllGroupsWithNewUserInfo();
          UsersDao().updateDefaultUserWithNewUserInfo();
        } else {
          // i.e. the user logged in straight away
          await AppDatabase.instance.deleteDatabase();
          await NotificationHandler.cancelAllNotification();
          print("Making new database for new user");
          await AppDatabase.instance.initializeDatabaseForUser();
          await NotificationHandler.initializeAllTasksReminder();
        }

        // After creating data for the new user, we must update in Firestore about it.
        // TODO: Update about new data on firestore straightaway
      } else {
        // i.e. the user logged in straight away
        await AppDatabase.instance.deleteDatabase();
        await NotificationHandler.cancelAllNotification();
        print("Initializing data for old user");
        // Creating basic user details
        await AppDatabase.instance.initializeDatabaseForUser(
          makeChats: false,
          makeGroups: false,
          makeTasks: false,
        );
        // TODO: Fetch the currently present user data from firestore
        print("Do something if the user data is already present");
      }

      // //
      // //
      // //
      // // delete current data
      // if (state.currentLoginState != CurrentLoginState.choseNotToLogIn) {
      //   // because in case if we previously had CurrentLoginState.choseNotToLogIn
      //   // we would probably want the user data to carry forward
      //   // AND ONLY OTHERWISE GIVE THE USER A FRESH START
      //   await AppDatabase.instance.deleteDatabase();
      //   await NotificationHandler.cancelAllNotification();
      //   if (userCredential!.additionalUserInfo!.isNewUser) {
      //     print("Making new database for new user");
      //     await AppDatabase.instance.initializeDatabaseForNewUsers(
      //         currentUser: Person(
      //       name: newUser.email,
      //       uid: newUser.uid,
      //       email: newUser.email,
      //     ));
      //     await NotificationHandler.initializeAllTasksReminder();
      //   } else {
      //     // TODO: Fetch the currently present user data from firestore
      //     print("Do something if the user data is already present");
      //   }
      // } else {
      //   // iska matlab user had first decided not to log in(created tasks[liked the app]) then later logged in
      //   // in general, we simply want to carry forward the tasks he created there,
      //   // ! but what if the user is not new
      //   //  * in that case we simply fetch the latest data that was there initially
      //   //  * and nothing more
      //   // ? So we carry forward the data only if the logged user is [new]
      //   // TODO: Replace all [Task], [User],  [Chat], [Group] information with new UID, instead of [defaultUserUID]
      //   print("Updating all task information with new UID");
      // }

      // userCredential.additionalUserInfo.isNewUser
      // if(userCredential != null){
      //   userCredential.
      // }
      emit(LoginState(currentLoginState: CurrentLoginState.loggedIn));
    }
  }

  void userChoseNotToLogin() async {
    if (state.currentLoginState != CurrentLoginState.choseNotToLogIn) {
      // delete current data
      await AppDatabase.instance.deleteDatabase();
      await NotificationHandler.cancelAllNotification();
      // initialize with new data
      print("Making new database for new user that userChoseNotToLogin");
      await AppDatabase.instance.initializeDatabaseForUser();
      await NotificationHandler.initializeAllTasksReminder();
      emit(LoginState(currentLoginState: CurrentLoginState.choseNotToLogIn));
    }
  }

  // In case we have to do more stuff with the log out process
  void userLoggedOut() async {
    //delete current data
    await AppDatabase.instance.deleteDatabase();
    await NotificationHandler.cancelAllNotification();
    emit(LoginState(currentLoginState: CurrentLoginState.loggedOut));
  }

  @override
  LoginState? fromJson(Map<String, dynamic> json) {
    // // TODO: implement fromJson
    // throw UnimplementedError();
    return LoginState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(LoginState state) {
    // // TODO: implement toJson
    // throw UnimplementedError();
    return state.toMap();
  }
}
