import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/cubits/auth/auth_cubit.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/network/local/cache_helper.dart';
import 'package:skilltok/core/network/notification_repository.dart';
import 'package:skilltok/core/network/service/notification_service.dart';
import 'package:skilltok/core/network/user_repository.dart';
import 'package:skilltok/main.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserStates> {
  UserCubit() : super(UserInitialState());

  // ignore: strict_top_level_inference
  static UserCubit get(context) => BlocProvider.of(context);

  final UserRepository userRepo = UserRepository();
  final NotificationRepository notificationRepo = NotificationRepository();

  UserModel? userModel;
  StreamSubscription? _userSubscription;

  Future<void> cacheUser(UserModel? model) async {
    final json = jsonEncode(model!.toMap());
    await CacheHelper.saveData(key: 'userModel', value: json);
  }

  UserModel? getCachedUser() {
    final json = CacheHelper.getData(key: 'userModel');
    if (json == null) return null;
    return UserModel.fromMap(
      jsonDecode(json),
      FirebaseAuth.instance.currentUser!.uid,
    );
  }

  void listenToUserData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _userSubscription?.cancel(); // Cancel any existing subscription

    _userSubscription = userRepo
        .getUserStream(uid)
        .listen(
          (user) async {
            if (user == null) return; // Should not happen if user is logged in

            final currentToken = await FirebaseMessaging.instance.getToken();

            if (user.fcmToken != currentToken) {
              // Another device has logged in, log this one out
              // We need to call AuthCubit logout.
              // Since we don't have context here, we use navigatorKey.
              if (navigatorKey.currentContext != null) {
                AuthCubit.get(
                  navigatorKey.currentContext!,
                ).logout(navigatorKey.currentContext!);
              }
              return;
            }

            userModel = user;
            await cacheUser(user);
            emit(UserGetUserSuccessState());
          },
          onError: (dynamic error) {
            debugPrint("Error in user stream: $error");
            emit(UserGetUserErrorState(error.toString()));
          },
        );
  }

  Future<void> getUserData() async {
    final cached = getCachedUser();
    if (cached != null) {
      userModel = cached;
      emit(UserGetUserSuccessState());
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      final fresh = await userRepo.getUser(uid);
      if (fresh == null) return;

      // Update FCM Token & UsernameLower for search
      final token = await FirebaseMessaging.instance.getToken();
      bool needsUpdate = false;
      UserModel currentUser = fresh;

      if (token != null && currentUser.fcmToken != token) {
        currentUser = currentUser.copyWith(fcmToken: token);
        needsUpdate = true;
      }

      if (currentUser.username != null &&
          (currentUser.usernameLower == null ||
              currentUser.usernameLower !=
                  currentUser.username!.toLowerCase())) {
        currentUser = currentUser.copyWith(
          usernameLower: currentUser.username!.toLowerCase(),
        );
        needsUpdate = true;
      }

      if (needsUpdate) {
        await userRepo.updateUser(currentUser);
        userModel = currentUser;
        await cacheUser(currentUser);
      } else {
        userModel = fresh;
        await cacheUser(fresh);
      }

      emit(UserGetUserSuccessState());
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      if (cached == null) {
        emit(UserGetUserErrorState(e.toString()));
      }
    }
  }

  Future<void> followUser(String userIdToFollow) async {
    if (userModel == null) return;
    emit(UserFollowUserLoadingState());
    try {
      // Check if target is private to adjust notification text?
      // For now, simple logic. Repository handles the DB part.

      final targetUserDoc = await userRepo.users.doc(userIdToFollow).get();
      final targetUser = UserModel.fromMap(
        targetUserDoc.data() as Map<String, dynamic>,
        userIdToFollow,
      );

      await userRepo.followUser(userModel!.uid!, userIdToFollow);

      String notifContent = "started following you 👤";
      String notifAr = "بدأ بمتابعتك 👤";
      String type = "follow";

      if (targetUser.isPrivateProfile) {
        notifContent = "requested to follow you 👤";
        notifAr = "طلب متابعتك 👤";
        type = "follow_request";
      }

      await NotificationService.send(
        receiverId: userIdToFollow,
        title: userModel!.username!,
        contents: {"en": notifContent, "ar": notifAr},
        data: {"type": type, "senderId": userModel!.uid!},
      );
      await notificationRepo.sendNotification(
        senderId: userModel!.uid!,
        senderName: userModel!.username!,
        senderProfilePic: userModel!.photoUrl!,
        receiverId: userIdToFollow,
        type: type,
        text: notifContent,
      );

      await getUserData();
      emit(UserFollowUserSuccessState());
    } catch (e) {
      debugPrint("Follow error: $e");
      emit(UserFollowUserErrorState(e.toString()));
    }
  }

  Future<void> cancelFollowRequest(String targetUserId) async {
    if (userModel == null) return;
    try {
      await userRepo.cancelFollowRequest(userModel!.uid!, targetUserId);
      await getUserData();
    } catch (e) {
      debugPrint("Cancel Request Error: $e");
    }
  }

  Future<void> acceptFollowRequest(String requesterId) async {
    if (userModel == null) return;
    try {
      await userRepo.acceptFollowRequest(userModel!.uid!, requesterId);

      // Notify requester about acceptance
      await NotificationService.send(
        receiverId: requesterId,
        title: userModel!.username!,
        contents: {
          "en": "accepted your follow request ✅",
          "ar": "قبل طلب متابعتك ✅",
        },
        data: {"type": "follow_accept", "senderId": userModel!.uid!},
      );
      await notificationRepo.sendNotification(
        senderId: userModel!.uid!,
        senderName: userModel!.username!,
        senderProfilePic: userModel!.photoUrl!,
        receiverId: requesterId,
        type: 'follow_accept',
        text: 'accepted your follow request',
      );

      await getUserData();
    } catch (e) {
      debugPrint("Accept Request Error: $e");
    }
  }

  Future<void> declineFollowRequest(String requesterId) async {
    if (userModel == null) return;
    try {
      await userRepo.declineFollowRequest(userModel!.uid!, requesterId);
      await getUserData();
    } catch (e) {
      debugPrint("Decline Request Error: $e");
    }
  }

  Future<void> unfollowUser(String userIdToUnfollow) async {
    if (userModel == null) return;
    emit(UserUnfollowUserLoadingState());
    try {
      await userRepo.unfollowUser(userModel!.uid!, userIdToUnfollow);
      await getUserData();
      emit(UserUnfollowUserSuccessState());
    } catch (e) {
      debugPrint("Unfollow error: $e");
      emit(UserUnfollowUserErrorState(e.toString()));
    }
  }

  Future<void> toggleSavePost(String postId) async {
    if (userModel == null) return;
    try {
      await userRepo.toggleSavePost(userModel!.uid!, postId);
      await getUserData();
      debugPrint("Save post success");
    } catch (e) {
      debugPrint("Save post error: $e");
    }
  }

  List<UserModel> searchResults = [];
  Future<void> searchUsers(String query) async {
    emit(UserSearchLoadingState());
    try {
      searchResults = await userRepo.searchUsers(query);
      emit(UserSearchSuccessState());
    } catch (e) {
      emit(UserSearchErrorState(e.toString()));
    }
  }

  void cancelSubscription() {
    _userSubscription?.cancel();
  }
}
