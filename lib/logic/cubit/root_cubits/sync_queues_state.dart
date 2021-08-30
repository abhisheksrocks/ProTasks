part of 'sync_queues_cubit.dart';

@immutable
class SyncQueuesState {
  final List<String> groupIdsToSync;
  final List<String> taskIdsToSync;
  final List<String> chatIdsToSync;
  final List<String> userIdsToSync;
  SyncQueuesState({
    required this.groupIdsToSync,
    required this.taskIdsToSync,
    required this.chatIdsToSync,
    required this.userIdsToSync,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupIdsToSync': groupIdsToSync,
      'taskIdsToSync': taskIdsToSync,
      'chatIdsToSync': chatIdsToSync,
      'userIdsToSync': userIdsToSync,
    };
  }

  factory SyncQueuesState.fromMap(Map<String, dynamic> map) {
    return SyncQueuesState(
      groupIdsToSync: List<String>.from(map['groupIdsToSync']),
      taskIdsToSync: List<String>.from(map['taskIdsToSync']),
      chatIdsToSync: List<String>.from(map['chatIdsToSync']),
      userIdsToSync: List<String>.from(map['userIdsToSync']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncQueuesState.fromJson(String source) =>
      SyncQueuesState.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SyncQueuesState(groupIdsToSync: $groupIdsToSync, taskIdsToSync: $taskIdsToSync, chatIdsToSync: $chatIdsToSync, userIdsToSync: $userIdsToSync)';
  }
}
