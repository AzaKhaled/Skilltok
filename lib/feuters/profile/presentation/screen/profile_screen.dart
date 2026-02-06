import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/cubits/profile/profile_cubit.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/feuters/profile/presentation/widgets/profile_header.dart';
import 'package:skilltok/feuters/profile/presentation/widgets/profile_posts_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const double profileRadius = 52;
  UserModel? viewedUser;
  StreamSubscription<UserModel?>? _viewedUserSubscription;
  StreamSubscription<List<PostModel>>? _postsSubscription;

  int selectedTabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.getArg<String?>();

    // If viewing current user's profile, use local model and load their posts
    if (userId == null || userId == userCubit.userModel?.uid) {
      _viewedUserSubscription?.cancel();
      viewedUser = userCubit.userModel;
      if (viewedUser != null) {
        // Only fetch if posts are empty or belong to a different user
        // (This prevents reloading when navigating back/forth or rebuilding)
        final bool shouldFetch =
            profileCubit.userPosts.isEmpty ||
            (profileCubit.userPosts.isNotEmpty &&
                profileCubit.userPosts.first.userId != viewedUser!.uid);

        if (shouldFetch) {
          profileCubit.getMyPosts(viewedUser!.uid!);
        }
      }
    } else {
      // Use a real-time stream so followers/following counts update immediately
      _viewedUserSubscription?.cancel();
      _viewedUserSubscription = userCubit.userRepo.getUserStream(userId).listen(
        (user) {
          if (mounted) {
            setState(() {
              viewedUser = user;
            });
            if (user != null) {
              _postsSubscription?.cancel();
              _postsSubscription = profileCubit.postRepo
                  .getUserPosts(user.uid!)
                  .listen((posts) {
                    if (mounted) {
                      setState(() {
                        profileCubit.userPosts = posts;
                      });
                    }
                  });
            }
          }
        },
      );
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      selectedTabIndex = index;
    });
    if (index == 1) {
      if (userCubit.userModel != null) {
        profileCubit.getSavedPosts(userCubit.userModel!.savedPosts);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, profileState) {
        return BlocBuilder<UserCubit, UserStates>(
          builder: (context, userState) {
            final currentUser = userCubit.userModel;

            if (viewedUser == null || currentUser == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isMe = viewedUser!.uid == currentUser.uid;

            var displayPosts = (isMe && selectedTabIndex == 1)
                ? profileCubit.savedPosts
                : profileCubit.userPosts;

            // Filter private posts if viewing someone else's profile
            if (!isMe) {
              displayPosts = displayPosts.where((p) {
                if (!p.isPrivate) return true;
                return currentUser.following.contains(p.userId);
              }).toList();
            }

            final posts = displayPosts;

            return Scaffold(
              appBar: AppBar(
                leading: !isMe
                    ? IconButton(
                        onPressed: () => context.pop,
                        icon: const Icon(Icons.arrow_back_ios_new),
                      )
                    : null,
                title: Text(appTranslation().get('profile')),
                centerTitle: true,
                actions: [
                  if (isMe && currentUser.followRequests.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                      ), // Adjust padding if needed
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            onPressed: () {
                              context.push(Routes.followRequests);
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8, right: 8),
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              currentUser.followRequests.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isMe)
                    IconButton(
                      onPressed: () => context.push(Routes.settings),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                ],
              ),

              backgroundColor: ColorsManager.backgroundColor,

              body: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileHeader(
                      user: viewedUser!,
                      profileRadius: profileRadius,
                      currentUser: currentUser,
                      postCount:
                          (!isMe &&
                              !currentUser.following.contains(viewedUser!.uid))
                          ? profileCubit.userPosts
                                .where((p) => !p.isPrivate)
                                .length
                          : profileCubit.userPosts.length,
                    ),

                    if (isMe) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _onTabChanged(0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: selectedTabIndex == 0
                                      ? const Border(
                                          bottom: BorderSide(
                                            color: ColorsManager.primary,
                                            width: 2,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Icon(
                                    Icons.grid_on,
                                    color: selectedTabIndex == 0
                                        ? ColorsManager.primary
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => _onTabChanged(1),
                              child: Container(
                                // padding: const EdgeInsets.symmetric(
                                //   vertical: 12,
                                // ),
                                decoration: BoxDecoration(
                                  border: selectedTabIndex == 1
                                      ? const Border(
                                          bottom: BorderSide(
                                            color: ColorsManager.primary,
                                            width: 2,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Icon(
                                    Icons.bookmark_outline,
                                    color: selectedTabIndex == 1
                                        ? ColorsManager.primary
                                        : Colors.grey,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ProfilePostsSection(posts: posts),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _viewedUserSubscription?.cancel();
    _postsSubscription?.cancel();
    super.dispose();
  }
}
