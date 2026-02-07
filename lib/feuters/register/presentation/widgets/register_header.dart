import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/assets_helper.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AssetsHelper.logo, height: 90, width: 90),
        Transform.translate(
          offset: const Offset(-8, 0), // شمال بسيط جدًا
          child: Text(
            'SkillTok',
            style: TextStylesManager.bold24.copyWith(
              color: ColorsManager.textColor,
            ),
          ),
        ),
        verticalSpace4,
        Text(
          appTranslation().get('join_skilltok_today'),
          style: TextStylesManager.regular16.copyWith(
            color: ColorsManager.textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
