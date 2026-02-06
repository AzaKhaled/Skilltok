import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/text_styles.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final int count;
  final VoidCallback onTap;
  final VoidCallback? onCountTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.count,
    required this.onTap,
    this.color,
    this.onCountTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onCountTap,
              child: Text(count.toString(), style: TextStylesManager.regular12),
            ),
          ],
        ),
      ),
    );
  }
}
