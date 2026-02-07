import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/cubits/profile/profile_cubit.dart';
import 'package:skilltok/feuters/profile/presentation/widgets/edit_profile/edit_profile_back_button.dart';
import 'package:skilltok/feuters/profile/presentation/widgets/edit_profile/edit_profile_cover.dart';
import 'package:skilltok/feuters/profile/presentation/widgets/edit_profile/edit_profile_form.dart';
import 'package:skilltok/feuters/profile/presentation/widgets/edit_profile/edit_profile_header.dart';
import 'package:skilltok/feuters/profile/presentation/widgets/edit_profile/edit_profile_save_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const double coverHeight = 220;
  static const double profileRadius = 52;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    super.initState();
    final user = userCubit.userModel;

    if (user != null) {
      profileCubit.usernameController.text = user.username ?? '';
      profileCubit.bioController.text = user.bio ?? '';
      profileCubit.isPrivateProfile = user.isPrivateProfile;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = userCubit.userModel;

    return BlocConsumer<ProfileCubit, ProfileStates>(
      buildWhen: (previous, current) =>
          current is ProfileUpdateProfileSuccessState ||
          current is ProfileUpdateProfileErrorState ||
          current is ProfileUpdateProfileLoadingState ||
          current is ProfileProfileImagePickedState ||
          current is ProfileCoverImagePickedState,
      listener: (context, state) {
        if (state is ProfileUpdateProfileSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appTranslation().get('profile_updated_successfully'),
              ),
              backgroundColor: ColorsManager.success,
              duration: const Duration(seconds: 2),
            ),
          );
          // userCubit.userModel = state.updatedUser; // Should update UserCubit if possible
          // UserCubit's stream listener will handle this automatically if we update Firestore
          Navigator.pop(
            context,
          ); // Use Navigator.pop instead of context.pop getter if issue
        }
      },
      builder: (context, state) {
        if (state is ProfileUpdateProfileLoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: ColorsManager.backgroundColor,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                EditProfileCover(
                  height: EditProfileScreen.coverHeight,
                  user: user!,
                ),
                const EditProfileBackButton(),
                const EditProfileSaveButton(),
                Padding(
                  padding: const EdgeInsets.only(
                    top:
                        EditProfileScreen.coverHeight -
                        EditProfileScreen.profileRadius,
                  ),
                  child: Column(
                    children: [
                      EditProfileHeader(
                        user: user,
                        profileRadius: EditProfileScreen.profileRadius,
                      ),
                      const EditProfileForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
