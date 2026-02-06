import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skilltok/core/models/notification_model.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class NotificationContent extends StatelessWidget {
  final NotificationModel notification;

  const NotificationContent({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    if (notification.type == 'login_alert') {
      return _buildLoginAlertContent();
    }

    return _buildDefaultContent();
  }

  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${notification.senderName} ',
                style: TextStylesManager.bold14.copyWith(
                  color: ColorsManager.textColor,
                ),
              ),
              TextSpan(
                text: _getLocalizedText(notification),
                style: TextStylesManager.regular14.copyWith(
                  color: ColorsManager.textColor,
                ),
              ),
            ],
          ),
        ),
        verticalSpace4,
        Text(
          DateFormat.yMMMd().add_jm().format(notification.timestamp.toDate()),
          style: TextStylesManager.regular12.copyWith(
            color: ColorsManager.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  String _getLocalizedText(NotificationModel notification) {
    switch (notification.type) {
      case 'like':
        return appTranslation().get('notification_like');
      case 'follow':
        return appTranslation().get('notification_follow');
      case 'follow_request':
        return appTranslation().get('notification_follow_request');
      case 'follow_accept':
        return appTranslation().get('notification_follow_accept');
      case 'comment':
        String commentText = notification.text ?? '';
        // Strip English prefix if present (for backward compatibility)
        if (commentText.startsWith("commented on your post: ")) {
          commentText = commentText.replaceFirst(
            "commented on your post: ",
            "",
          );
        }
        return "${appTranslation().get('notification_comment')}: $commentText";
      default:
        return notification.text ?? '';
    }
  }

  Widget _buildLoginAlertContent() {
    final deviceInfo = notification.deviceInfo;
    String deviceText = 'New login from an unknown device.';

    if (deviceInfo != null) {
      final platform = deviceInfo['platform'] ?? '';
      final model = deviceInfo['model'] ?? '';
      deviceText = 'New login on $model ($platform)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appTranslation().get('security_alert'), // "Security Alert"
          style: TextStylesManager.bold14.copyWith(color: ColorsManager.error),
        ),
        verticalSpace4,
        Text(
          deviceText,
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.textColor,
          ),
        ),
        verticalSpace4,
        Text(
          DateFormat.yMMMd().add_jm().format(notification.timestamp.toDate()),
          style: TextStylesManager.regular12.copyWith(
            color: ColorsManager.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
