import 'package:flutter/material.dart';
import 'package:ridoo_customer/core/theme/app_theme.dart';
import 'package:ridoo_customer/features/splash/splash_screen.dart';

class RidooCustomerApp extends StatelessWidget {
  const RidooCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ridoo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
