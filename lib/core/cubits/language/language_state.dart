part of 'language_cubit.dart';

abstract class LanguageStates {}

class LanguageInitialState extends LanguageStates {}

class LanguageLoadingState extends LanguageStates {}

class LanguageUpdatedState extends LanguageStates {}

class LanguageErrorState extends LanguageStates {
  final String error;
  LanguageErrorState(this.error);
}

class LanguageLoadedState extends LanguageStates {}
