import 'package:flutter/material.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/cubits/comment/comment_cubit.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';

class CommentInputBar extends StatelessWidget {
  final bool isEmojiVisible;
  final FocusNode focusNode;
  final VoidCallback onEmojiToggle;
  final PostModel post;

  const CommentInputBar({
    super.key,
    required this.isEmojiVisible,
    required this.focusNode,
    required this.onEmojiToggle,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final commentCubit = CommentCubit.get(context);
    final userCubit = UserCubit.get(context);

    final isReplying = commentCubit.replyToUsername != null;
    final hint = isReplying
        ? '${appTranslation().get('reply_to')} @${commentCubit.replyToUsername}'
        : appTranslation().get('add_comment');

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isEmojiVisible ? Icons.keyboard : Icons.emoji_emotions_outlined,
            ),
            color: ColorsManager.primary,
            onPressed: () {
              onEmojiToggle();
              isEmojiVisible
                  ? focusNode.unfocus()
                  : FocusScope.of(context).requestFocus(focusNode);
            },
          ),
          Expanded(
            child: TextFormField(
              focusNode: focusNode,
              controller: commentCubit.commentController,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
          if (isReplying) ...[
            horizontalSpace8,
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => commentCubit.clearReplyTarget(),
            ),
          ],
          horizontalSpace8,
          IconButton(
            icon: const Icon(Icons.send),
            color: ColorsManager.primary,
            onPressed: () {
              if (commentCubit.commentController.text.isNotEmpty) {
                commentCubit.submitComment(
                  postId: post.postId,
                  postOwnerId: post.userId,
                  userModel: userCubit.userModel!,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
