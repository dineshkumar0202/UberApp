import 'package:flutter/material.dart';
import 'package:ridoo_customer/core/theme/button_theme.dart';
import 'package:ridoo_customer/core/theme/colors.dart';
import 'package:ridoo_customer/core/theme/typography.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ),
  textTheme: AppTypography.textTheme,
  elevatedButtonTheme: AppButtonTheme.elevated,
  scaffoldBackgroundColor: AppColors.backgroundLight,
);
