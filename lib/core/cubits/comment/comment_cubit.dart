import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/models/comment_model.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/network/post_repository.dart';
import 'package:skilltok/core/network/notification_repository.dart';
import 'package:skilltok/core/network/service/notification_service.dart';

part 'comment_state.dart';

class CommentCubit extends Cubit<CommentStates> {
  CommentCubit() : super(CommentInitialState());

  // ignore: strict_top_level_inference
  static CommentCubit get(context) => BlocProvider.of(context);

  final PostRepository postRepo = PostRepository();
  final NotificationRepository notificationRepo = NotificationRepository();

  final commentController = TextEditingController();

  String? replyToCommentId;
  String? replyToUsername;
  String? replyToUserId;

  void setReplyTarget({
    required String commentId,
    required String username,
    required String userId,
  }) {
    replyToCommentId = commentId;
    replyToUsername = username;
    replyToUserId = userId;
    emit(CommentSetReplyState());
  }

  void clearReplyTarget() {
    replyToCommentId = null;
    replyToUsername = null;
    replyToUserId = null;
    emit(CommentClearReplyState());
  }

  Future<void> addComment({
    required String postId,
    required String postOwnerId,
    required UserModel userModel,
    required String text,
    String? parentCommentId,
    String? replyToUsername,
    String? replyToUserId,
  }) async {
    emit(CommentAddCommentLoadingState());
    try {
      final parent = parentCommentId ?? this.replyToCommentId;
      final rUsername = replyToUsername ?? this.replyToUsername;
      final rUserId = replyToUserId ?? this.replyToUserId;

      await postRepo.addComment(
        postId: postId,
        userId: userModel.uid!,
        username: userModel.username!,
        userProfilePic: userModel.photoUrl!,
        text: text,
        parentCommentId: parent,
        replyToUsername: rUsername,
      );

      // 1. Notify Post Owner
      if (postOwnerId != userModel.uid) {
        await NotificationService.send(
          receiverId: postOwnerId,
          title: userModel.username!,
          contents: {
            "en": "commented on your post 💬",
            "ar": "علّق على منشورك 💬",
          },
          data: {
            "type": "comment",
            "postId": postId,
            "senderId": userModel.uid!,
          },
        );
        await notificationRepo.sendNotification(
          senderId: userModel.uid!,
          senderName: userModel.username!,
          senderProfilePic: userModel.photoUrl!,
          receiverId: postOwnerId,
          type: 'comment',
          postId: postId,
          text: 'commented on your post: $text',
        );
      }

      // 2. Notify Reply Target (if different from Post Owner and Me)
      if (rUserId != null &&
          rUserId != userModel.uid &&
          rUserId != postOwnerId) {
        await NotificationService.send(
          receiverId: rUserId,
          title: userModel.username!,
          contents: {
            "en": "replied to your comment 💬",
            "ar": "رد على تعليقك 💬",
          },
          data: {
            "type": "comment",
            "postId": postId,
            "senderId": userModel.uid!,
          },
        );
        await notificationRepo.sendNotification(
          senderId: userModel.uid!,
          senderName: userModel.username!,
          senderProfilePic: userModel.photoUrl!,
          receiverId: rUserId,
          type: 'comment',
          postId: postId,
          text: 'replied to your comment: $text',
        );
      }
      // keep parent in variable, emit state to request expansion
      emit(CommentAddCommentSuccessState());
      emit(CommentAddedState(parent));
      clearReplyTarget();
    } catch (e) {
      emit(CommentAddCommentErrorState(e.toString()));
    }
  }

  Future<void> submitComment({
    required String postId,
    required String postOwnerId,
    required UserModel userModel,
  }) async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    // Capture state BEFORE clearing
    final currentReplyId = replyToCommentId;
    final currentReplyUsername = replyToUsername;
    final currentReplyUserId = replyToUserId;

    // Clear immediately to give instant feedback and prevent double taps
    commentController.clear();
    // clear reply target immediately to show feedback
    clearReplyTarget();

    await addComment(
      postId: postId,
      postOwnerId: postOwnerId,
      userModel: userModel,
      text: text,
      parentCommentId: currentReplyId,
      replyToUsername: currentReplyUsername,
      replyToUserId: currentReplyUserId,
    );
  }

  Future<void> deleteComment(String postId, CommentModel comment) async {
    emit(CommentDeleteCommentLoadingState());
    try {
      await postRepo.deleteComment(postId: postId, comment: comment);
      emit(CommentDeleteCommentSuccessState());
    } catch (e) {
      emit(CommentDeleteCommentErrorState(e.toString()));
    }
  }

  Future<void> toggleCommentReaction({
    required String postId,
    required String commentId,
    required String currentUserId,
    required String commentOwnerId,
    required UserModel userModel,
    required bool isLiked,
  }) async {
    emit(CommentToggleReactionLoadingState());
    try {
      await postRepo.toggleCommentReaction(
        postId: postId,
        commentId: commentId,
        currentUserId: currentUserId,
      );

      // Notify if we are LIKING (not unliking) and not liking our own comment
      if (!isLiked && commentOwnerId != currentUserId) {
        await NotificationService.send(
          receiverId: commentOwnerId,
          title: userModel.username!,
          contents: {"en": "liked your comment ❤️", "ar": "أعجب بتعليقك ❤️"},
          data: {"type": "like", "postId": postId, "senderId": userModel.uid!},
        );
        await notificationRepo.sendNotification(
          senderId: userModel.uid!,
          senderName: userModel.username!,
          senderProfilePic: userModel.photoUrl!,
          receiverId: commentOwnerId,
          type: 'like',
          postId: postId,
          text: 'liked your comment',
        );
      }

      emit(CommentToggleReactionSuccessState());
    } catch (e) {
      emit(CommentToggleReactionErrorState(e.toString()));
    }
  }

  Future<void> editComment({
    required String postId,
    required String commentId,
    required String newText,
  }) async {
    emit(CommentEditLoadingState());
    try {
      await postRepo.updateComment(
        postId: postId,
        commentId: commentId,
        newText: newText,
      );
      emit(CommentEditSuccessState());
    } catch (e) {
      emit(CommentEditErrorState(e.toString()));
    }
  }
}
