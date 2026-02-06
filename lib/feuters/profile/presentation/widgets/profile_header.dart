import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/emoji_text.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/primary/image_preview_page.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';

import 'package:skilltok/feuters/profile/presentation/widgets/profile_action_button.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;
  final double profileRadius;
  final int postCount;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.profileRadius,
    required this.currentUser,
    required this.postCount,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = user.uid == currentUser.uid;
    final isFollowing = currentUser.following.contains(user.uid);
    final isFollowedBy = currentUser.followers.contains(user.uid);
    final isRequested = user.followRequests.contains(currentUser.uid);

    String buttonText;
    if (isFollowing) {
      buttonText = appTranslation().get('unfollow');
    } else if (isRequested) {
      buttonText = appTranslation().get('requested');
    } else if (isFollowedBy) {
      buttonText = appTranslation().get('follow_back');
    } else {
      buttonText = appTranslation().get('follow');
    }

    final isPrimaryAction =
        !isFollowing && !isRequested; // Follow or Follow Back

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute<Object>(
                  builder: (context) => ImagePreviewPage(url: user.photoUrl!),
                ),
              );
            }
          },
          child: CircleAvatar(
            radius: profileRadius + 4,
            backgroundColor: ColorsManager.backgroundColor,
            child: CircleAvatar(
              radius: profileRadius,
              backgroundImage:
                  (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                  ? CachedNetworkImageProvider(user.photoUrl!)
                  : null,
              child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 48)
                  : null,
            ),
          ),
        ),
        verticalSpace12,
        EmojiText(text: user.username ?? '', style: TextStylesManager.bold20),
        verticalSpace6,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: EmojiText(
            text: user.bio ?? '',
            textAlign: TextAlign.center,
            style: TextStylesManager.regular14.copyWith(
              color: ColorsManager.textSecondaryColor,
            ),
          ),
        ),
        verticalSpace12,
        if (isCurrentUser)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ProfileActionButton(
                text: appTranslation().get('edit_profile'),
                onPressed: () {
                  context.push<Object>(Routes.editProfile);
                },
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ProfileActionButton(
                    text: buttonText,
                    isPrimary: isPrimaryAction,
                    onPressed: () {
                      if (isFollowing) {
                        userCubit.unfollowUser(user.uid!);
                      } else if (isRequested) {
                        userCubit.cancelFollowRequest(user.uid!);
                      } else {
                        userCubit.followUser(user.uid!);
                      }
                    },
                  ),
                ),
                horizontalSpace8,
                Expanded(
                  child: ProfileActionButton(
                    text: appTranslation().get('message'),
                    onPressed: () {
                      context.push(Routes.chatDetails, arguments: user);
                    },
                  ),
                ),
              ],
            ),
          ),
        verticalSpace12,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn(
              appTranslation().get('posts'),
              postCount.toString(),
            ),
            _buildStatColumn(
              appTranslation().get('followers'),
              user.followers.length.toString(),
              onTap: () {
                context.push<Object>(
                  Routes.followList,
                  arguments: {'userId': user.uid, 'type': 'followers'},
                );
              },
            ),
            _buildStatColumn(
              appTranslation().get('following'),
              user.following.length.toString(),
              onTap: () {
                context.push<Object>(
                  Routes.followList,
                  arguments: {'userId': user.uid, 'type': 'following'},
                );
              },
            ),
          ],
        ),
        verticalSpace16,
      ],
    );
  }

  Widget _buildStatColumn(String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(value, style: TextStylesManager.bold16),
          verticalSpace4,
          Text(
            title,
            style: TextStylesManager.regular14.copyWith(
              color: ColorsManager.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
