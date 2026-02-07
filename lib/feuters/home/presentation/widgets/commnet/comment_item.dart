import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skilltok/core/models/comment_model.dart';
import 'package:skilltok/core/theme/colors.dart';

import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/feuters/home/presentation/widgets/commnet/comment_context_menu.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/core/cubits/comment/comment_cubit.dart';

import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/cubits/theme/theme_cubit.dart';
import 'package:skilltok/core/theme/emoji_text.dart';

class CommentItem extends StatelessWidget {
  final String postId;
  final CommentModel comment;
  final int indentLevel;

  const CommentItem({
    super.key,
    required this.postId,
    required this.comment,
    this.indentLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    final userCubit = UserCubit.get(context);
    final commentCubit = CommentCubit.get(context);
    final themeCubit = ThemeCubit.get(context);
    final isMe = userCubit.userModel?.uid == comment.userId;
    final currentUserId = userCubit.userModel?.uid ?? '';
    final isReacted = comment.reactions.contains(currentUserId);
    // Removed unused card variable

    // Direct return of logic since we removed the previous card wrapper
    // Old card block removed

    final bool isReply = indentLevel > 0;
    final double avatarSize = isReply ? 12 : 18;
    // Indent: if reply, push significantly.
    // Parent avatar (36) + space (12) + margin (12) = 60.
    // So reply padding should start around there.
    // Let's use left padding based on indent level logic but customized.
    final double leftPadding = isReply
        ? (44.0 + (indentLevel - 1) * 20.0)
        : 0.0;

    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () =>
                      context.push(Routes.profile, arguments: comment.userId),
                  child: CircleAvatar(
                    radius: avatarSize,
                    backgroundImage: comment.userProfilePic.isNotEmpty
                        ? CachedNetworkImageProvider(comment.userProfilePic)
                        : null,
                    child: comment.userProfilePic.isEmpty
                        ? Icon(Icons.person, size: avatarSize)
                        : null,
                  ),
                ),
                horizontalSpace12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  ...EmojiText.parse(
                                    text: "${comment.username}  ",
                                    style: isReply
                                        ? TextStylesManager.bold12.copyWith(
                                            color: themeCubit.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          )
                                        : TextStylesManager.bold14.copyWith(
                                            color: themeCubit.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                  ),
                                  ...EmojiText.parse(
                                    text: comment.text,
                                    style: isReply
                                        ? TextStylesManager.regular12.copyWith(
                                            color: themeCubit.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          )
                                        : TextStylesManager.regular14.copyWith(
                                            color: themeCubit.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Heart Icon on Right
                          InkWell(
                            onTap: () => commentCubit.toggleCommentReaction(
                              postId: postId,
                              commentId: comment.commentId,
                              currentUserId: currentUserId,
                              commentOwnerId: comment.userId,
                              userModel: userCubit.userModel!,
                              isLiked: isReacted,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isReacted
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 14,
                                  color: isReacted ? Colors.red : Colors.grey,
                                ),
                                if (comment.reactions.isNotEmpty)
                                  Text(
                                    comment.reactions.length.toString(),
                                    style: TextStylesManager.regular12.copyWith(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      verticalSpace4,
                      if (comment.replyToUsername != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${appTranslation().get('replying_to')} @${comment.replyToUsername}',
                            style: TextStylesManager.regular12.copyWith(
                              color: ColorsManager.primary.withValues(
                                alpha: .8,
                              ),
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Text(
                            DateFormat.yMMMd().add_jm().format(
                              comment.timestamp.toDate(),
                            ),
                            style: TextStylesManager.regular12.copyWith(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: () {
                              commentCubit.setReplyTarget(
                                commentId: comment.commentId,
                                username: comment.username,
                                userId: comment.userId,
                              );
                            },
                            child: Text(
                              appTranslation().get('reply'),
                              style: TextStylesManager.bold12.copyWith(
                                color: Colors
                                    .grey, // Instagram uses grey for 'Reply'
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: () => CommentContextMenu.showMenu(
                              context,
                              isMe: isMe,
                              postId: postId,
                              comment: comment,
                              child: const SizedBox(),
                              // We just want logic, typically context menus open from an anchor.
                              // But since existing logic wraps a child, we can just trigger it.
                              // Alternatively, we can just use the more_vert icon as before but smaller/placed differently if desired.
                              // Wait, user asked for Instagram style. Instagram has NO 3-dots on comment usually, they use long-press or swipe.
                              // But we'll keep the button for functionality but maybe make it subtle or just use the whole item for context?
                              // The user complained about "clicking 3 dots" causing overflow in the previous request.
                              // For now, let's keep it simple: no 3 dots in the row, maybe long press on the text?
                              // I will leave the 3 dots but maybe hidden or less intrusive.
                              // Actually, let's keep the more_vert but maybe in the metadata row properly.
                            ),
                            child:
                                const SizedBox.shrink(), // hiding explicit 3 dots to look like clean instagram, assuming long press or similar might be better eventually.
                            // BUT wait, previous user request mentioned pressing 3 dots.
                            // I should probably keep a way to access options.
                            // Let's add it back to the end or keep it overlay.
                          ),
                          // Let's add the 3 dots to the end of the metadata row for robust access
                          InkWell(
                            onTap: () => CommentContextMenu.showMenu(
                              context,
                              isMe: isMe,
                              postId: postId,
                              comment: comment,
                              child: Container(), // Dummy
                            ),
                            child: const Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
