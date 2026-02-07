import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/emoji_text.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/feuters/home/presentation/widgets/posts/scrollable_caption.dart';
import 'package:video_player/video_player.dart';
import 'package:skilltok/feuters/home/presentation/widgets/commnet/comments_sheet.dart';
import 'package:skilltok/feuters/home/presentation/widgets/posts/likes_list_sheet.dart';
import 'package:skilltok/main.dart';

class FullScreenPostCard extends StatefulWidget {
  final PostModel post;

  const FullScreenPostCard({super.key, required this.post});

  @override
  State<FullScreenPostCard> createState() => _FullScreenPostCardState();
}

class _FullScreenPostCardState extends State<FullScreenPostCard>
    with RouteAware {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.post.imageUrl!))
          ..setLooping(true)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
              _controller.play();
            }
          });

    _controller.play();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  void didPopNext() {
    if (!_controller.value.isPlaying) {
      _controller.play();
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userCubit = UserCubit.get(context);
    final postCubit = PostCubit.get(context);
    final isLiked = widget.post.likes.contains(userCubit.userModel?.uid);

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.isInitialized
                  ? _controller.value.size.width
                  : 16,
              height: _controller.value.isInitialized
                  ? _controller.value.size.height
                  : 9,
              child: _controller.value.isInitialized
                  ? VideoPlayer(_controller)
                  : Container(color: Colors.black),
            ),
          ),

          if (!_controller.value.isInitialized || _controller.value.isBuffering)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),

          if (!_controller.value.isPlaying &&
              _controller.value.isInitialized &&
              !_controller.value.isBuffering)
            Center(
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.blue,
                bufferedColor: Colors.white38,
                backgroundColor: Colors.white24,
              ),
            ),
          ),

          PositionedDirectional(
            start: 16,
            end: 96,

            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== USER (FIXED) =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.push(
                        Routes.profile,
                        arguments: widget.post.userId,
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: ColorsManager.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: widget.post.userProfilePic.isNotEmpty
                            ? CachedNetworkImageProvider(
                                widget.post.userProfilePic,
                              )
                            : null,
                        child: widget.post.userProfilePic.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: ColorsManager.primary,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: EmojiText(
                              text: widget.post.username,
                              style: TextStylesManager.bold16.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (widget.post.isPrivate) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.lock,
                              size: 14,
                              color: Colors.white70,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                ScrollableCaption(text: widget.post.text),
              ],
            ),
          ),

          // ================= ACTION BUTTONS =================
          PositionedDirectional(
            end: 12,
            bottom: 20,
            child: Column(
              children: [
                 CircleAvatar(
                        radius: 18,
                        backgroundColor: ColorsManager.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: widget.post.userProfilePic.isNotEmpty
                            ? CachedNetworkImageProvider(
                                widget.post.userProfilePic,
                              )
                            : null,
                        child: widget.post.userProfilePic.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: ColorsManager.primary,
                              )
                            : null,
                      ),
                    
                const SizedBox(height: 16),
                _IconButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: widget.post.likes.length.toString(),
                  color: isLiked ? Colors.red : Colors.white,
                  onTap: () => postCubit.togglePostLike(
                    post: widget.post,
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
                      builder: (context) => LikesListSheet(post: widget.post),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _IconButton(
                  icon: Icons.comment,
                  label: widget.post.comments.length.toString(),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) =>
                          CommentsSheet(initialPost: widget.post),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _IconButton(
                  icon:
                      (userCubit.userModel?.savedPosts.contains(
                            widget.post.postId,
                          ) ??
                          false)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  label: 'Save',
                  color:
                      (userCubit.userModel?.savedPosts.contains(
                            widget.post.postId,
                          ) ??
                          false)
                      ? Colors.red
                      : Colors.white,
                  onTap: () => userCubit.toggleSavePost(widget.post.postId),
                ),
                const SizedBox(height: 16),
                PopupMenuButton<String>(
                  color: ColorsManager.backgroundColor,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 32,
                  ),
                  onSelected: (value) {
                    if (value == 'copy') {
                      if (widget.post.text != null) {
                        Clipboard.setData(
                          ClipboardData(text: widget.post.text!),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              appTranslation().get('copy_to_clipboard'),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } else if (value == 'edit') {
                      context.push(
                        Routes.editPost,
                        arguments: widget.post.postId,
                      );
                    } else if (value == 'delete') {
                      postCubit.deletePost(widget.post.postId);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'copy',
                      child: Text(appTranslation().get('copy')),
                    ),
                    if (widget.post.userId == userCubit.userModel?.uid) ...[
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onCountTap;
  final Color? color;

  const _IconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onCountTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Icon(icon, size: 36, color: color ?? Colors.white),
        ),
        if (label.isNotEmpty) const SizedBox(height: 6),
        if (label.isNotEmpty)
          GestureDetector(
            onTap: onCountTap,
            child: Text(
              label,
              style: TextStylesManager.regular12.copyWith(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
