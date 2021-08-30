import 'package:protasks/core/constants/enums.dart';
import 'package:enum_to_string/enum_to_string.dart';

class NotificationPayload {
  final NotificationFor notificationFor;
  final String id;
  NotificationPayload({
    required this.notificationFor,
    required this.id,
  });

  Map<String, String> toMap() {
    return {
      'notificationFor': EnumToString.convertToString(notificationFor),
      'id': id,
    };
  }

  factory NotificationPayload.fromMap(Map<String, String> map) {
    return NotificationPayload(
      notificationFor: EnumToString.fromString(
            NotificationFor.values,
            map['notificationFor']!,
          ) ??
          NotificationFor.task,
      id: map['id']!,
    );
  }
}
