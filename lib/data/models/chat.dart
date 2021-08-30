import 'package:enum_to_string/enum_to_string.dart';
import 'package:sembast/timestamp.dart';

import 'package:protasks/core/constants/enums.dart';

class Chat {
  final String id;

  // Idea being reference can be just a Task or even a group
  // Although it will be just taskID for now
  final String refId;

  final DateTime time;
  final bool isSeen;
  final MessageType messageType;
  final String fromUID;
  final String messageContent;
  final String replyToChatId;
  final bool isSynced;

  // final String groupId;
  // This is added for online db easiness

  Chat({
    required this.id,
    required this.refId,
    required this.time,
    required this.isSeen,
    required this.messageType,
    required this.fromUID,
    required this.messageContent,
    required this.replyToChatId,
    required this.isSynced,
    // required this.groupId,
  });

  @override
  String toString() {
    return 'Chat(id: $id, refId: $refId, time: $time, isSeen: $isSeen, messageType: $messageType, fromUID: $fromUID, messageContent: $messageContent, replyToChatId: $replyToChatId, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chat &&
        other.id == id &&
        other.refId == refId &&
        other.time == time &&
        other.isSeen == isSeen &&
        other.messageType == messageType &&
        other.fromUID == fromUID &&
        other.messageContent == messageContent &&
        other.replyToChatId == replyToChatId &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        refId.hashCode ^
        time.hashCode ^
        isSeen.hashCode ^
        messageType.hashCode ^
        fromUID.hashCode ^
        messageContent.hashCode ^
        replyToChatId.hashCode ^
        isSynced.hashCode;
  }

  Map<String, dynamic> toMapForDatabase() {
    return {
      'id': id,
      'refId': refId,
      'time': Timestamp.fromDateTime(time.toUtc()),
      'isSeen': isSeen,
      'messageType': EnumToString.convertToString(messageType),
      'messageContent': messageContent,
      'fromUID': fromUID,
      'replyToChatId': replyToChatId,
      'isSynced': isSynced,
      // 'groupId': groupId,
    };
  }

  static Chat fromMapOfDatabase(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      refId: map['refId'],
      time: (map['time'] as Timestamp).toDateTime(),
      isSeen: map['isSeen'],
      messageType:
          EnumToString.fromString(MessageType.values, map['messageType']) ??
              MessageType.text,
      messageContent: map['messageContent'],
      fromUID: map['fromUID'],
      replyToChatId: map['replyToChatId'],
      isSynced: map['isSynced'],
      // groupId: map['groupId'],
    );
  }

  Chat copyWith({
    String? id,
    String? refId,
    DateTime? time,
    bool? isSeen,
    MessageType? messageType,
    String? fromUID,
    String? messageContent,
    String? replyToChatId,
    bool? isSynced,
  }) {
    return Chat(
      id: id ?? this.id,
      refId: refId ?? this.refId,
      time: time ?? this.time,
      isSeen: isSeen ?? this.isSeen,
      messageType: messageType ?? this.messageType,
      fromUID: fromUID ?? this.fromUID,
      messageContent: messageContent ?? this.messageContent,
      replyToChatId: replyToChatId ?? this.replyToChatId,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
