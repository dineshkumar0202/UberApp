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
  ).copyWith(
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.black87,
    onSecondary: Colors.white,
  ),
  textTheme: AppTypography.textTheme.apply(
    bodyColor: Colors.black87,
    displayColor: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: Colors.black54),
    floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    hintStyle: const TextStyle(color: Colors.grey),
    iconColor: Colors.black54,
    prefixIconColor: Colors.black54,
  ),
  elevatedButtonTheme: AppButtonTheme.elevated,
  scaffoldBackgroundColor: AppColors.backgroundLight,
);
