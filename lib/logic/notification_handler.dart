import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/notifications.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:protasks/data/data_providers/tasks_dao.dart';
import 'package:protasks/data/models/notification_payload.dart';
import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/logic/my_navigator.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/task_details_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationHandler {
  static Future<void> initializeAllTasksReminder() async {
    List<Task> listOfUpcomingUnfinishedTasks =
        await TasksDao().getUpcomingUnfinishedTasks();
    // List<PushNotification> scheduledNotification =
    //     await AwesomeNotifications().listScheduledNotifications();
    // scheduledNotification.first.content.id
    for (Task currentTask in listOfUpcomingUnfinishedTasks) {
      await makeTaskReminder(MyNavigator.context, givenTask: currentTask);
    }
    print("All Task Reminders Initialized");
  }

  static void initialiseNotificationListener() {
    // AwesomeNotifications().createdStream.listen((receivedNotification) {
    //   receivedNotification.
    // });
    // AwesomeNotifications().dismissedStream.listen((receivedAction) async {
    //   Fluttertoast.showToast(msg: "dismissedStream called");
    //   print("Navcontext: ${Navigator.of(MyNavigator.context!)}");
    //   print(
    //       "ModalRoute.of(context).settings.name: ${ModalRoute.of(MyNavigator.context!)?.settings.name}");
    //   print(
    //       "receivedAction: $receivedAction\n receivedAction.buttonKeyPressed: ${receivedAction.buttonKeyPressed}");
    //   print("receivedAction.payload: ${receivedAction.payload}");
    //   NotificationPayload? _notificationPayload;
    //   if (receivedAction.payload != null &&
    //       receivedAction.payload!.isNotEmpty) {
    //     _notificationPayload =
    //         NotificationPayload.fromMap(receivedAction.payload!);
    //   }
    //   if (_notificationPayload == null) {
    //     Fluttertoast.showToast(msg: "Error Occured! NotificationPayload empty");
    //   }

    //   if (receivedAction.buttonKeyPressed.isEmpty) {
    //     switch (receivedAction.actionLifeCycle) {
    //       case NotificationLifeCycle.AppKilled:
    //         Navigator.of(MyNavigator.context!).pushNamed(AppRouter.dashboard);
    //         break;
    //       case NotificationLifeCycle.Foreground:
    //         break;
    //       case NotificationLifeCycle.Background:
    //         break;
    //       default:
    //         Navigator.of(MyNavigator.context!).pushNamed(AppRouter.dashboard);
    //     }
    //     if (_notificationPayload != null) {
    //       if (_notificationPayload.notificationFor == NotificationFor.task) {
    //         final Task? task = await TasksDao()
    //             .getSingleTaskDetailsStream(taskId: _notificationPayload.id)
    //             .first;

    //         if (task != null) {
    //           showModalBottomSheet(
    //             isScrollControlled: true,
    //             context: MyNavigator.context!,
    //             builder: (BuildContext context) {
    //               return TaskDetailsModalSheetProvider(
    //                 task: task,
    //               );
    //             },
    //           );
    //         } else {
    //           Fluttertoast.showToast(msg: "Couldn't find the task");
    //         }
    //       } else {
    //         // TODO: Group notification handling
    //         Fluttertoast.showToast(
    //             msg: "Any other notification handling not supported");
    //       }
    //       return;
    //     }
    //     return;
    //   } else if (receivedAction.buttonKeyPressed ==
    //       Notifications.markAsCompletedActionButton.key) {
    //     Fluttertoast.showToast(msg: "Message received");
    //     // if (_notificationPayload != null) {
    //     //   if (_notificationPayload.notificationFor == NotificationFor.task) {
    //     //     switch (receivedAction.actionLifeCycle) {
    //     //       case NotificationLifeCycle.AppKilled:
    //     //         Navigator.of(MyNavigator.context!)
    //     //             .pushNamed(AppRouter.dashboard);
    //     //         break;
    //     //       case NotificationLifeCycle.Foreground:
    //     //         break;
    //     //       case NotificationLifeCycle.Background:
    //     //         break;
    //     //       default:
    //     //         Navigator.of(MyNavigator.context!)
    //     //             .pushNamed(AppRouter.dashboard);
    //     //     }
    //     //     await TasksDao()
    //     //         .changeIsCompletedNew(taskId: _notificationPayload.id);
    //     //   } else {
    //     //     Fluttertoast.showToast(
    //     //       msg:
    //     //           "markAsCompletedActionButton doesn't handle anything except task",
    //     //     );
    //     //   }
    //     // }
    //     return;
    //     // AwesomeNotifications().dismiss(1);
    //     // showModalBottomSheet(
    //     //   context: MyNavigator.context!,
    //     //   isScrollControlled: true,
    //     //   enableDrag: false,
    //     //   builder: (context) => AddNewTaskModalSheetProviderNew(),
    //     // );'

    //     // if (Navigator.canPop(context)) {
    //     //   Navigator.pushNamedAndRemoveUntil(
    //     //     context,
    //     //     AppRouter.dashboard,
    //     //     (route) => (route.settings.name != AppRouter.dashboard),
    //     //   );
    //     // } else {
    //     // switch (receivedAction.actionLifeCycle) {
    //     //   case NotificationLifeCycle.AppKilled:
    //     //     // if (!Navigator.of(MyNavigator.context!)
    //     //     //     .isCurrent(AppRouter.dashboard)) {
    //     //     //   Navigator.of(MyNavigator.context!)
    //     //     //       .pushNamed(AppRouter.dashboard);
    //     //     // }
    //     //     Navigator.pushNamedAndRemoveUntil(
    //     //         MyNavigator.context!, AppRouter.dashboard, (route) {
    //     //       print("route: $route");
    //     //       print("route.settings : ${route.settings}");
    //     //       print("route.settings.name : ${route.settings.name}");
    //     //       return (route.settings.name != AppRouter.dashboard);
    //     //     });
    //     //     break;

    //     //   case NotificationLifeCycle.Foreground:
    //     //     print(
    //     //         "Navigator.of(context).isCurrent(AppRouter.dashboard): ${Navigator.of(MyNavigator.context!).isCurrent(AppRouter.dashboard)}");
    //     //     // Navigator.pushNamedAndRemoveUntil(
    //     //     //     MyNavigator.context!, AppRouter.dashboard, (route) {
    //     //     //   print("route.settings 1: ${route.settings}");
    //     //     //   print("route.settings.name 1: ${route.settings.name}");
    //     //     //   return (route.settings.name != AppRouter.dashboard);
    //     //     // }).then((_) {
    //     //     //   print("Here 2 2 2");
    //     //     // });
    //     //     Navigator.pushNamed(MyNavigator.context!, AppRouter.dashboard);
    //     //     print("Here 2 2 2");
    //     //     break;
    //     //   default:
    //     //     Navigator.pushNamedAndRemoveUntil(
    //     //       MyNavigator.context!,
    //     //       AppRouter.dashboard,
    //     //       (route) {
    //     //         print("route.settings.name 2: ${route.settings.name}");
    //     //         return (route.settings.name != AppRouter.dashboard);
    //     //       },
    //     //     );
    //     // }

    //     // Navigator.of(MyNavigator.context!)
    //     //     .pushReplacementNamed(AppRouter.dashboard);
    //     // print("Waiting for dashboard tasks");
    //     // var listOfTasks = await TasksDao().getDashboardTasks().first;
    //     // var task = await TasksDao()
    //     //     .getSingleTaskDetailsStream(
    //     //         taskId: NotificationPayload.fromMap(receivedAction.payload!).id)
    //     //     .first;
    //     // print("Got dashboard tasks");
    //     // Navigator.of(MyNavigator.context!).pushNamedAndRemoveUntil(
    //     //     AppRouter.dashboard, (route) => !route.isFirst);
    //     // Navigator.pushNamedAndRemoveUntil(
    //     //   context,
    //     //   AppRouter.dashboard,
    //     //   (route) => (route.settings.name != AppRouter.dashboard),
    //     // );

    //     // if (task == null) {
    //     //   Fluttertoast.showToast(msg: "We couldn't find the task");
    //     // } else {
    //     //   await showModalBottomSheet(
    //     //     isScrollControlled: true,
    //     //     context: MyNavigator.context!,
    //     //     builder: (BuildContext context) {
    //     //       return TaskDetailsModalSheetProvider(
    //     //         task: task,
    //     //       );
    //     //       // return TextField();
    //     //     },
    //     //   );
    //     // }

    //     // }
    //   }
    // });

    AwesomeNotifications().actionStream.listen((receivedAction) async {
      print("Navcontext: ${Navigator.of(MyNavigator.context!)}");
      print(
          "ModalRoute.of(context).settings.name: ${ModalRoute.of(MyNavigator.context!)?.settings.name}");
      print(
          "receivedAction: $receivedAction\n receivedAction.buttonKeyPressed: ${receivedAction.buttonKeyPressed}");
      print("receivedAction.payload: ${receivedAction.payload}");
      NotificationPayload? _notificationPayload;
      if (receivedAction.payload != null &&
          receivedAction.payload!.isNotEmpty) {
        _notificationPayload =
            NotificationPayload.fromMap(receivedAction.payload!);
      }
      if (_notificationPayload == null) {
        Fluttertoast.showToast(
            msg: "Error Occured! Notification Payload empty");
      }

      if (receivedAction.buttonKeyPressed.isEmpty) {
        // * Because button type is default, so app will open anyway
        // switch (receivedAction.actionLifeCycle) {
        //   case NotificationLifeCycle.AppKilled:
        //     Navigator.of(MyNavigator.context!).pushNamed(AppRouter.dashboard);
        //     break;
        //   case NotificationLifeCycle.Foreground:
        //     break;
        //   case NotificationLifeCycle.Background:
        //     break;
        //   default:
        //     Navigator.of(MyNavigator.context!).pushNamed(AppRouter.dashboard);
        // }
        if (_notificationPayload != null) {
          if (_notificationPayload.notificationFor == NotificationFor.task) {
            final Task? task = await TasksDao()
                .getSingleTaskDetailsStream(taskId: _notificationPayload.id)
                .first;

            if (task != null) {
              showModalBottomSheet(
                isScrollControlled: true,
                context: MyNavigator.context!,
                builder: (BuildContext context) {
                  return TaskDetailsModalSheetProvider(
                    task: task,
                  );
                },
              );
            } else {
              Fluttertoast.showToast(msg: "Couldn't find the task");
            }
          } else {
            // TODO: Group notification handling
            Fluttertoast.showToast(
                msg: "Any other notification handling not supported");
          }
          return;
        }
        return;
      } else if (receivedAction.buttonKeyPressed ==
          Notifications.markAsCompletedActionButton.key) {
        // Fluttertoast.showToast(msg: "Message received");
        if (_notificationPayload != null) {
          if (_notificationPayload.notificationFor == NotificationFor.task) {
            // * Because button type is default, so app will open anyway
            // * so better move the user to completed screen OR NOT(your choice)
            switch (receivedAction.actionLifeCycle) {
              // case NotificationLifeCycle.AppKilled:
              //   Navigator.of(MyNavigator.context!)
              //       .pushNamed(AppRouter.completedTasks);
              //   break;
              case NotificationLifeCycle.Foreground:
                // Navigator.of(MyNavigator.context!)
                //     .pushNamed(AppRouter.completedTasks);
                break;
              // case NotificationLifeCycle.Background:
              //   Navigator.of(MyNavigator.context!)
              //       .pushNamed(AppRouter.completedTasks);
              //   break;
              default:
                Navigator.of(MyNavigator.context!)
                    .pushNamed(AppRouter.completedTasks);
            }
            await TasksDao()
                .changeIsCompletedNew(taskId: _notificationPayload.id);
          } else {
            Fluttertoast.showToast(
              msg:
                  "markAsCompletedActionButton doesn't handle anything except task",
            );
          }
        }
        return;
        // AwesomeNotifications().dismiss(1);
        // showModalBottomSheet(
        //   context: MyNavigator.context!,
        //   isScrollControlled: true,
        //   enableDrag: false,
        //   builder: (context) => AddNewTaskModalSheetProviderNew(),
        // );'

        // if (Navigator.canPop(context)) {
        //   Navigator.pushNamedAndRemoveUntil(
        //     context,
        //     AppRouter.dashboard,
        //     (route) => (route.settings.name != AppRouter.dashboard),
        //   );
        // } else {
        // switch (receivedAction.actionLifeCycle) {
        //   case NotificationLifeCycle.AppKilled:
        //     // if (!Navigator.of(MyNavigator.context!)
        //     //     .isCurrent(AppRouter.dashboard)) {
        //     //   Navigator.of(MyNavigator.context!)
        //     //       .pushNamed(AppRouter.dashboard);
        //     // }
        //     Navigator.pushNamedAndRemoveUntil(
        //         MyNavigator.context!, AppRouter.dashboard, (route) {
        //       print("route: $route");
        //       print("route.settings : ${route.settings}");
        //       print("route.settings.name : ${route.settings.name}");
        //       return (route.settings.name != AppRouter.dashboard);
        //     });
        //     break;

        //   case NotificationLifeCycle.Foreground:
        //     print(
        //         "Navigator.of(context).isCurrent(AppRouter.dashboard): ${Navigator.of(MyNavigator.context!).isCurrent(AppRouter.dashboard)}");
        //     // Navigator.pushNamedAndRemoveUntil(
        //     //     MyNavigator.context!, AppRouter.dashboard, (route) {
        //     //   print("route.settings 1: ${route.settings}");
        //     //   print("route.settings.name 1: ${route.settings.name}");
        //     //   return (route.settings.name != AppRouter.dashboard);
        //     // }).then((_) {
        //     //   print("Here 2 2 2");
        //     // });
        //     Navigator.pushNamed(MyNavigator.context!, AppRouter.dashboard);
        //     print("Here 2 2 2");
        //     break;
        //   default:
        //     Navigator.pushNamedAndRemoveUntil(
        //       MyNavigator.context!,
        //       AppRouter.dashboard,
        //       (route) {
        //         print("route.settings.name 2: ${route.settings.name}");
        //         return (route.settings.name != AppRouter.dashboard);
        //       },
        //     );
        // }

        // Navigator.of(MyNavigator.context!)
        //     .pushReplacementNamed(AppRouter.dashboard);
        // print("Waiting for dashboard tasks");
        // var listOfTasks = await TasksDao().getDashboardTasks().first;
        // var task = await TasksDao()
        //     .getSingleTaskDetailsStream(
        //         taskId: NotificationPayload.fromMap(receivedAction.payload!).id)
        //     .first;
        // print("Got dashboard tasks");
        // Navigator.of(MyNavigator.context!).pushNamedAndRemoveUntil(
        //     AppRouter.dashboard, (route) => !route.isFirst);
        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   AppRouter.dashboard,
        //   (route) => (route.settings.name != AppRouter.dashboard),
        // );

        // if (task == null) {
        //   Fluttertoast.showToast(msg: "We couldn't find the task");
        // } else {
        //   await showModalBottomSheet(
        //     isScrollControlled: true,
        //     context: MyNavigator.context!,
        //     builder: (BuildContext context) {
        //       return TaskDetailsModalSheetProvider(
        //         task: task,
        //       );
        //       // return TextField();
        //     },
        //   );
        // }

        // }
      }
    });
  }

  static Future<bool> checkAndEnableNotifications(BuildContext context) async {
    bool isNotificationAllowed =
        await AwesomeNotifications().isNotificationAllowed();
    if (isNotificationAllowed) {
      return isNotificationAllowed;
    }
    final dialogReturn = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text('Notification Permission'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'To show the reminders, we need permission to allow notifications.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await AwesomeNotifications()
                    .requestPermissionToSendNotifications();
                Navigator.of(context)
                    .pop(await AwesomeNotifications().isNotificationAllowed());
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    if (dialogReturn != null) {
      return dialogReturn;
    }
    return false;
  }

  static void cancelNotification({
    required String taskId,
    required DateTime taskRemindTime,
  }) async {
    int notificationId = ExtraFunctions.makeIntIdFromStringIdAndDateTime(
      stringId: taskId,
      sourceDateTime: taskRemindTime,
    );
    await _cancelNotificationById(notificationId);
  }

  static Future<void> _cancelNotificationById(int notificationId) async {
    await AwesomeNotifications().cancel(notificationId);
  }

  static Future<void> cancelAllNotification() async {
    await AwesomeNotifications().cancelAll();
  }

  static Future<void> makeTaskReminder(BuildContext? context,
      {required Task givenTask}) async {
    if (givenTask.remindTime.isBefore(DateTime.now()) ||
        givenTask.isCompleted) {
      return;
    }
    bool notificationPermissionIsEnabled = true;
    if (context != null) {
      notificationPermissionIsEnabled =
          await checkAndEnableNotifications(context);
    }
    if (notificationPermissionIsEnabled) {
      String? channelKey;
      switch (givenTask.taskPriority) {
        case TaskPriority.low:
          channelKey =
              Notifications.lowPriorityReminderNotificationChannel.channelKey;
          break;
        case TaskPriority.medium:
          channelKey = Notifications
              .mediumPriorityReminderNotificationChannel.channelKey;
          break;
        default:
          channelKey =
              Notifications.highPriorityReminderNotificationChannel.channelKey;
      }

      int notificationId = ExtraFunctions.makeIntIdFromStringIdAndDateTime(
        stringId: givenTask.id,
        sourceDateTime: givenTask.remindTime,
      );

      String groupName =
          (await GroupsDao().findGroupById(groupID: givenTask.groupId).first)!
              .name;

      await _cancelNotificationById(notificationId);

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: channelKey,
          // title: "Here's your Reminder!",
          // body: givenTask.description,
          body: "Tap for more information",
          title: givenTask.description,
          // payload: <String, String>{'id': givenTask.id},
          payload: NotificationPayload(
            id: givenTask.id,
            notificationFor: NotificationFor.task,
          ).toMap(),
          // body: "<b>${givenTask.description}</b>",
          // bigPicture: givenTask.description,
          summary: groupName,
          notificationLayout: NotificationLayout
              .BigText, // * Summary is only visible with BigText and Inbox *
        ),
        actionButtons: [
          Notifications.markAsCompletedActionButton,
        ],
        schedule: NotificationCalendar.fromDate(
          date: givenTask.remindTime,
          allowWhileIdle: true,
        ),
      );
    }
  }

  // ! Can be removed
  // BuildContext is required to show a dialog box with notification permission, if
  // permission is not yet been given
  static Future<void> createBasicNotification(BuildContext context) async {
    if (await checkAndEnableNotifications(context)) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: ExtraFunctions.dateTimeToIntTimestamp(DateTime.now()),
          channelKey: Notifications
              .mediumPriorityReminderNotificationChannel.channelKey,
          title: 'Notification Test',
          body: 'Test notification',
          summary: 'Test',
          payload: NotificationPayload(
            notificationFor: NotificationFor.task,
            id: 'Af2201baDC36964ea2DA01e1Dd6Cc0',
          ).toMap(),
          notificationLayout: NotificationLayout.BigText,
        ),
        actionButtons: [
          Notifications.markAsCompletedActionButton,
        ],
      );
    }
  }
}
