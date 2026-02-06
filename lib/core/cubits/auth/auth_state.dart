
part of 'auth_cubit.dart';

abstract class AuthStates {}

class AuthInitialState extends AuthStates {}

class AuthLoginLoadingState extends AuthStates {}

class AuthLoginSuccessState extends AuthStates {
  final User user;
  AuthLoginSuccessState(this.user);
}

class AuthLoginErrorState extends AuthStates {
  final String error;
  AuthLoginErrorState(this.error);
}

class AuthShowPasswordUpdatedState extends AuthStates {}

class AuthForgotPasswordLoadingState extends AuthStates {}

class AuthForgotPasswordSuccessState extends AuthStates {
  final String message;
  AuthForgotPasswordSuccessState(this.message);
}

class AuthForgotPasswordErrorState extends AuthStates {
  final String error;
  AuthForgotPasswordErrorState(this.error);
}

class AuthRegisterLoadingState extends AuthStates {}

class AuthRegisterSuccessState extends AuthStates {
  final User user;
  AuthRegisterSuccessState(this.user);
}

class AuthRegisterErrorState extends AuthStates {
  final String error;
  AuthRegisterErrorState(this.error);
}

class AuthProfileImagePickedState extends AuthStates {}
