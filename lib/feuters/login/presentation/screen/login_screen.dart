import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';
import 'package:skilltok/core/cubits/auth/auth_cubit.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/feuters/login/presentation/widgets/forgeted_password.dart';
import 'package:skilltok/feuters/login/presentation/widgets/login_button.dart';
import 'package:skilltok/feuters/login/presentation/widgets/login_email_field.dart';
import 'package:skilltok/feuters/login/presentation/widgets/login_header.dart';
import 'package:skilltok/feuters/login/presentation/widgets/login_password_field.dart';

class LoginScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      buildWhen: (_, state) =>
          state is AuthLoginLoadingState ||
          state is AuthLoginSuccessState ||
          state is AuthLoginErrorState,
      listener: (context, state) {
        if (state is AuthLoginSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appTranslation().get('login_success')),
              backgroundColor: ColorsManager.success,
              duration: const Duration(seconds: 2),
            ),
          );
          userCubit.listenToUserData(); // Trigger user data listening
          context.pushReplacement<Object>(Routes.buttomnav);
          authCubit.loginEmailController.clear();
          authCubit.loginPasswordController.clear();
        } else if (state is AuthLoginErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: ColorsManager.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final isDark = themeCubit.isDarkMode;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const LoginHeader(),
                      verticalSpace40,
                      const LoginEmailField(),
                      verticalSpace20,
                      const LoginPasswordField(),
                      verticalSpace20,
                      ForgotPasswordScreen(),
                      verticalSpace30,
                      LoginButton(
                        formKey: formKey,
                        isLoading: state is AuthLoginLoadingState,
                      ),
                      verticalSpace20,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appTranslation().get('dont_have_account'),
                            style: TextStylesManager.regular14.copyWith(
                              color: ColorsManager.textSecondaryColor,
                            ),
                          ),
                          horizontalSpace6,
                          GestureDetector(
                            onTap: () {
                              context.push<Object>(Routes.register);
                            },
                            child: Text(
                              appTranslation().get('create_account'),
                              style: TextStylesManager.medium14.copyWith(
                                color: ColorsManager.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
