import 'package:flutter/material.dart';
import 'package:ridoo_customer/core/theme/colors.dart';

class AppButtonTheme {
  static ElevatedButtonThemeData get elevated => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
}
