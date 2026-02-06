import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/models/notification_model.dart';
import 'package:skilltok/core/network/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationStates> {
  NotificationCubit() : super(NotificationInitialState());

  // ignore: strict_top_level_inference
  static NotificationCubit get(context) => BlocProvider.of(context);

  final NotificationRepository notificationRepo = NotificationRepository();

  List<NotificationModel> notifications = [];
  int unreadNotificationsCount = 0;

  void getNotifications(String uid) {
    emit(NotificationGetNotificationsLoadingState());
    try {
      notificationRepo.getUserNotifications(uid).listen((event) {
        notifications = event;
        unreadNotificationsCount = notifications.where((n) => !n.isRead).length;
        emit(NotificationGetNotificationsSuccessState(event));
      });
    } catch (e) {
      emit(NotificationGetNotificationsErrorState(e.toString()));
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await notificationRepo.markNotificationAsRead(notificationId);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }
}
