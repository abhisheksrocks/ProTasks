enum TaskPriority {
  // undefined,
  low,
  medium,
  high,
  // globalLow,
  // globalMedium,
  // globalHigh,
}

enum MessageType {
  text,
  log,
  attachment,
}

enum CurrentButtonState {
  disabled,
  normal,
  loading,
  success,
  failure,
}

// Used in CurrentReminderWidget
enum CurrentReminderOption {
  mins,
  hrs,
  days,
  weeks,
}

enum CurrentLoginState {
  loggedOut,
  loggedIn,
  choseNotToLogIn,
}

// enum MessageDeliveryState {
//   enqueued,
//   sent,
// }

enum CurrentSyncState {
  initialized,
  complete,
  waiting,
  inProgress,
  deviceOffline,
  serverError,
}

enum ReturnStatus {
  success,
  failure,
}

enum DatabaseInsertStatus {
  createdNew,
  updatedValue,
  insertFailed,
}

enum CurrentPremiumState {
  freeUser,
  pseudoProUser,
}

enum NotificationFor {
  task,
  group,
}
