import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skilltok/core/models/comment_model.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/cubits/comment/comment_cubit.dart';
import 'package:skilltok/feuters/home/data/model/context_menu.dart';
import 'package:skilltok/feuters/home/presentation/widgets/commnet/ios_style_context_menu.dart';

class CommentContextMenu extends StatelessWidget {
  final bool isMe;
  final String postId;
  final CommentModel comment;
  final Widget child;

  const CommentContextMenu({
    super.key,
    required this.isMe,
    required this.postId,
    required this.comment,
    required this.child,
  });

  static Future<void> showMenu(
    BuildContext context, {
    required bool isMe,
    required String postId,
    required CommentModel comment,
    required Widget child,
  }) async {
    showDialog<Object>(
      context: context,
      builder: (_) => IosStyleContextMenu(
        menuAlignment: Alignment.centerRight,
        actions: [
          ContextMenuAndroid(
            icon: Icons.copy,
            label: appTranslation().get('copy'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: comment.text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appTranslation().get('copied')),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          if (isMe) ...[
            ContextMenuAndroid(
              icon: Icons.edit,
              label: appTranslation().get('edit'),
              onTap: () {
                Navigator.of(context).pop();
                final controller = TextEditingController(text: comment.text);
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(appTranslation().get('edit')),
                    content: TextFormField(
                      controller: controller,
                      maxLines: null,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(appTranslation().get('cancel')),
                      ),
                      TextButton(
                        onPressed: () async {
                          final newText = controller.text.trim();
                          if (newText.isEmpty) return;
                          try {
                            await CommentCubit.get(context).editComment(
                              postId: postId,
                              commentId: comment.commentId,
                              newText: newText,
                            );
                            if (!context.mounted) return;
                            Navigator.of(ctx).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(appTranslation().get('error')),
                              ),
                            );
                          }
                        },
                        child: Text(appTranslation().get('save')),
                      ),
                    ],
                  ),
                );
              },
            ),
            ContextMenuAndroid(
              icon: Icons.delete,
              label: appTranslation().get('delete'),
              onTap: () {
                CommentCubit.get(context).deleteComment(postId, comment);
              },
            ),
          ],
        ],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // no long press anymore. The three-dot button in the comment item opens this menu.
    return child;
  }
}
