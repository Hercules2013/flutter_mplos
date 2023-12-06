import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:mplos_chat/shared/theme/text_styles.dart';

class TextThemes {
  // Main text theme

  static TextTheme get textTheme {
    return GoogleFonts.dmSansTextTheme().copyWith(
      bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.black),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.black),
      titleMedium: AppTextStyles.bodySm.copyWith(color: AppColors.black),
      titleSmall: AppTextStyles.bodyXs.copyWith(color: AppColors.black),
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.black),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.black),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.black),
      headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.black),
    );
  }

  // Dark text theme

  static TextTheme get darkTextTheme {
    return GoogleFonts.dmSansTextTheme().copyWith(
      bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.white),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.white),
      titleMedium: AppTextStyles.bodySm.copyWith(color: AppColors.white),
      titleSmall: AppTextStyles.bodyXs.copyWith(color: AppColors.white),
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.white),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.white),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.white),
      headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.white),
    );
  }

  // Primary text theme

  static TextTheme get primaryTextTheme {
    return GoogleFonts.dmSansTextTheme().copyWith(
      bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.primary),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.primary),
      titleMedium: AppTextStyles.bodySm.copyWith(color: AppColors.primary),
      titleSmall: AppTextStyles.bodyXs.copyWith(color: AppColors.primary),
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.primary),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.primary),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.primary),
      headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.primary),
    );
  }
}
