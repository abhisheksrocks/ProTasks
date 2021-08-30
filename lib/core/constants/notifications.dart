import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:protasks/core/themes/app_theme.dart';

class Notifications {
  // static final NotificationChannel minPriorityReminderNotificationChannel =
  //     NotificationChannel(
  //   channelKey: 'min_priority_reminder_channel',
  //   channelName: 'Min Priority Reminder Channel',
  //   channelDescription:
  //       'Channel to provide you Min Priority reminder notifications',
  //   defaultColor: AppTheme.lowPriorityColor,
  //   ledColor: AppTheme.lowPriorityColor,
  //   importance: NotificationImportance.Min, //Notification with no alert
  //   // vibrationPattern: lowVibrationPattern,
  // );

  static final NotificationChannel lowPriorityReminderNotificationChannel =
      NotificationChannel(
    channelKey: 'low_priority_reminder_channel',
    channelName: 'Low Priority Reminder Channel',
    channelDescription:
        'Channel to provide you Low Priority reminder notifications',
    defaultColor: AppTheme.lowPriorityColor,
    ledColor: AppTheme.lowPriorityColor,
    importance: NotificationImportance.Low, //Notification with no alert
    // vibrationPattern: lowVibrationPattern,
  );

  static final NotificationChannel mediumPriorityReminderNotificationChannel =
      NotificationChannel(
    channelKey: 'medium_priority_reminder_channel',
    channelName: 'Medium Priority Reminder Channel',
    channelDescription:
        'Channel to provide you Medium Priority reminder notifications',
    defaultColor: AppTheme.mediumPriorityColor,
    ledColor: AppTheme.mediumPriorityColor,
    importance: NotificationImportance.Default,
    // vibrationPattern: mediumVibrationPattern,
    vibrationPattern: lowVibrationPattern,
  );

  static final NotificationChannel highPriorityReminderNotificationChannel =
      NotificationChannel(
    channelKey: 'high_priority_reminder_channel',
    channelName: 'High Priority Reminder Channel',
    channelDescription:
        'Channel to provide you High Priority reminder notifications',
    defaultColor: AppTheme.highPriorityColor,
    ledColor: AppTheme.highPriorityColor,
    importance: NotificationImportance.High,
    vibrationPattern: highVibrationPattern,
  );

  // static final NotificationActionButton markAsReadActionButton =
  //     NotificationActionButton(
  //   key: 'MARK_AS_READ',
  //   label: 'Mark as Read',
  //   buttonType: ActionButtonType.KeepOnTop, // Doesn't brings app to front
  // );

  static final NotificationActionButton markAsCompletedActionButton =
      NotificationActionButton(
    key: 'MARK_AS_FINISHED',
    label: 'Complete',
    buttonType: ActionButtonType.Default, // Doesn't brings app to front
  );
}
