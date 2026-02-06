import 'package:flutter/material.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/theme/colors.dart';

class ProfileActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const ProfileActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeCubit.isDarkMode;

    final backgroundColor = isPrimary
        ? ColorsManager.primary
        : (isDark ? Colors.grey[800] : Colors.grey[200]);

    final foregroundColor = isPrimary
        ? Colors.white
        : (isDark ? Colors.white : Colors.black);

    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}
