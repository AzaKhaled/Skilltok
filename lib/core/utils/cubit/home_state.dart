import 'package:firebase_auth/firebase_auth.dart';
import 'package:skilltok/core/models/notification_model.dart';
import 'package:skilltok/core/models/post_model.dart';

abstract class HomeStates {}

class HomeInitialState extends HomeStates {}

class HomeChangeThemeState extends HomeStates {}

class HomeLanguageUpdatedState extends HomeStates {}

class HomeLanguageLoadingState extends HomeStates {}

class HomeLanguageLoadedState extends HomeStates {}

class HomeLanguageErrorState extends HomeStates {
  final String error;

  HomeLanguageErrorState(this.error);
}

class HomeShowPasswordUpdatedState extends HomeStates {}

//button nav
class ChangeBannerIndexState extends HomeStates {}

class ChangeBottomNavBarState extends HomeStates {}

class HomeSelectedIndexUpdatedState extends HomeStates {}

//login
class HomeLoginLoadingState extends HomeStates {}

class HomeLoginSuccessState extends HomeStates {
  final User? user;

  HomeLoginSuccessState(this.user);
}

class HomeLoginErrorState extends HomeStates {
  final String error;

  HomeLoginErrorState(this.error);
}

//register
class HomeProfileImagePickedState extends HomeStates {}

class HomeRegisterLoadingState extends HomeStates {}

class HomeRegisterSuccessState extends HomeStates {
  final User? user;

  HomeRegisterSuccessState(this.user);
}

class HomeRegisterErrorState extends HomeStates {
  final String error;

  HomeRegisterErrorState(this.error);
}

//getUserData
class HomeGetUserSuccessState extends HomeStates {}

class HomeGetUserErrorState extends HomeStates {
  final String error;

  HomeGetUserErrorState(this.error);
}

// Posts
class HomeGetPostsLoadingState extends HomeStates {}

class HomeGetPostsSuccessState extends HomeStates {
  final List<PostModel> posts;

  HomeGetPostsSuccessState(this.posts);
}

class HomeGetPostsErrorState extends HomeStates {
  final String error;

  HomeGetPostsErrorState(this.error);
}

class HomeAddPostLoadingState extends HomeStates {}

class HomeAddPostSuccessState extends HomeStates {}

class HomeAddPostErrorState extends HomeStates {
  final String error;

  HomeAddPostErrorState(this.error);
}

class HomeRemovepostVideoState extends HomeStates {}

class HomePickpostVideoState extends HomeStates {}

// Like Post
class HomeLikePostSuccessState extends HomeStates {}

class HomeLikePostErrorState extends HomeStates {
  final String error;

  HomeLikePostErrorState(this.error);
}
class HomePickPostVideoState  extends HomeStates {
}

class HomeRemovePostVideoState  extends HomeStates {
}
// Comments
class HomeAddCommentLoadingState extends HomeStates {}

class HomeAddCommentSuccessState extends HomeStates {}

class HomeAddCommentErrorState extends HomeStates {
  final String error;

  HomeAddCommentErrorState(this.error);
}

class HomeDeleteCommentLoadingState extends HomeStates {}

class HomeDeleteCommentSuccessState extends HomeStates {}

class HomeDeleteCommentErrorState extends HomeStates {
  final String error;

  HomeDeleteCommentErrorState(this.error);
}

//myPosts
class HomeGetMyPostsLoadingState extends HomeStates {}

class HomeGetMyPostsSuccessState extends HomeStates {
  final List<PostModel> posts;

  HomeGetMyPostsSuccessState(this.posts);
}

class HomeGetMyPostsErrorState extends HomeStates {
  final String error;

  HomeGetMyPostsErrorState(this.error);
}

// Edit Profile
class HomePickProfileImageState extends HomeStates {}

class HomePickCoverImageState extends HomeStates {}

class HomeUpdateProfileLoadingState extends HomeStates {}

class HomeUpdateProfileSuccessState extends HomeStates {}

class HomeUpdateProfileErrorState extends HomeStates {
  final String error;

  HomeUpdateProfileErrorState(this.error);
}

class HomeCoverImagePickedState extends HomeStates {}

// Edit Post
class HomeRemoveEditpostVideoState extends HomeStates {}

class HomeUpdatePostLoadingState extends HomeStates {}

class HomeUpdatePostSuccessState extends HomeStates {}

class HomeUpdatePostErrorState extends HomeStates {
  final String error;

  HomeUpdatePostErrorState(this.error);
}

// Follow
class HomeFollowUserLoadingState extends HomeStates {}

class HomeFollowUserSuccessState extends HomeStates {}

class HomeFollowUserErrorState extends HomeStates {
  final String error;

  HomeFollowUserErrorState(this.error);
}

class HomeUnfollowUserLoadingState extends HomeStates {}

class HomeUnfollowUserSuccessState extends HomeStates {}

class HomeUnfollowUserErrorState extends HomeStates {
  final String error;

  HomeUnfollowUserErrorState(this.error);
}

// Delete Post
class HomeDeletePostLoadingState extends HomeStates {}

class HomeDeletePostSuccessState extends HomeStates {}

class HomeDeletePostErrorState extends HomeStates {
  final String error;

  HomeDeletePostErrorState(this.error);
}

// Notifications
class HomeGetNotificationsLoadingState extends HomeStates {}

class HomeGetNotificationsSuccessState extends HomeStates {
  final List<NotificationModel> notifications;

  HomeGetNotificationsSuccessState(this.notifications);
}

class HomeGetNotificationsErrorState extends HomeStates {
  final String error;

  HomeGetNotificationsErrorState(this.error);
}

class HomeForgotPasswordLoadingState extends HomeStates {}

class HomeForgotPasswordSuccessState extends HomeStates {
  final String message;
  HomeForgotPasswordSuccessState(this.message);
}

class HomeForgotPasswordErrorState extends HomeStates {
  final String error;
  HomeForgotPasswordErrorState(this.error);
}
// ===================== CHAT STATES =====================

class ChatBackgroundChangedState extends HomeStates {}

class ChatSendSuccessState extends HomeStates {}

class ChatSendErrorState extends HomeStates {
  final String error;
  ChatSendErrorState(this.error);
}

class ChatUploadImageLoadingState extends HomeStates {}

class ChatUploadImageSuccessState extends HomeStates {
  final String imageUrl;
  ChatUploadImageSuccessState(this.imageUrl);
}

class ChatUploadImageErrorState extends HomeStates {
  final String error;
  ChatUploadImageErrorState(this.error);
}
class HomeHeartAnimationState extends HomeStates {
  final String videoUrl;
  HomeHeartAnimationState(this.videoUrl);
}
