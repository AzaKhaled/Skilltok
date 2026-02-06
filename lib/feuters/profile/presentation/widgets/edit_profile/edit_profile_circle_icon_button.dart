import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';

class EditProfileCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const EditProfileCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorsManager.cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: ColorsManager.textColor, size: 20),
      ),
    );
  }
}
