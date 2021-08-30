part of 'sync_cubit.dart';

@immutable
class SyncState {
  final CurrentSyncState currentSyncState;
  final DateTime lastGroupSyncTime;
  final DateTime lastTaskSyncTime;
  final DateTime lastChatSyncTime;
  final DateTime lastUserSyncTime;
  // final DateTime lastGroupDownloadTime;
  // final DateTime lastTaskDownloadTime;
  // final DateTime lastChatDownloadTime;
  // final DateTime lastUserDownloadTime;
  // final DateTime lastGroupUploadTime;
  // final DateTime lastTaskUploadTime;
  // final DateTime lastChatUploadTime;
  SyncState({
    required this.currentSyncState,
    required this.lastGroupSyncTime,
    required this.lastTaskSyncTime,
    required this.lastChatSyncTime,
    required this.lastUserSyncTime,
    // required this.lastGroupDownloadTime,
    // required this.lastTaskDownloadTime,
    // required this.lastChatDownloadTime,
    // required this.lastUserDownloadTime,
    // required this.lastGroupUploadTime,
    // required this.lastTaskUploadTime,
    // required this.lastChatUploadTime,
  });

  @override
  String toString() {
    return 'SyncState(currentSyncState: $currentSyncState, lastGroupSyncTime: $lastGroupSyncTime, lastTaskSyncTime: $lastTaskSyncTime, lastChatSyncTime: $lastChatSyncTime, lastUserSyncTime: $lastUserSyncTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SyncState &&
        other.currentSyncState == currentSyncState &&
        other.lastGroupSyncTime == lastGroupSyncTime &&
        other.lastTaskSyncTime == lastTaskSyncTime &&
        other.lastChatSyncTime == lastChatSyncTime &&
        other.lastUserSyncTime == lastUserSyncTime;
  }

  @override
  int get hashCode {
    return currentSyncState.hashCode ^
        lastGroupSyncTime.hashCode ^
        lastTaskSyncTime.hashCode ^
        lastChatSyncTime.hashCode ^
        lastUserSyncTime.hashCode;
  }

  Map<String, dynamic> toMap() {
    return {
      'currentSyncState': EnumToString.convertToString(currentSyncState),
      'lastGroupSyncTime': lastGroupSyncTime.millisecondsSinceEpoch,
      'lastTaskSyncTime': lastTaskSyncTime.millisecondsSinceEpoch,
      'lastChatSyncTime': lastChatSyncTime.millisecondsSinceEpoch,
      'lastUserSyncTime': lastUserSyncTime.millisecondsSinceEpoch,
    };
  }

  factory SyncState.fromMap(Map<String, dynamic> map) {
    return SyncState(
      currentSyncState: EnumToString.fromString(
              CurrentSyncState.values, map['currentSyncState']) ??
          CurrentSyncState.initialized,
      lastGroupSyncTime:
          DateTime.fromMillisecondsSinceEpoch(map['lastGroupSyncTime']).toUtc(),
      lastTaskSyncTime:
          DateTime.fromMillisecondsSinceEpoch(map['lastTaskSyncTime']).toUtc(),
      lastChatSyncTime:
          DateTime.fromMillisecondsSinceEpoch(map['lastChatSyncTime']).toUtc(),
      lastUserSyncTime:
          DateTime.fromMillisecondsSinceEpoch(map['lastUserSyncTime']).toUtc(),
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncState.fromJson(String source) =>
      SyncState.fromMap(json.decode(source));
}
