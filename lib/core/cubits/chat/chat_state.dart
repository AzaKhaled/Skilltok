part of 'chat_cubit.dart';

abstract class ChatStates {}

class ChatInitialState extends ChatStates {}

class ChatLoadingState extends ChatStates {}

class ChatErrorState extends ChatStates {
  final String error;
  ChatErrorState(this.error);
}

class ChatSendMessageSuccessState extends ChatStates {}

class ChatSendMessageErrorState extends ChatStates {
  final String error;
  ChatSendMessageErrorState(this.error);
}

class ChatGetChatsSuccessState extends ChatStates {
  // List of chat metadata (chatId, lastMessage, otherUserId, etc.)
  final List<Map<String, dynamic>> chats;
  ChatGetChatsSuccessState(this.chats);
}
