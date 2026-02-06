import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/cubits/theme/theme_cubit.dart';
import 'package:skilltok/core/cubits/language/language_cubit.dart';
import 'package:skilltok/core/cubits/bottom_nav/bottom_nav_cubit.dart';
import 'package:skilltok/core/cubits/auth/auth_cubit.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';
import 'package:skilltok/core/cubits/comment/comment_cubit.dart';
import 'package:skilltok/core/cubits/profile/profile_cubit.dart';
import 'package:skilltok/core/cubits/notification/notification_cubit.dart';
import 'package:skilltok/core/cubits/video/video_cubit.dart';
import 'package:skilltok/core/cubits/chat/chat_cubit.dart';

import 'dart:convert';
import 'package:skilltok/core/utils/constants/translations.dart';

List<BlocProvider> getProviders({
  required bool isDark,
  required bool isArabic,
  required String translations,
}) {
  final translationModel = TranslationModel.fromJson(json.decode(translations));
  return [
    BlocProvider<ThemeCubit>(create: (context) => ThemeCubit(isDark: isDark)),
    BlocProvider<LanguageCubit>(
      create: (context) =>
          LanguageCubit(isArabic: isArabic, translationModel: translationModel),
    ),
    BlocProvider<BottomNavCubit>(create: (context) => BottomNavCubit()),
    BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
    BlocProvider<UserCubit>(create: (context) => UserCubit()),
    BlocProvider<PostCubit>(create: (context) => PostCubit()..getPosts()),
    BlocProvider<CommentCubit>(create: (context) => CommentCubit()),
    BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
    BlocProvider<NotificationCubit>(create: (context) => NotificationCubit()),
    BlocProvider<VideoCubit>(create: (context) => VideoCubit()),
    BlocProvider<ChatCubit>(create: (context) => ChatCubit()),
  ];
}
