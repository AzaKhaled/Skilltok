part of 'comment_cubit.dart';

abstract class CommentStates {}

class CommentInitialState extends CommentStates {}

class CommentAddCommentLoadingState extends CommentStates {}

class CommentAddCommentSuccessState extends CommentStates {}

class CommentAddCommentErrorState extends CommentStates {
  final String error;
  CommentAddCommentErrorState(this.error);
}

class CommentDeleteCommentLoadingState extends CommentStates {}

class CommentDeleteCommentSuccessState extends CommentStates {}

class CommentDeleteCommentErrorState extends CommentStates {
  final String error;
  CommentDeleteCommentErrorState(this.error);
}

class CommentSetReplyState extends CommentStates {}

class CommentClearReplyState extends CommentStates {}

class CommentToggleReactionLoadingState extends CommentStates {}

class CommentToggleReactionSuccessState extends CommentStates {}

class CommentToggleReactionErrorState extends CommentStates {
  final String error;
  CommentToggleReactionErrorState(this.error);
}

class CommentAddedState extends CommentStates {
  final String? parentId;
  CommentAddedState(this.parentId);
}

class CommentEditLoadingState extends CommentStates {}

class CommentEditSuccessState extends CommentStates {}

class CommentEditErrorState extends CommentStates {
  final String error;
  CommentEditErrorState(this.error);
}
