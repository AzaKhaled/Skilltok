import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/primary/emoji_picker_container.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({super.key});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  bool isEmojiVisible = false;

  void toggleEmojiPicker() {
    setState(() => isEmojiVisible = !isEmojiVisible);
  }

  final FocusNode inputFocusNode = FocusNode();

  late String arg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      arg = context.getArg() as String;
      final postCubit = PostCubit.get(context);
      postCubit.initEditPost(
        postCubit.posts.firstWhere((p) => p.postId == arg),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostStates>(
      buildWhen: (previous, current) =>
          current is PostUpdatePostLoadingState ||
          current is PostUpdatePostSuccessState ||
          current is PostUpdatePostErrorState ||
          current is PostRemoveEditpostVideoState,
      listener: (context, state) {
        if (state is PostUpdatePostSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appTranslation().get('post_updated')),
              duration: const Duration(seconds: 2),
              backgroundColor: ColorsManager.success,
            ),
          );
          context.pop;
        }
        if (state is PostUpdatePostErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: ColorsManager.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final postCubit = PostCubit.get(context);
        if (state is PostUpdatePostLoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop,
              icon: const Icon(Icons.arrow_back_ios),
            ),
            title: Text(appTranslation().get('edit_post')),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () {
                  postCubit.updatePost(postId: arg);
                },
                child: Text(
                  appTranslation().get('save'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.primary,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (state is PostUpdatePostLoadingState) ...[
                        const LinearProgressIndicator(),
                        verticalSpace12,
                      ],
                      TextFormField(
                        controller: postCubit.editPostController,
                        focusNode: inputFocusNode,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),
                      if (postCubit.editpostVideo != null ||
                          postCubit.editpostVideoUrl != null)
                        Stack(
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * .25,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: DecorationImage(
                                  image: postCubit.editpostVideo != null
                                      ? FileImage(postCubit.editpostVideo!)
                                      : NetworkImage(
                                              postCubit.editpostVideoUrl!,
                                            )
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                postCubit.removeEditpostVideo();
                              },
                              icon: const CircleAvatar(
                                radius: 20,
                                backgroundColor: ColorsManager.primary,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: () => postCubit.pickPostVideo(),
                      color: ColorsManager.primary,
                    ),
                    IconButton(
                      icon: Icon(
                        isEmojiVisible
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                      ),
                      onPressed: () {
                        toggleEmojiPicker();
                        if (isEmojiVisible) {
                          inputFocusNode.unfocus();
                        } else {
                          FocusScope.of(context).requestFocus(inputFocusNode);
                        }
                      },
                      color: ColorsManager.primary,
                    ),
                  ],
                ),
              ),
              EmojiPickerContainer(
                isVisible: isEmojiVisible,
                controller: postCubit.editPostController,
              ),
            ],
          ),
        );
      },
    );
  }
}
