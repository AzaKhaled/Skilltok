part of 'post_cubit.dart';

abstract class PostStates {}

class PostInitialState extends PostStates {}

class PostGetPostsLoadingState extends PostStates {}

class PostGetPostsSuccessState extends PostStates {
  final List<PostModel> posts;
  PostGetPostsSuccessState(this.posts);
}

class PostGetPostsErrorState extends PostStates {
  final String error;
  PostGetPostsErrorState(this.error);
}

class PostAddPostLoadingState extends PostStates {}

class PostAddPostSuccessState extends PostStates {}

class PostAddPostErrorState extends PostStates {
  final String error;
  PostAddPostErrorState(this.error);
}

class PostRemovePostVideoState extends PostStates {}

class PostPickPostVideoState extends PostStates {}

class PostLikePostSuccessState extends PostStates {}

class PostLikePostErrorState extends PostStates {
  final String error;
  PostLikePostErrorState(this.error);
}

class PostDeletePostLoadingState extends PostStates {}

class PostDeletePostSuccessState extends PostStates {}

class PostDeletePostErrorState extends PostStates {
  final String error;
  PostDeletePostErrorState(this.error);
}

class PostUpdatePostLoadingState extends PostStates {}

class PostUpdatePostSuccessState extends PostStates {}

class PostUpdatePostErrorState extends PostStates {
  final String error;
  PostUpdatePostErrorState(this.error);
}

class PostRemoveEditpostVideoState extends PostStates {}

class PostPrivacyChangedState extends PostStates {
  final bool isPrivate;
  PostPrivacyChangedState(this.isPrivate);
}
