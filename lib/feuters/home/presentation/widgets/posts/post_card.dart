import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/emoji_text.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/feuters/home/presentation/widgets/posts/action_buttom.dart';
import 'package:skilltok/feuters/home/presentation/widgets/posts/video_player.dart';
import 'package:skilltok/feuters/home/presentation/widgets/commnet/comments_sheet.dart';
import 'package:skilltok/feuters/home/presentation/widgets/posts/likes_list_sheet.dart';

bool isVideo(String url) {
  return url.contains('/video/upload') ||
      url.endsWith('.mp4') ||
      url.endsWith('.mov') ||
      url.endsWith('.webm');
}

// ================== POST CARD ==================
class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final userCubit = UserCubit.get(context);
    final postCubit = PostCubit.get(context);
    final isLiked = post.likes.contains(userCubit.userModel?.uid);

    return Card(
      elevation: 0.6,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: ColorsManager.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== USER ROW + MENU =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        context.push(Routes.profile, arguments: post.userId),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: ColorsManager.primary.withValues(
                            alpha: .1,
                          ),
                          backgroundImage: post.userProfilePic.isNotEmpty
                              ? CachedNetworkImageProvider(post.userProfilePic)
                              : null,
                          child: post.userProfilePic.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: ColorsManager.primary,
                                )
                              : null,
                        ),
                        horizontalSpace12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EmojiText(
                                text: post.username,
                                style: TextStylesManager.bold14,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat.yMMMd().add_jm().format(
                                  post.timestamp.toDate(),
                                ),
                                style: TextStylesManager.regular12.copyWith(
                                  color: ColorsManager.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (post.text?.isNotEmpty == true)
                  PopupMenuButton<String>(
                    splashRadius: 18,
                    color: ColorsManager.error,
                    onSelected: (value) {
                      if (value == 'copy') {
                        Clipboard.setData(ClipboardData(text: post.text!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              appTranslation().get('copy_to_clipboard'),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else if (value == 'edit') {
                        context.push<String>(
                          Routes.editPost,
                          arguments: post.postId,
                        );
                      } else if (value == 'delete') {
                        postCubit.deletePost(post.postId);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'copy',
                        child: Text(appTranslation().get('copy')),
                      ),
                      if (post.userId == userCubit.userModel?.uid) ...[
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(appTranslation().get('edit_post')),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(appTranslation().get('delete_post')),
                        ),
                      ],
                    ],
                    icon: const Icon(Icons.more_horiz, size: 20),
                  ),
              ],
            ),

            // ===== POST TEXT =====
            if (post.text?.isNotEmpty == true) ...[
              verticalSpace12,
              EmojiText(
                text: post.text!,
                style: TextStylesManager.regular16.copyWith(height: 1.5),
              ),
            ],

            // ===== POST MEDIA =====
            if (post.imageUrl != null) ...[
              verticalSpace12,
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: isVideo(post.imageUrl!)
                    ? PostVideoPlayer(videoUrl: post.imageUrl!)
                    : AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: ColorsManager.backgroundColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                            ),
                          ),
                          errorWidget: (_, _, _) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
              ),
            ],

            verticalSpace8,

            // ===== LIKE & COMMENT BUTTONS =====
            Row(
              children: [
                ActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                  count: post.likes.length,
                  onTap: () => postCubit.togglePostLike(
                    post: post,
                    userModel: userCubit.userModel!,
                  ),
                  onCountTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => LikesListSheet(post: post),
                    );
                  },
                ),
                horizontalSpace16,
                ActionButton(
                  icon: Icons.comment_outlined,
                  count: post.comments.length,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => CommentsSheet(initialPost: post),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
