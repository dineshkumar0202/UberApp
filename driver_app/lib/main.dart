import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_driver/core/storage/local_storage.dart';
import 'package:ridoo_driver/data/providers/auth_provider.dart';
import 'package:ridoo_driver/data/providers/driver_ride_provider.dart';
import 'package:ridoo_driver/features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DriverRideProvider()),
      ],
      child: const RidooDriverApp(),
    ),
  );
}

class RidooDriverApp extends StatelessWidget {
  const RidooDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ridoo Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      home: const SplashScreen(),
    );
  }
}
