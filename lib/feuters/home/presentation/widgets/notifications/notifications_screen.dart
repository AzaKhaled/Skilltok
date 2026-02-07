import 'package:flutter/material.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/cubits/notification/notification_cubit.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/feuters/home/presentation/widgets/notifications/notifications_list.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final userCubit = UserCubit.get(context);
    if (userCubit.userModel != null) {
      NotificationCubit.get(
        context,
      ).getNotifications(userCubit.userModel!.uid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTranslation().get('notifications')),
        centerTitle: true,
      ),
      body: const NotificationsList(),
    );
  }
}
