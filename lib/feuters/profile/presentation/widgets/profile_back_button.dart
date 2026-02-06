import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';

class ProfileBackButton extends StatelessWidget {
  const ProfileBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: MediaQuery.of(context).padding.top + 8,
      start: 12,
      child: GestureDetector(
        onTap: () => context.pop,
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
          child: Icon(
            Icons.arrow_back_ios_new,
            color: ColorsManager.textColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}
