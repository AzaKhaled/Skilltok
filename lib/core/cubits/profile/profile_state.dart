part of 'profile_cubit.dart';

abstract class ProfileStates {}

class ProfileInitialState extends ProfileStates {}

class ProfileGetMyPostsLoadingState extends ProfileStates {}

class ProfileGetMyPostsSuccessState extends ProfileStates {
  final List<PostModel> posts;
  ProfileGetMyPostsSuccessState(this.posts);
}

class ProfileGetMyPostsErrorState extends ProfileStates {
  final String error;
  ProfileGetMyPostsErrorState(this.error);
}

class ProfileGetSavedPostsLoadingState extends ProfileStates {}

class ProfileGetSavedPostsSuccessState extends ProfileStates {
  final List<PostModel> posts;
  ProfileGetSavedPostsSuccessState(this.posts);
}

class ProfileGetSavedPostsErrorState extends ProfileStates {
  final String error;
  ProfileGetSavedPostsErrorState(this.error);
}

class ProfileProfileImagePickedState extends ProfileStates {}

class ProfileCoverImagePickedState extends ProfileStates {}

class ProfileUpdateProfileLoadingState extends ProfileStates {}

class ProfileUpdateProfileSuccessState extends ProfileStates {
  final UserModel updatedUser;
  ProfileUpdateProfileSuccessState(this.updatedUser);
}

class ProfileUpdateProfileErrorState extends ProfileStates {
  final String error;
  ProfileUpdateProfileErrorState(this.error);
}
