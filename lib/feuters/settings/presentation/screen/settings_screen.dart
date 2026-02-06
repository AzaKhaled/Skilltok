import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/network/local/cache_helper.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/cubits/theme/theme_cubit.dart';
import 'package:skilltok/core/cubits/language/language_cubit.dart';

import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/feuters/settings/presentation/widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeStates>(
      builder: (context, themeState) {
        return BlocBuilder<LanguageCubit, LanguageStates>(
          builder: (context, langState) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    context.pop;
                  },
                ),
                title: Text(appTranslation().get('settings')),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SettingsTile(
                      icon: themeCubit.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      title: appTranslation().get('app_theme'),
                      subtitle: themeCubit.isDarkMode
                          ? appTranslation().get('dark_mode')
                          : appTranslation().get('light_mode'),
                      trailing: Switch(
                        value: themeCubit.isDarkMode,
                        activeThumbColor: ColorsManager.neonGreen,
                        inactiveThumbColor: ColorsManager.primary,
                        onChanged: (_) => themeCubit.changeTheme(),
                      ),
                    ),
                    verticalSpace14,
                    SettingsTile(
                      icon: Icons.language,
                      title: appTranslation().get('language'),
                      subtitle: languageCubit.isArabicLang
                          ? 'العربية'
                          : 'English',
                      trailing: Switch(
                        value: languageCubit.isArabicLang,
                        activeThumbColor: ColorsManager.neonGreen,
                        inactiveThumbColor: ColorsManager.primary,
                        onChanged: (_) async {
                          final isArabic = !languageCubit.isArabicLang;
                          final jsonString = await rootBundle.loadString(
                            'assets/translations/${isArabic ? 'ar' : 'en'}.json',
                          );
                          languageCubit.changeLanguage(
                            isArabic: isArabic,
                            translations: jsonString,
                          );
                          CacheHelper.saveData(
                            key: 'isArabicLang',
                            value: isArabic,
                          );
                        },
                      ),
                    ),
                    verticalSpace14,
                    SettingsTile(
                      icon: Icons.logout,
                      title: appTranslation().get('logout'),
                      subtitle: appTranslation().get('logout'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        authCubit.logout(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
