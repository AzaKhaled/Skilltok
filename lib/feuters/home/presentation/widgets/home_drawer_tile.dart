import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class HomeDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final GestureTapCallback onTap;

  const HomeDrawerTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeCubit.isDarkMode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: ColorsManager.primary.withValues(alpha: .12),
        highlightColor: ColorsManager.primary.withValues(alpha: .06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: ColorsManager.primary.withValues(
                    alpha: isDark ? 0.18 : 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: ColorsManager.primary),
              ),
              horizontalSpace16,
              Expanded(
                child: Text(
                  title,
                  style: TextStylesManager.bold16.copyWith(
                    color: ColorsManager.textColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: ColorsManager.primary.withValues(alpha: .5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
