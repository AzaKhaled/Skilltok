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
import 'package:skilltok/feuters/register/presentation/widgets/register_button.dart';
import 'package:skilltok/feuters/register/presentation/widgets/register_email_field.dart';
import 'package:skilltok/feuters/register/presentation/widgets/register_header.dart';
import 'package:skilltok/feuters/register/presentation/widgets/register_name_field.dart';
import 'package:skilltok/feuters/register/presentation/widgets/register_password_field.dart';

class RegisterScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      buildWhen: (_, state) =>
          state is AuthRegisterLoadingState ||
          state is AuthRegisterSuccessState ||
          state is AuthRegisterErrorState,
      listener: (context, state) {
        if (state is AuthRegisterSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appTranslation().get('register_success')),
              backgroundColor: ColorsManager.success,
              duration: const Duration(seconds: 2),
            ),
          );
          context.pushReplacement<Object>(Routes.login);
        } else if (state is AuthRegisterErrorState) {
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
                      const RegisterHeader(),
                      verticalSpace40,
                      const RegisterNameField(),
                      verticalSpace20,
                      const RegisterEmailField(),
                      verticalSpace20,
                      const RegisterPasswordField(),
                      verticalSpace30,
                      RegisterButton(
                        formKey: formKey,
                        isLoading: state is AuthRegisterLoadingState,
                      ),
                      verticalSpace20,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appTranslation().get('have_account'),
                            style: TextStylesManager.regular14.copyWith(
                              color: ColorsManager.textSecondaryColor,
                            ),
                          ),
                          horizontalSpace6,
                          GestureDetector(
                            onTap: () {
                              context.push<Object>(Routes.login);
                            },
                            child: Text(
                              appTranslation().get('login_here'),
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
