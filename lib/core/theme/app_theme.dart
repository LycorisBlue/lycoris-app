import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycoris/core/constants/app_sizes.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      // Police globale pour toute l'application
      fontFamily: GoogleFonts.inter().fontFamily,
      brightness: Brightness.dark,

      // Couleurs principales
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w600),
      ),

      // Texte avec tailles réelles
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          // Tailles extra petites
          labelSmall: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textTertiary, fontWeight: FontWeight.w400),
          labelMedium: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textTertiary, fontWeight: FontWeight.w400),
          labelLarge: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),

          // Tailles petites
          bodySmall: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
          bodyMedium: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w400),
          bodyLarge: GoogleFonts.inter(fontSize: 16.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w400),

          // Titres
          titleSmall: GoogleFonts.inter(fontSize: 18.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.inter(fontSize: 20.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.inter(fontSize: 24.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w700),

          // Headers
          headlineSmall: GoogleFonts.inter(fontSize: 28.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          headlineMedium: GoogleFonts.inter(fontSize: 32.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          headlineLarge: GoogleFonts.inter(fontSize: 36.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w800),
        ),
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.background,
          textStyle: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
        ),
      ),

      // Dividers
      dividerTheme: DividerThemeData(color: AppColors.divider, thickness: 1),
    );
  }
}
