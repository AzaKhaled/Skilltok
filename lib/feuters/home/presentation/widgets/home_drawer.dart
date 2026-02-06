import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/theme/emoji_text.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/assets_helper.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skilltok/feuters/home/presentation/widgets/home_drawer_tile.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserStates>(
      builder: (context, state) {
        final user = userCubit.userModel;
        return Drawer(
          child: Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey, Colors.black87],
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 34,
                          backgroundImage: user?.photoUrl != null
                              ? CachedNetworkImageProvider(user!.photoUrl!)
                              : const AssetImage(AssetsHelper.logo),
                        ),
                      ),
                      horizontalSpace12,
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EmojiText(
                              text: user?.username ?? 'skilltok User',
                              style: TextStylesManager.bold18.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            verticalSpace2,
                            EmojiText(
                              text: user?.bio ?? 'skilltok',
                              style: TextStylesManager.regular14.copyWith(
                                color: Colors.white.withValues(alpha: .8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpace6,
              HomeDrawerTile(
                title: appTranslation().get('home'),
                icon: Icons.home_outlined,
                onTap: () => context.pop,
              ),
              HomeDrawerTile(
                title: appTranslation().get('profile'),
                icon: Icons.person_outline,
                onTap: () {
                  context.push<Object>(Routes.profile);
                },
              ),
              HomeDrawerTile(
                title: appTranslation().get('settings'),
                icon: Icons.settings_outlined,
                onTap: () {
                  context.push<Object>(Routes.settings);
                },
              ),
              const Spacer(),
              Divider(
                indent: 24,
                endIndent: 24,
                color: Colors.grey.withValues(alpha: .3),
              ),
              HomeDrawerTile(
                title: appTranslation().get('logout'),
                icon: Icons.logout,
                onTap: () {
                  authCubit.logout(context);
                },
              ),
              verticalSpace12,
            ],
          ),
        );
      },
    );
  }
}
