import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/cubits/notification/notification_cubit.dart';
import 'package:skilltok/feuters/home/presentation/widgets/notifications/notification_item.dart';

class NotificationsList extends StatelessWidget {
  const NotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationStates>(
      builder: (context, state) {
        final notifCubit = NotificationCubit.get(context);
        if (state is NotificationGetNotificationsLoadingState &&
            notifCubit.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final notifications = notifCubit.notifications;

        if (notifications.isEmpty) {
          return Center(
            child: Text(
              appTranslation().get('no_notifications'),
              style: TextStylesManager.regular16,
            ),
          );
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return NotificationItem(notification: notifications[index]);
          },
        );
      },
    );
  }
}
