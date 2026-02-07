import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/cubits/auth/auth_cubit.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class LoginPasswordField extends StatelessWidget {
  const LoginPasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      buildWhen: (_, state) => state is AuthShowPasswordUpdatedState,
      builder: (context, state) {
        return TextFormField(
          controller: authCubit.loginPasswordController,
          obscureText: authCubit.passwordVisibility['login']!,
          obscuringCharacter: "*",
          keyboardType: TextInputType.visiblePassword,
          validator: (value) {
            const pattern = r'^(?=.*[A-Za-z])(?=.*\d).{8,}$';
            if (!RegExp(pattern).hasMatch(value ?? "")) {
              return appTranslation().get('please_enter_password');
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: appTranslation().get('password'),
            filled: true,
            fillColor: ColorsManager.cardColor,
            prefixIcon: const Icon(
              Icons.password,
              color: ColorsManager.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                authCubit.passwordVisibility['login']!
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: ColorsManager.primary,
              ),
              onPressed: () => authCubit.togglePasswordVisibility('login'),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: ColorsManager.textSecondaryColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: ColorsManager.textSecondaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        );
      },
    );
  }
}
