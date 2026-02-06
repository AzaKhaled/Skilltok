import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class LoginEmailField extends StatelessWidget {
  const LoginEmailField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: authCubit.loginEmailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) =>
          value!.isEmpty ? appTranslation().get('please_enter_email') : null,
      decoration: InputDecoration(
        hintText: appTranslation().get('email_address'),
        prefixIcon: const Icon(
          Icons.email_rounded,
          color: ColorsManager.primary,
        ),

        filled: true,
        fillColor: ColorsManager.cardColor,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: ColorsManager.textSecondaryColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            width: 1.5,
            color: ColorsManager.textSecondaryColor,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: ColorsManager.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: ColorsManager.error, width: 1.5),
        ),
      ),
    );
  }
}
