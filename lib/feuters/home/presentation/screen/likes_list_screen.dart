import 'package:flutter/material.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/feuters/home/presentation/widgets/posts/likes_list_sheet.dart';

class LikesListScreen extends StatelessWidget {
  const LikesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final post = context.getArg<PostModel>()!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(appTranslation().get('likes')),
        centerTitle: true,
      ),
      body: LikesListSheet(post: post, isScreen: true),
    );
  }
}
