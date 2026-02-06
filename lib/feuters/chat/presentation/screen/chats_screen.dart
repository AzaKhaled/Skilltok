import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/cubits/chat/chat_cubit.dart';

import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    if (userCubit.userModel != null) {
      chatCubit.getChats(userCubit.userModel!.uid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTranslation().get('my_chats')),
        centerTitle: true,
      ),
      body: BlocBuilder<ChatCubit, ChatStates>(
        builder: (context, state) {
          final myId = userCubit.userModel?.uid;

          if (state is ChatLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatCubit.chats.isEmpty) {
            // If loading finished but empty
            if (state is! ChatLoadingState) {
              return Center(child: Text("No chats yet"));
            }
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: chatCubit.chats.length,
            itemBuilder: (context, index) {
              final chat = chatCubit.chats[index];
              final UserModel otherUser = chat['otherUser'];
              final lastMessage = chat['lastMessage'] ?? '';
              final lastMessageTime = chat['lastMessageTime'];
              final unreadCounts =
                  chat['unreadCounts'] as Map<String, dynamic>?;
              final unreadCount = unreadCounts != null && myId != null
                  ? (unreadCounts[myId] ?? 0)
                  : 0;

              return ListTile(
                onTap: () {
                  context.push(Routes.chatDetails, arguments: otherUser);
                },
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: otherUser.photoUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(otherUser.photoUrl!)
                      : null,
                  child: otherUser.photoUrl!.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(
                  otherUser.username!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: unreadCount > 0
                        ? ColorsManager.primary
                        : Colors.grey,
                    fontWeight: unreadCount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (lastMessageTime != null)
                      Text(
                        timeago.format(
                          DateTime.fromMillisecondsSinceEpoch(lastMessageTime),
                          locale: 'en_short',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: ColorsManager.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
