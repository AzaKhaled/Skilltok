import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/emoji_text.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserCubit.get(context).userModel;

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundImage: user?.photoUrl != null
              ? CachedNetworkImageProvider(user!.photoUrl!)
              : null,
          child: user?.photoUrl == null ? const Icon(Icons.person) : null,
        ),
        horizontalSpace16,
        Expanded(
          child: EmojiText(
            text: user?.username ?? 'Loading...',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
