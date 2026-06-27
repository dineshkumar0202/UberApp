import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_driver/data/providers/auth_provider.dart';
import 'package:ridoo_driver/features/auth/login/login_screen.dart';
import 'package:ridoo_driver/features/dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    await authProvider.checkAuthStatus();
    
    if (mounted) {
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                size: 80,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ridoo Driver',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Driver Partner App',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
