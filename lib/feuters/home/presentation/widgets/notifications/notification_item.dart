import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skilltok/core/models/notification_model.dart';
import 'package:skilltok/core/network/service/notification_service.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/cubits/notification/notification_cubit.dart';
import 'package:skilltok/feuters/home/presentation/widgets/notifications/notification_content.dart';
import 'package:skilltok/feuters/home/presentation/widgets/notifications/notification_icon.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          NotificationCubit.get(
            context,
          ).markNotificationAsRead(notification.notificationId);
        }

        NotificationService.handleNotification(context, {
          'type': notification.type,
          'postId': notification.postId,
          'senderId': notification.senderId,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        color: notification.isRead
            ? Colors.transparent
            : ColorsManager.primary.withValues(alpha: 0.05),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: notification.senderProfilePic.isNotEmpty
                  ? CachedNetworkImageProvider(notification.senderProfilePic)
                  : null,
              child: notification.senderProfilePic.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            horizontalSpace12,
            Expanded(child: NotificationContent(notification: notification)),
            NotificationIcon(type: notification.type),
          ],
        ),
      ),
    );
  }
}
