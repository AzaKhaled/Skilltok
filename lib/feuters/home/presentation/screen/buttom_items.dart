import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/text_styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int? badgeCount; // عدد الإشعارات

  const BottomNavItemWidget({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? ColorsManager.pinkGradient
                  : ColorsManager.grayNormalHover,
              size: 24,
            ),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                top: -4,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${badgeCount!}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStylesManager.medium14.copyWith(
            color: isActive
                ? ColorsManager.pinkGradient
                : ColorsManager.textColor,
          ),
        ),
      ],
    );
  }
}
