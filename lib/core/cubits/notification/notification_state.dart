part of 'notification_cubit.dart';

abstract class NotificationStates {}

class NotificationInitialState extends NotificationStates {}

class NotificationGetNotificationsLoadingState extends NotificationStates {}

class NotificationGetNotificationsSuccessState extends NotificationStates {
  final List<NotificationModel> notifications;
  NotificationGetNotificationsSuccessState(this.notifications);
}

class NotificationGetNotificationsErrorState extends NotificationStates {
  final String error;
  NotificationGetNotificationsErrorState(this.error);
}
