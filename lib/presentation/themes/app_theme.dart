import 'package:flutter/material.dart';
import '../../core/constant/app_colors.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppColors.textPrimary),
  ),
);

