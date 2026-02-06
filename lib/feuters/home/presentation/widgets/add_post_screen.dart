import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/primary/emoji_picker_container.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/feuters/home/presentation/widgets/add_post/add_post_actions.dart';
import 'package:skilltok/feuters/home/presentation/widgets/add_post/add_post_app_bar.dart';
import 'package:skilltok/feuters/home/presentation/widgets/add_post/add_post_buttom.dart';
import 'package:skilltok/feuters/home/presentation/widgets/add_post/post_image_preview.dart';
import 'package:skilltok/feuters/home/presentation/widgets/add_post/post_text_field.dart';

import 'package:skilltok/feuters/home/presentation/widgets/add_post/add_post_actions.dart';
import 'package:skilltok/feuters/home/presentation/widgets/add_post/add_post_app_bar.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool isEmojiVisible = false;
  final FocusNode inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Clear previous state when entering the screen
    postCubit.removePostVideo();
    postCubit.postTextController.clear();
    postCubit.isPrivate = false; // Reset privacy too if needed
  }

  void toggleEmojiPicker() {
    setState(() => isEmojiVisible = !isEmojiVisible);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostStates>(
      buildWhen: (previous, current) =>
          current is PostAddPostLoadingState ||
          current is PostAddPostSuccessState ||
          current is PostAddPostErrorState ||
          current is PostPickPostVideoState ||
          current is PostRemovePostVideoState ||
          current is PostPrivacyChangedState,
      listener: (context, state) {
        if (state is PostAddPostSuccessState) {
          bottomNavCubit.currentIndex = 0;
        } else if (state is PostAddPostErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const AddPostAppBar(),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (state is PostAddPostLoadingState) ...[
                        const LinearProgressIndicator(),
                        verticalSpace12,
                      ],
                      const PostVideoPreview(),
                      verticalSpace16,
                      const PostTextField(),
                      verticalSpace16,
                      SwitchListTile(
                        title: Text(
                          appTranslation().get('private_post'),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          appTranslation().get('only_followers_can_see_this'),
                        ),
                        value: postCubit.isPrivate,
                        onChanged: (value) => postCubit.togglePrivacy(value),
                        activeThumbColor: ColorsManager.primary,
                      ),
                      verticalSpace16,
                      AddPostButtom(),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              AddPostActions(
                isEmojiVisible: isEmojiVisible,
                focusNode: inputFocusNode,
                onEmojiToggle: toggleEmojiPicker,
              ),
              EmojiPickerContainer(
                isVisible: isEmojiVisible,
                controller: postCubit.postTextController,
              ),
            ],
          ),
        );
      },
    );
  }
}
