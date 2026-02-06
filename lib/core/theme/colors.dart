import 'package:flutter/material.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class ColorsManager {
  static bool get isDark => themeCubit.isDarkMode;

  // -------- PRIMARY COLORS (SkillTok Identity - من واقع الصور) -------- //
  static const Color primary = Color(0xFF9B66FF); // اللون البنفسجي المتوسط
  static const Color pinkGradient = Color(0xFFFF45BD); // بداية الـ Gradient
  static const Color blueGradient = Color(0xFF2FD1FF); // نهاية الـ Gradient
  static const Color neonGreen = Color(
    0xFF2DE18A,
  ); // اللون الأخضر الموجود في الأزرار والبروفايل
  static const Color grayNormalHover = Color(0xFF7C8391);
  static const Color secondaryNormal = Color(0xFF739ABF);
  static const Color orange = Color(0xFFFFA043);
  // -------- LIGHT THEME (زي صورة الـ Login البيضاء) -------- //
  static const Color lightBackground = Color(
    0xFFF2F2F2,
  ); // الرمادي الفاتح جداً للخلفية
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF101213);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightInput = Color(0xFFE8E8E8); // لون حقول الإدخال الفاتحة

  // -------- DARK THEME (زي صورة الـ Login الغامقة والـ Main Feed) -------- //
  static const Color darkBackground = Color(
    0xFF121212,
  ); // الأسود المطفي للديزاين
  static const Color darkCard = Color(
    0xFF1E1E1E,
  ); // لون الكروت والحقول في الـ Dark
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFA1A1AA);

  // -------- SHARED -------- //
  static const Color success = Color(0xFF2DE18A);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  // أضف هذا المتغير داخل class ColorsManager
  static const Color neonBlue = Color(
    0xFF2FD1FF,
  ); // اللون الأزرق الموجود في إطارات السيتنج

  // وإذا أردت استخدامه كألوان متغيرة حسب الثيم:
  // -------- THEME COLORS -------- //
  static Color get textColor => isDark ? darkTextPrimary : lightTextPrimary;
  static Color get backgroundColor => isDark ? darkBackground : lightBackground;
  static Color get cardColor => isDark ? darkCard : lightCard;
  static Color get textSecondaryColor =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color get iconColor => isDark ? darkTextPrimary : lightTextPrimary;
  static Color get iconSecondaryColor =>
      isDark ? darkTextSecondary : lightTextSecondary;
  // داخل class ColorsManager أضف هذه السطور:
  static Color get outlineColor =>
      isDark ? neonBlue : primary.withValues(alpha: 0.5);

  static Color get navBarActiveColor =>
      primary; // اللون البنفسجي ثابت للطرفين لترسيخ البراند
  static Color get navBarInactiveColor =>
      isDark ? darkTextSecondary : lightTextSecondary;
}
