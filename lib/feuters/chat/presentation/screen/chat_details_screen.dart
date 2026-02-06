import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skilltok/core/models/message_model.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:intl/intl.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'dart:ui' as ui;
import 'package:skilltok/core/theme/emoji_text.dart';
import 'package:skilltok/core/utils/constants/primary/emoji_picker_container.dart';

class ChatDetailsScreen extends StatefulWidget {
  final UserModel otherUser;

  const ChatDetailsScreen({super.key, required this.otherUser});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Mark as seen when entering
    if (userCubit.userModel != null) {
      chatCubit.markAsSeen(userCubit.userModel!.uid!, widget.otherUser.uid!);
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    if (userCubit.userModel != null) {
      chatCubit.sendMessage(
        receiverId: widget.otherUser.uid!,
        text: _messageController.text.trim(),
        currentUser: userCubit.userModel!,
      );
      _messageController.clear();
      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // Because we will reverse the list
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = userCubit.userModel?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.pop;
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser.photoUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(widget.otherUser.photoUrl!)
                  : null,
              child: widget.otherUser.photoUrl!.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            horizontalSpace12,
            Text(widget.otherUser.username!),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_showEmojiPicker) {
            setState(() {
              _showEmojiPicker = false;
            });
            return false;
          }
          return true;
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: chatCubit.getMessages(myId!, widget.otherUser.uid!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Using EmojiText here for consistency even though it's static
                    return Center(
                      child: EmojiText(
                        text: appTranslation().get('say_hello'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  final messages = snapshot.data!;

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == myId;

                      return Align(
                        alignment: isMe
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,

                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? ColorsManager.primary
                                : Colors.grey[200],
                            borderRadius: BorderRadiusDirectional.only(
                              topStart: const Radius.circular(16),
                              topEnd: const Radius.circular(16),
                              bottomStart: isMe
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              bottomEnd: isMe
                                  ? Radius.zero
                                  : const Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              EmojiText(
                                text: message.text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat.jm().format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    message.timestamp,
                                  ),
                                ),
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                              if (isMe)
                                Icon(
                                  Icons.done_all,
                                  size: 12,
                                  color: message.seen
                                      ? Colors.blue[100]
                                      : Colors.white60,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                textDirection: ui.TextDirection.ltr,

                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showEmojiPicker = !_showEmojiPicker;
                        if (_showEmojiPicker) {
                          _focusNode.unfocus();
                        } else {
                          _focusNode.requestFocus();
                        }
                      });
                    },
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: _showEmojiPicker
                          ? ColorsManager.primary
                          : Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: appTranslation().get('type_a_message'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  horizontalSpace12,
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: ColorsManager.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            EmojiPickerContainer(
              isVisible: _showEmojiPicker,
              controller: _messageController,
            ),
          ],
        ),
      ),
    );
  }
}
