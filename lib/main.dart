import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/di/injections.dart';
import 'package:skilltok/core/network/local/cache_helper.dart';
import 'package:skilltok/core/network/service/notification_handler.dart';
import 'package:skilltok/core/theme/theme.dart';
import 'package:skilltok/core/utils/constants/my_bloc_observer.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/bloc_providers.dart';
import 'package:skilltok/core/cubits/theme/theme_cubit.dart';
import 'package:skilltok/core/cubits/language/language_cubit.dart';
import 'package:skilltok/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjections();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationHandler.initFirebaseMessaging();
  FirebaseMessaging.onBackgroundMessage(NotificationHandler.messageHandler);
  Bloc.observer = MyBlocObserver();
  final bool isDark = CacheHelper.getData(key: 'isDark') ?? false;
  final bool isArabic = CacheHelper.getData(key: 'isArabicLang') ?? false;
  final String translation = await rootBundle.loadString(
    'assets/translations/${isArabic ? 'ar' : 'en'}.json',
  );
  runApp(MyApp(isDark: isDark, isArabic: isArabic, translation: translation));
}

class MyApp extends StatelessWidget {
  final bool isDark;
  final bool isArabic;
  final String translation;

  const MyApp({
    super.key,
    required this.isDark,
    required this.isArabic,
    required this.translation,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getProviders(
        isDark: isDark,
        isArabic: isArabic,
        translations: translation,
      ),
      child: BlocBuilder<ThemeCubit, ThemeStates>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, LanguageStates>(
            builder: (context, languageState) {
              final languageCubit = LanguageCubit.get(context);
              final themeCubit = ThemeCubit.get(context);

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                routes: Routes.routes,
                initialRoute: Routes.entry,
                navigatorObservers: [routeObserver],
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeCubit.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                builder: (context, child) {
                  return Directionality(
                    textDirection: languageCubit.isArabicLang
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
