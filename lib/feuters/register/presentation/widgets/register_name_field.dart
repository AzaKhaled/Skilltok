import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class RegisterNameField extends StatelessWidget {
  const RegisterNameField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: authCubit.registerNameController,
      keyboardType: TextInputType.name,
      validator: (value) => value == null || value.trim().isEmpty
          ? appTranslation().get('please_enter_name')
          : null,
      decoration: InputDecoration(
        hintText: appTranslation().get('name'),
        prefixIcon: const Icon(
          Icons.person_outline,
          color: ColorsManager.primary,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
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
  }
}
