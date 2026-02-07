import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/utils/constants/primary/conditional_builder.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/feuters/home/presentation/widgets/posts/full_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    userCubit.getUserData().then((value) {
      if (userCubit.userModel != null) {
        notificationCubit.getNotifications(userCubit.userModel!.uid!);
      }
    });

    if (postCubit.posts.isEmpty) {
      postCubit.getPosts();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostStates>(
      builder: (context, postState) {
        return BlocBuilder<UserCubit, UserStates>(
          builder: (context, userState) {
            final currentUser = userCubit.userModel;

            final visiblePosts = postCubit.posts.where((post) {
              if (!post.isPrivate) return true;
              if (currentUser == null) return false;
              if (post.userId == currentUser.uid) return true;

              return currentUser.following.contains(post.userId);
            }).toList();

            // Trigger rebuild if following list changes/updates
            if (currentUser != null) {
              // This is just to ensure the check happens with latest data
            }

            return Scaffold(
              body: Stack(
                children: [
                  ConditionalBuilder(
                    condition:
                        postState is PostGetPostsLoadingState &&
                        postCubit.posts.isEmpty,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                    fallback: (context) => PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: visiblePosts.length,
                      itemBuilder: (context, index) {
                        final post = visiblePosts[index];
                        return FullScreenPostCard(
                          key: ValueKey(post.postId),
                          post: post,
                        );
                      },
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        context.push(Routes.search);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
