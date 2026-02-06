import 'package:skilltok/core/utils/constants/translations.dart';
import 'package:skilltok/core/cubits/language/language_cubit.dart';
import 'package:skilltok/core/cubits/auth/auth_cubit.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';
import 'package:skilltok/core/cubits/bottom_nav/bottom_nav_cubit.dart';
import 'package:skilltok/core/cubits/notification/notification_cubit.dart';
import 'package:skilltok/core/cubits/theme/theme_cubit.dart';
import 'package:skilltok/core/cubits/profile/profile_cubit.dart';
import 'package:skilltok/core/cubits/comment/comment_cubit.dart';
import 'package:skilltok/core/cubits/video/video_cubit.dart';
import 'package:skilltok/main.dart';
import 'package:skilltok/core/cubits/chat/chat_cubit.dart';

TranslationModel appTranslation() =>
    LanguageCubit.get(navigatorKey.currentContext!).translationModel ??
    TranslationModel.fromJson({});

AuthCubit get authCubit => AuthCubit.get(navigatorKey.currentContext!);
UserCubit get userCubit => UserCubit.get(navigatorKey.currentContext!);
PostCubit get postCubit => PostCubit.get(navigatorKey.currentContext!);
BottomNavCubit get bottomNavCubit =>
    BottomNavCubit.get(navigatorKey.currentContext!);
NotificationCubit get notificationCubit =>
    NotificationCubit.get(navigatorKey.currentContext!);
ThemeCubit get themeCubit => ThemeCubit.get(navigatorKey.currentContext!);
ProfileCubit get profileCubit => ProfileCubit.get(navigatorKey.currentContext!);
CommentCubit get commentCubit => CommentCubit.get(navigatorKey.currentContext!);
VideoCubit get videoCubit => VideoCubit.get(navigatorKey.currentContext!);
LanguageCubit get languageCubit =>
    LanguageCubit.get(navigatorKey.currentContext!);
ChatCubit get chatCubit => ChatCubit.get(navigatorKey.currentContext!);
