import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/assets_helper.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class RegisterProfileImage extends StatelessWidget {
  const RegisterProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    final image = authCubit.registerProfileImage;
    return GestureDetector(
      onTap: () => authCubit.pickRegisterProfileImage(),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: ColorsManager.primary.withValues(alpha: .15),
            backgroundImage: image != null
                ? FileImage(image)
                : const AssetImage(AssetsHelper.logo),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: ColorsManager.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
