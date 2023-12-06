import 'package:flutter/material.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';
import 'package:mplos_chat/shared/theme/text_styles.dart';
import 'package:mplos_chat/shared/theme/text_theme.dart';

class AppTheme {
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
        // brightness: Brightness.dark,
        fontFamily: AppTextStyles.fontFamily,
        primaryColor: AppColors.black,
        colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.lightGrey,
            error: AppColors.error,
            background: AppColors.black),
        scaffoldBackgroundColor: AppColors.black,
        textTheme: TextThemes.darkTextTheme,
        primaryTextTheme: TextThemes.primaryTextTheme,
        appBarTheme:
            const AppBarTheme(elevation: 0, backgroundColor: AppColors.black));
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
        // brightness: Brightness.light,
        fontFamily: AppTextStyles.fontFamily,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.lightGrey,
            error: AppColors.error),
        scaffoldBackgroundColor: AppColors.white,
        textTheme: TextThemes.textTheme,
        primaryTextTheme: TextThemes.primaryTextTheme,
        appBarTheme:
            const AppBarTheme(elevation: 0, backgroundColor: AppColors.primary),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.windows: CupertinoPageTransitionsBuilder()
        }));
  }
}
