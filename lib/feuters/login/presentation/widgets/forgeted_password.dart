import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/cubits/auth/auth_cubit.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthForgotPasswordSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is AuthForgotPasswordErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: state is AuthForgotPasswordLoadingState
              ? null
              : () => authCubit.sendPasswordResetEmail(),
          child: Text(
            appTranslation().get('forgot_password'),
            style: TextStylesManager.medium14.copyWith(
              color: ColorsManager.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
