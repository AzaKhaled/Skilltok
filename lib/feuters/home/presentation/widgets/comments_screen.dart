import 'package:flutter/material.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/feuters/home/presentation/widgets/commnet/comments_sheet.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  @override
  Widget build(BuildContext context) {
    final initialPost = context.getArg() as PostModel;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop,
        ),
        title: Text(appTranslation().get('comments')),
        centerTitle: true,
      ),
      body: CommentsSheet(initialPost: initialPost, showHeader: false),
    );
  }
}
