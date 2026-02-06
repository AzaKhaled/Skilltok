import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class AddPostButtom extends StatelessWidget {
  const AddPostButtom({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (userCubit.userModel != null) {
            postCubit.addPost(
              text: postCubit.postTextController.text,
              userModel: userCubit.userModel!,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero, // مهم للـ gradient
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                ColorsManager.pinkGradient,
                ColorsManager.primary,
                ColorsManager.orange,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: Text(
              appTranslation().get('post'),
              style: TextStylesManager.regular16.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
