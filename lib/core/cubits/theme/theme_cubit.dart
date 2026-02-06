import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/network/local/cache_helper.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeStates> {
  ThemeCubit({bool isDark = false})
    : _isDarkMode = isDark,
      super(ThemeInitialState());

  // ignore: strict_top_level_inference
  static ThemeCubit get(context) => BlocProvider.of(context);

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void changeTheme({bool? fromShared}) {
    _isDarkMode = fromShared ?? !_isDarkMode;
    CacheHelper.saveData(key: 'isDark', value: _isDarkMode);
    emit(ThemeChangeThemeState());
  }
}
