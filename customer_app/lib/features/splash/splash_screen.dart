import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_customer/core/theme/colors.dart';
import 'package:ridoo_customer/data/providers/auth_provider.dart';
import 'package:ridoo_customer/features/auth/login/login_screen.dart';
import 'package:ridoo_customer/features/home/home_screen.dart';

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
    
    // Allow splash to show for 2.5 seconds for a premium brand feel
    await Future.delayed(const Duration(milliseconds: 2500));
    
    await authProvider.checkAuthStatus();
    
    if (mounted) {
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
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
      backgroundColor: AppColors.accentYellow,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Geometric "R" Logo
              const GeometricRLogo(),
              const SizedBox(height: 28),
              
              // Ridoo Brand Name
              const Text(
                'Ridoo',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.charcoalBlack,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              
              // Tagline
              const Text(
                'Your Ride, Anytime, Anywhere',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppColors.charcoalBlack,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              
              // Sleek White Sedan Graphic / Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Premium Sedan Service',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class GeometricRLogo extends StatelessWidget {
  const GeometricRLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.charcoalBlack,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoalBlack.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(60, 60),
          painter: RLogoPainter(),
        ),
      ),
    );
  }
}

class RLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary // Vivid Purple
      ..style = PaintingStyle.fill;

    // Draw the rounded loop and leg of R
    final path = Path()
      ..moveTo(12, 5)
      ..lineTo(38, 5)
      ..quadraticBezierTo(58, 18, 38, 32)
      ..lineTo(24, 32)
      ..lineTo(48, 55)
      ..lineTo(32, 55)
      ..lineTo(12, 32)
      ..close();
    
    // Draw the vertical stem of R
    final stemPath = Path()
      ..moveTo(12, 5)
      ..lineTo(24, 5)
      ..lineTo(24, 55)
      ..lineTo(12, 55)
      ..close();

    canvas.drawPath(path, paint);
    
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(stemPath, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
