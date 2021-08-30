part of 'task_chat_cubit.dart';

@immutable
abstract class TaskChatState {}

class TaskChatLoading extends TaskChatState {}

class TaskChatLoaded extends TaskChatState {}
