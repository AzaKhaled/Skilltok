import 'package:flutter/material.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/core/cubits/theme/theme_cubit.dart';

class LikesListSheet extends StatelessWidget {
  final PostModel post;
  final bool isScreen;

  const LikesListSheet({super.key, required this.post, this.isScreen = false});

  @override
  Widget build(BuildContext context) {
    final postCubit = PostCubit.get(context);

    final themeCubit = ThemeCubit.get(context);
    final isDark = themeCubit.isDarkMode;

    // If it's a screen, we don't want the rounded top corners and white background might be handled by Scaffold.
    // However, if we want it white:
    return Container(
      decoration: isScreen
          ? null
          : BoxDecoration(
              color: isDark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
      constraints: isScreen
          ? null
          : BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
      child: Column(
        children: [
          if (!isScreen) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              appTranslation().get('likes'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const Divider(),
          ],
          Expanded(
            child: StreamBuilder<PostModel>(
              stream: postCubit.getPostStream(post.postId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final updatedPost = snapshot.data!;
                final userIds = updatedPost.likes;

                if (userIds.isEmpty) {
                  return Center(
                    child: Text(
                      appTranslation().get('no_likes'),
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: userIds.length,
                  itemBuilder: (context, index) {
                    return _UserTile(userId: userIds[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final String userId;

  const _UserTile({required this.userId});

  @override
  Widget build(BuildContext context) {
    final userCubit = UserCubit.get(context);
    final themeCubit = ThemeCubit.get(context);
    final isDark = themeCubit.isDarkMode;

    return StreamBuilder<UserModel?>(
      stream: userCubit.userRepo.getUserStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final user = snapshot.data!;
        final currentUser = userCubit.userModel;

        if (currentUser == null) return const SizedBox();

        final isMe = user.uid == currentUser.uid;
        final isFollowing = currentUser.following.contains(user.uid);

        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                ? NetworkImage(user.photoUrl!)
                : null,
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(
            user.username ?? '',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),

          trailing: isMe
              ? null
              : SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isFollowing) {
                        userCubit.unfollowUser(user.uid!);
                      } else {
                        userCubit.followUser(user.uid!);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing
                          ? (isDark ? Colors.grey[800] : Colors.grey[200])
                          : Colors.blue,
                      foregroundColor: isFollowing
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isFollowing
                          ? appTranslation().get('unfollow')
                          : appTranslation().get('follow'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),

          onTap: () {
            context.push<Object>(Routes.profile, arguments: user.uid);
          },
        );
      },
    );
  }
}
