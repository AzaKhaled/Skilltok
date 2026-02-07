import 'package:flutter/material.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';

class FollowListScreen extends StatelessWidget {
  const FollowListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = context.getArg<Map<String, dynamic>>()!;
    final userId = args['userId'] as String;
    final type = args['type'] as String; // followers | following
    final userCubit = UserCubit.get(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          type == 'followers'
              ? appTranslation().get('followers')
              : appTranslation().get('following'),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<UserModel?>(
        stream: userCubit.userRepo.getUserStream(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;
          final ids = type == 'followers' ? user.followers : user.following;

          if (ids.isEmpty) {
            return Center(child: Text(appTranslation().get('no_users')));
          }

          return ListView.builder(
            itemCount: ids.length,
            itemBuilder: (context, index) {
              return _UserTile(userId: ids[index]);
            },
          );
        },
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
          title: Text(user.username ?? ''),

          /// 👉 زرار Follow / Unfollow
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
                      backgroundColor: isFollowing ? Colors.grey : Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
