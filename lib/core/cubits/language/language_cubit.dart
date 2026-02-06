import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/utils/constants/translations.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageStates> {
  LanguageCubit({bool isArabic = false, TranslationModel? translationModel})
    : _isArabicLang = isArabic,
      _translationModel = translationModel,
      super(LanguageLoadedState());

  // ignore: strict_top_level_inference
  static LanguageCubit get(context) => BlocProvider.of(context);

  bool _isArabicLang = false;
  TranslationModel? _translationModel;

  bool get isArabicLang => _isArabicLang;

  TranslationModel? get translationModel => _translationModel;

  Future<void> changeLanguage({
    required bool isArabic,
    required String translations,
  }) async {
    try {
      if (_isArabicLang == isArabic && _translationModel != null) {
        emit(LanguageUpdatedState());
        return;
      }
      emit(LanguageLoadingState());
      final model = TranslationModel.fromJson(json.decode(translations));
      _isArabicLang = isArabic;
      _translationModel = model;
      emit(LanguageUpdatedState());
    } catch (e) {
      emit(LanguageErrorState(e.toString()));
    }
  }

  Future<void> initializeLanguage({
    required bool isArabic,
    required String translations,
  }) async {
    try {
      _isArabicLang = isArabic;
      _translationModel = TranslationModel.fromJson(json.decode(translations));
      emit(LanguageLoadedState());
    } catch (e) {
      emit(LanguageErrorState(e.toString()));
    }
  }
}
