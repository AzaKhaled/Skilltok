import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/cubits/profile/profile_cubit.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class EditProfileCover extends StatelessWidget {
  final double height;
  final UserModel user;

  const EditProfileCover({super.key, required this.height, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileStates>(
      buildWhen: (previous, current) => current is ProfileCoverImagePickedState,
      builder: (context, state) {
        ImageProvider? imageProvider;

        if (profileCubit.coverImage != null) {
          imageProvider = FileImage(profileCubit.coverImage!);
        } else if (user.coverUrl != null && user.coverUrl!.isNotEmpty) {
          imageProvider = CachedNetworkImageProvider(user.coverUrl!);
        }

        return GestureDetector(
          onTap: () {
            profileCubit.pickCoverImage();
          },
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: imageProvider == null
                  ? ColorsManager.primary.withValues(alpha: 0.8)
                  : Colors.transparent,
              image: imageProvider != null
                  ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                  : null,
            ),
            child: imageProvider == null
                ? Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 32,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
