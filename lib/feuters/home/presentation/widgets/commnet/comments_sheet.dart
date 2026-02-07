import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/primary/emoji_picker_container.dart';
import 'package:skilltok/core/cubits/comment/comment_cubit.dart';
import 'package:skilltok/core/cubits/theme/theme_cubit.dart';
import 'package:skilltok/feuters/home/presentation/widgets/commnet/comment_input_bar.dart';
import 'package:skilltok/feuters/home/presentation/widgets/commnet/comment_list.dart';

class CommentsSheet extends StatefulWidget {
  final PostModel initialPost;
  final bool showHeader;

  const CommentsSheet({
    super.key,
    required this.initialPost,
    this.showHeader = true,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  bool isEmojiVisible = false;
  final FocusNode inputFocusNode = FocusNode();

  void toggleEmojiPicker() {
    setState(() => isEmojiVisible = !isEmojiVisible);
  }

  @override
  Widget build(BuildContext context) {
    final commentCubit = CommentCubit.get(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final themeCubit = ThemeCubit.get(context);
    final isDark = themeCubit.isDarkMode;

    return BlocListener<CommentCubit, CommentStates>(
      listener: (context, state) {
        if (state is CommentSetReplyState) {
          FocusScope.of(context).requestFocus(inputFocusNode);
        } else if (state is CommentDeleteCommentSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appTranslation().get('comment_deleted')),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CommentDeleteCommentErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          children: [
            if (widget.showHeader) ...[
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
                appTranslation().get('comments'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Divider(),
            ],

            Expanded(child: CommentList(initialPost: widget.initialPost)),

            Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                children: [
                  CommentInputBar(
                    isEmojiVisible: isEmojiVisible,
                    focusNode: inputFocusNode,
                    onEmojiToggle: toggleEmojiPicker,
                    post: widget.initialPost,
                  ),
                  EmojiPickerContainer(
                    isVisible: isEmojiVisible,
                    controller: commentCubit.commentController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
