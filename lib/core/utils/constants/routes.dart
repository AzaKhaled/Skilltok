import 'package:flutter/material.dart';
import 'package:skilltok/feuters/entry/presentation/screen/entry_screen.dart';
import 'package:skilltok/feuters/folowers/presentation/screen/folowers_screen.dart';
import 'package:skilltok/feuters/home/presentation/screen/buttom_nav.dart';
import 'package:skilltok/feuters/home/presentation/screen/home_screen.dart';
import 'package:skilltok/feuters/home/presentation/widgets/add_post_screen.dart';
import 'package:skilltok/feuters/home/presentation/widgets/comments_screen.dart';
import 'package:skilltok/feuters/home/presentation/widgets/edit_post_screen.dart';
import 'package:skilltok/feuters/home/presentation/widgets/notifications/notifications_screen.dart';
import 'package:skilltok/feuters/login/presentation/screen/login_screen.dart';
import 'package:skilltok/feuters/login/presentation/widgets/forgeted_password.dart';
import 'package:skilltok/feuters/profile/presentation/screen/profile_screen.dart';
import 'package:skilltok/feuters/profile/presentation/widgets/edit_profile_screen.dart';
import 'package:skilltok/feuters/register/presentation/screen/register_screen.dart';
import 'package:skilltok/feuters/settings/presentation/screen/settings_screen.dart';
import 'package:skilltok/feuters/home/presentation/screen/likes_list_screen.dart';

import 'package:skilltok/feuters/profile/presentation/screen/follow_requests_screen.dart';
import 'package:skilltok/feuters/home/presentation/screen/search_screen.dart';
import 'package:skilltok/feuters/chat/presentation/screen/chat_details_screen.dart';
import 'package:skilltok/core/models/user_model.dart'; // Needed for casting argument

class Routes {
  static const String entry = "/entry";
  static const String login = "/login";
  static const String register = "/register";
  static const String home = "/home";
  static const String buttomnav = "/buttomnav";
  static const String settings = "/settings";
  static const String forgotPassword = "/forgot_password";
  static const String editProfile = "/edit_profile";
  static const String profile = "/profile";
  static const String addPost = "/add_post";
  static const String editPost = "/edit_post";
  static const String comments = "/comments";
  static const String notifications = "/notifications";
  static const followList = '/follow-list';
  static const likesList = '/likes-list';
  static const followRequests = '/follow-requests';
  static const search = '/search';
  static const chatDetails = '/chat_details';

  static Map<String, WidgetBuilder> get routes => {
    entry: (context) => const EntryScreen(),

    register: (context) => RegisterScreen(),
    login: (context) => LoginScreen(),
    home: (context) => const HomeScreen(),
    buttomnav: (context) => const ButtomNav(),
    settings: (context) => const SettingsScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    editProfile: (context) => const EditProfileScreen(),
    profile: (context) => const ProfileScreen(),
    addPost: (context) => const AddPostScreen(),
    editPost: (context) => const EditPostScreen(),
    comments: (context) => const CommentsScreen(),
    notifications: (context) => const NotificationsScreen(),
    followList: (context) => const FollowListScreen(),
    likesList: (context) => const LikesListScreen(),
    followRequests: (context) => const FollowRequestsScreen(),
    search: (context) => const SearchScreen(),
    chatDetails: (context) {
      final user = ModalRoute.of(context)!.settings.arguments as UserModel;
      return ChatDetailsScreen(otherUser: user);
    },
  };
}
