import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type system.
///
/// Fraunces (soft serif) carries the brand voice in display and headline
/// styles; Manrope handles everything functional.
abstract final class AppTypography {
  static const display = 'Fraunces';
  static const body = 'Manrope';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      fontSize: 52,
      height: 1.05,
      letterSpacing: -1.2,
      color: AppColors.ink,
    ),
    displayMedium: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      fontSize: 40,
      height: 1.08,
      letterSpacing: -0.8,
      color: AppColors.ink,
    ),
    displaySmall: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w500,
      fontSize: 32,
      height: 1.12,
      letterSpacing: -0.5,
      color: AppColors.ink,
    ),
    headlineMedium: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w500,
      fontSize: 28,
      height: 1.15,
      letterSpacing: -0.4,
      color: AppColors.ink,
    ),
    headlineSmall: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w500,
      fontSize: 22,
      height: 1.2,
      letterSpacing: -0.2,
      color: AppColors.ink,
    ),
    titleLarge: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w700,
      fontSize: 20,
      height: 1.3,
      color: AppColors.ink,
    ),
    titleMedium: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.35,
      color: AppColors.ink,
    ),
    titleSmall: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      height: 1.35,
      color: AppColors.ink,
    ),
    bodyLarge: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.5,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.5,
      color: AppColors.inkMuted,
    ),
    bodySmall: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 1.4,
      color: AppColors.inkMuted,
    ),
    labelLarge: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.2,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      height: 1.2,
    ),
    labelSmall: TextStyle(
      fontFamily: body,
      fontWeight: FontWeight.w600,
      fontSize: 11,
      height: 1.2,
      letterSpacing: 0.8,
      color: AppColors.inkMuted,
    ),
  );
}
