import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/feuters/home/presentation/widgets/posts/full_screen.dart';
import 'package:skilltok/feuters/home/presentation/widgets/posts/post_card.dart';

class ProfilePostsSection extends StatelessWidget {
  final List<PostModel> posts;

  const ProfilePostsSection({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /*
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              appTranslation().get('posts'),
              style: TextStylesManager.bold18,
            ),
          ),
        ),
        verticalSpace8,
        */
        if (posts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              appTranslation().get('no_posts_yet'),
              style: TextStylesManager.regular16.copyWith(
                color: ColorsManager.textSecondaryColor,
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 أعمدة زي TikTok
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 9 / 16, // شكل الفيديو
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfilePostsViewer(posts: posts, initialIndex: index),
                    ),
                  );
                },

                child: _PostThumbnail(post: post),
              );
            },
          ),
      ],
    );
  }
}

class _PostThumbnail extends StatelessWidget {
  final PostModel post;

  const _PostThumbnail({required this.post});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (post.imageUrl != null && !isVideo(post.imageUrl!))
            CachedNetworkImage(
              imageUrl: post.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  Container(color: ColorsManager.backgroundColor),
              errorWidget: (_, _, _) => Container(
                color: ColorsManager.backgroundColor,
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            )
          else
            Container(color: Colors.black),

          // أيقونة فيديو
          if (post.imageUrl != null && isVideo(post.imageUrl!))
            const Positioned(
              right: 6,
              bottom: 6,
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}

class ProfilePostsViewer extends StatefulWidget {
  final List<PostModel> posts;
  final int initialIndex;

  const ProfilePostsViewer({
    super.key,
    required this.posts,
    required this.initialIndex,
  });

  @override
  State<ProfilePostsViewer> createState() => _ProfilePostsViewerState();
}

class _ProfilePostsViewerState extends State<ProfilePostsViewer> {
  late PageController _controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _controller,
        itemCount: widget.posts.length,
        onPageChanged: (index) {
          setState(() => currentIndex = index);
        },
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          return FullScreenPostCard(post: post);
        },
      ),
    );
  }
}
