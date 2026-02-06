import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/theme/text_styles.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class RegisterButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isLoading;

  const RegisterButton({
    super.key,
    required this.formKey,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                if (formKey.currentState!.validate()) {
                  authCubit.register();
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
              colors: [ColorsManager.pinkGradient, ColorsManager.blueGradient],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    appTranslation().get('register'),
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
