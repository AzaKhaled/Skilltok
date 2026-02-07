import 'package:flutter/material.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/cubits/post/post_cubit.dart';

class PostTextField extends StatelessWidget {
  const PostTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.cardColor, // استخدام لون الكارت الغامق
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), // ظل أسود خفيف جداً
            blurRadius: 10,
            offset: const Offset(0, 4), // إزاحة الظل للأسفل قليلاً
          ),
        ],
      ),
      child: TextFormField(
        controller: PostCubit.get(context).postTextController,
        style: TextStyle(color: ColorsManager.textColor), // لون النص الأساسي
        maxLines: null,
        minLines: 3, // زدتها لتشبه مساحة الوصف في الصورة
        decoration: InputDecoration(
          hintText: appTranslation().get("what_on_your_mind"),
          hintStyle: TextStyle(
            color: ColorsManager.textSecondaryColor.withValues(alpha: 0.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder
              .none, // إزالة الحدود الافتراضية لأننا نستخدم الـ Container
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: ColorsManager.primary.withValues(
                alpha: 0.5,
              ), // إضاءة خفيفة عند التركيز
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
