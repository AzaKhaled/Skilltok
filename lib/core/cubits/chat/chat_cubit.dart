import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/models/message_model.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/network/chat_repository.dart';
import 'package:skilltok/core/network/service/notification_service.dart';
import 'package:skilltok/core/network/user_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatStates> {
  ChatCubit() : super(ChatInitialState());

  static ChatCubit get(BuildContext context) => BlocProvider.of(context);

  final ChatRepository _chatRepo = ChatRepository();
  final UserRepository _userRepo = UserRepository();

  List<Map<String, dynamic>> chats = [];

  void sendMessage({
    required String receiverId,
    required String text,
    String? imageUrl,
    required UserModel currentUser,
  }) {
    // Optimistic UI update could be done here, but for now we rely on stream
    _chatRepo
        .sendMessage(
          senderId: currentUser.uid!,
          receiverId: receiverId,
          text: text,
          imageUrl: imageUrl,
        )
        .then((_) async {
          // Send Notification
          await NotificationService.send(
            receiverId: receiverId,
            title: currentUser.username!,
            contents: {
              "en": text,
              "ar": text,
            }, // Chat messages are usually just the content
            data: {
              "type": "chat",
              "senderId": currentUser.uid!,
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
            },
          );
          // We generally don't save Chat Messages to "Activity Feed" notifications (NotificationRepository)
          // because that would clutter the notification tab. Chat has its own tab.

          emit(ChatSendMessageSuccessState());
        })
        .catchError((error) {
          emit(ChatSendMessageErrorState(error.toString()));
        });
  }

  void getChats(String userId) {
    emit(ChatLoadingState());
    _chatRepo.getChats(userId).listen((chatList) async {
      // We need to fetch User Details for each chat (the 'other' participant)
      // This might be expensive if many chats, but necessary if we don't duplicate data.

      List<Map<String, dynamic>> enrichedChats = [];

      for (var chat in chatList) {
        List<dynamic> participants = chat['participants'];
        String otherUserId = participants.firstWhere(
          (id) => id != userId,
          orElse: () => "",
        );

        if (otherUserId.isNotEmpty) {
          final userDoc = await _userRepo.getUser(otherUserId);
          if (userDoc != null) {
            chat['otherUser'] = userDoc;
            enrichedChats.add(chat);
          }
        }
      }

      chats = enrichedChats;
      // Sort in memory since we removed Firestore orderBy
      chats.sort((a, b) {
        final timeA = a['lastMessageTime'] as int? ?? 0;
        final timeB = b['lastMessageTime'] as int? ?? 0;
        return timeB.compareTo(timeA); // Descending
      });

      emit(ChatGetChatsSuccessState(chats));
    });
  }

  Stream<List<MessageModel>> getMessages(String senderId, String receiverId) {
    return _chatRepo.getMessages(senderId, receiverId);
  }

  void markAsSeen(String senderId, String receiverId) {
    _chatRepo.markMessagesAsSeen(senderId, receiverId);
  }
}
