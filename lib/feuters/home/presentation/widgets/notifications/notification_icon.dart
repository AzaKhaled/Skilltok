import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';

class NotificationIcon extends StatelessWidget {
  final String type;

  const NotificationIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'like':
      case 'comment':
        return const Icon(Icons.post_add, color: ColorsManager.primary);
      case 'follow':
        return const Icon(Icons.person_add, color: ColorsManager.primary);
      case 'login_alert':
        return const Icon(Icons.security, color: ColorsManager.error);
      default:
        return const SizedBox.shrink();
    }
  }
}
