import 'package:flutter/material.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/models/comment_model.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';
import 'package:skilltok/feuters/home/presentation/widgets/commnet/comment_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/cubits/comment/comment_cubit.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class CommentList extends StatelessWidget {
  final PostModel initialPost;

  const CommentList({super.key, required this.initialPost});

  @override
  Widget build(BuildContext context) {
    final postCubit = PostCubit.get(context);
    return StreamBuilder<PostModel>(
      stream: postCubit.getPostStream(initialPost.postId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final post = snapshot.data!;
          // Build nested comment list
          final comments = post.comments;

          // map parentId -> List<CommentModel>
          final Map<String?, List<CommentModel>> children = {};
          for (final c in comments) {
            children.putIfAbsent(c.parentId, () => []);
            children[c.parentId]!.add(c);
          }

          // Build hierarchical widget tree with collapsible replies
          Widget buildNode(CommentModel item, int indent) {
            final directChildren = children[item.commentId] ?? [];
            return CommentWithReplies(
              postId: post.postId,
              comment: item,
              children: directChildren,
              childrenMap: children,
              indent: indent,
            );
          }

          final roots = children[null] ?? [];

          return ListView(children: roots.map((r) => buildNode(r, 0)).toList());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class CommentWithReplies extends StatefulWidget {
  final String postId;
  final CommentModel comment;
  final List<CommentModel> children;
  final Map<String?, List<CommentModel>> childrenMap;
  final int indent;

  const CommentWithReplies({
    super.key,
    required this.postId,
    required this.comment,
    required this.children,
    required this.childrenMap,
    required this.indent,
  });

  @override
  State<CommentWithReplies> createState() => _CommentWithRepliesState();
}

class _CommentWithRepliesState extends State<CommentWithReplies> {
  bool isExpanded = false;
  final GlobalKey _itemKey = GlobalKey();

  List<CommentModel> _getAllDescendants(String parentId) {
    final List<CommentModel> result = [];
    final immediate = widget.childrenMap[parentId] ?? [];
    for (var child in immediate) {
      result.add(child);
      result.addAll(_getAllDescendants(child.commentId));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final allDescendants = _getAllDescendants(widget.comment.commentId);

    return BlocListener<CommentCubit, CommentStates>(
      listener: (context, state) {
        if (state is CommentAddedState) {
          final isReplyToMe = state.parentId == widget.comment.commentId;
          final isReplyToDescendant =
              state.parentId != null &&
              allDescendants.any((c) => c.commentId == state.parentId);

          if (isReplyToMe || isReplyToDescendant) {
            setState(() => isExpanded = true);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final ctx = _itemKey.currentContext;
              if (ctx != null) {
                Scrollable.ensureVisible(
                  ctx,
                  duration: const Duration(milliseconds: 300),
                  alignment: 0.05,
                );
              }
            });
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: _itemKey,
            child: CommentItem(
              postId: widget.postId,
              comment: widget.comment,
              indentLevel: widget.indent,
            ),
          ),
          if (allDescendants.isNotEmpty && !isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 44.0, top: 4, bottom: 4),
              child: GestureDetector(
                onTap: () => setState(() => isExpanded = true),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 1,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'View ${allDescendants.length} replies',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isExpanded)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...allDescendants.map(
                  (c) => CommentItem(
                    postId: widget.postId,
                    comment: c,
                    indentLevel: 1, // All replies flattened to level 1
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 44.0, top: 4, bottom: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => isExpanded = false),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Hide replies',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
