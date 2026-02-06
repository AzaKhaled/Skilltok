part of 'user_cubit.dart';

abstract class UserStates {}

class UserInitialState extends UserStates {}

class UserGetUserSuccessState extends UserStates {}

class UserGetUserErrorState extends UserStates {
  final String error;
  UserGetUserErrorState(this.error);
}

class UserFollowUserLoadingState extends UserStates {}

class UserFollowUserSuccessState extends UserStates {}

class UserFollowUserErrorState extends UserStates {
  final String error;
  UserFollowUserErrorState(this.error);
}

class UserUnfollowUserLoadingState extends UserStates {}

class UserUnfollowUserSuccessState extends UserStates {}

class UserUnfollowUserErrorState extends UserStates {
  final String error;
  UserUnfollowUserErrorState(this.error);
}

class UserSearchLoadingState extends UserStates {}

class UserSearchSuccessState extends UserStates {}

class UserSearchErrorState extends UserStates {
  final String error;
  UserSearchErrorState(this.error);
}
