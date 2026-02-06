import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/spacing.dart';

class EditProfileForm extends StatelessWidget {
  const EditProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorsManager.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            TextFormField(
              controller: profileCubit.usernameController,
              decoration: InputDecoration(
                labelText: appTranslation().get('username'),
                border: const OutlineInputBorder(),
              ),
            ),
            verticalSpace16,
            TextFormField(
              controller: profileCubit.bioController,
              decoration: InputDecoration(
                labelText: appTranslation().get('bio'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            verticalSpace16,
            StatefulBuilder(
              builder: (context, setState) {
                return SwitchListTile(
                  title: const Text(
                    "Private Account",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "Only approved users can follow you",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  value: profileCubit.isPrivateProfile,
                  onChanged: (val) {
                    setState(() {
                      profileCubit.isPrivateProfile = val;
                    });
                  },
                  activeThumbColor: ColorsManager.primary,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
