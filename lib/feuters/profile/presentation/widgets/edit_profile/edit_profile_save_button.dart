import 'package:flutter/material.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/feuters/profile/presentation/widgets/edit_profile/edit_profile_circle_icon_button.dart';

class EditProfileSaveButton extends StatelessWidget {
  const EditProfileSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: MediaQuery.of(context).padding.top + 8,
      end: 12,
      child: EditProfileCircleIconButton(
        icon: Icons.check,
        onTap: () {
          if (userCubit.userModel != null) {
            profileCubit.updateProfile(userModel: userCubit.userModel!);
          }
        },
      ),
    );
  }
}
