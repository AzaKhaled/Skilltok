import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

import 'package:skilltok/core/cubits/bottom_nav/bottom_nav_cubit.dart';

class AddPostAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AddPostAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // leading: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: GestureDetector(
      //     onTap: () => BottomNavCubit.get(context).currentIndex = 0,
      //     child: Container(
      //       padding: const EdgeInsets.all(8),
      //       decoration: BoxDecoration(
      //         shape: BoxShape.circle,
      //         gradient: const LinearGradient(
      //           begin: Alignment.topLeft,
      //           end: Alignment.bottomRight,
      //           colors: [
      //             ColorsManager.primary, // البنفسجي المتوسط
      //             ColorsManager.pinkGradient, // الوردي
      //             ColorsManager.orange,
      //           ],
      //         ),
      //         boxShadow: [
      //           BoxShadow(color: Colors.black.withValues(alpha: 0.15)),
      //         ],
      //       ),
      //       child: Icon(
      //         Icons.arrow_back_ios_new,
      //         color: ColorsManager.lightBackground,
      //         size: 22,
      //       ),
      //     ),
      //   ),
      // ),
      title: Text(appTranslation().get("add_post")),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
