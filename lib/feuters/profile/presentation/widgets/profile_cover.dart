import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/primary/image_preview_page.dart';

class ProfileCover extends StatelessWidget {
  final double height;
  final String? imageUrl;

  const ProfileCover({super.key, required this.height, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<Object>(
            builder: (context) => ImagePreviewPage(url: imageUrl!),
          ),
        );
      },
      child: Container(
        height: height,
        width: double.infinity,
        color: ColorsManager.cardColor,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover)
            : Container(color: ColorsManager.primary.withValues(alpha: 0.25)),
      ),
    );
  }
}
