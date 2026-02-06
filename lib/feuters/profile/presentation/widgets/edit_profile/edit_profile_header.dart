import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/feuters/profile/presentation/widgets/edit_profile/edit_profile_circle_icon_button.dart';

class EditProfileHeader extends StatelessWidget {
  final dynamic user;
  final double profileRadius;

  const EditProfileHeader({
    super.key,
    required this.user,
    required this.profileRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: profileRadius + 4,
          backgroundColor: ColorsManager.backgroundColor,
          child: CircleAvatar(
            radius: profileRadius,
            backgroundImage: _buildProfileImage(),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                if (profileCubit.profileImage == null && user.photoUrl!.isEmpty)
                  const Center(child: Icon(Icons.person, size: 48)),
                EditProfileCircleIconButton(
                  icon: Icons.camera_alt,
                  onTap: () {
                    profileCubit.pickProfileImage();
                  },
                ),
              ],
            ),
          ),
        ),
        verticalSpace16,
      ],
    );
  }

  ImageProvider? _buildProfileImage() {
    if (profileCubit.profileImage != null) {
      return FileImage(profileCubit.profileImage!);
    }
    if (user.photoUrl.isNotEmpty) {
      return CachedNetworkImageProvider(user.photoUrl);
    }
    return null;
  }
}
