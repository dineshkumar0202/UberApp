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
      backgroundColor: const Color(0xFFF7C815),
      body: Stack(
        children: [
          // City Skyline silhouette at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 180,
            child: CustomPaint(
              painter: CitySkylinePainter(color: Colors.black.withOpacity(0.08)),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SteeringWheelLogo(size: 110),
                const SizedBox(height: 28),
                const Text(
                  'Ridoo',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Ride, Anytime, Anywhere',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Steering Wheel Logo Drawing
class SteeringWheelLogo extends StatelessWidget {
  final double size;
  const SteeringWheelLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.55, size * 0.55),
          painter: SteeringWheelPainter(),
        ),
      ),
    );
  }
}

class SteeringWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF7C815)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Outer circle
    canvas.drawCircle(center, radius, paint);

    // Inner center cap
    final capPaint = Paint()
      ..color = const Color(0xFFF7C815)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.25, capPaint);

    // Spokes (left, right, bottom)
    final spokePaint = Paint()
      ..color = const Color(0xFFF7C815)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;

    // Left spoke
    canvas.drawLine(
      Offset(center.dx - radius * 0.25, center.dy),
      Offset(center.dx - radius, center.dy),
      spokePaint,
    );
    // Right spoke
    canvas.drawLine(
      Offset(center.dx + radius * 0.25, center.dy),
      Offset(center.dx + radius, center.dy),
      spokePaint,
    );
    // Bottom spoke
    canvas.drawLine(
      Offset(center.dx, center.dy + radius * 0.25),
      Offset(center.dx, center.dy + radius),
      spokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// City Skyline silhouette painter
class CitySkylinePainter extends CustomPainter {
  final Color color;
  CitySkylinePainter({this.color = const Color(0x33F5B041)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(w * 0.06, h * 0.75);
    path.lineTo(w * 0.06, h * 0.6);
    path.lineTo(w * 0.12, h * 0.6);
    path.lineTo(w * 0.12, h * 0.85);
    path.lineTo(w * 0.18, h * 0.85);
    path.lineTo(w * 0.18, h * 0.5);
    path.lineTo(w * 0.26, h * 0.5);
    path.lineTo(w * 0.26, h * 0.8);
    path.lineTo(w * 0.32, h * 0.8);
    path.lineTo(w * 0.32, h * 0.4);
    path.lineTo(w * 0.40, h * 0.4);
    path.lineTo(w * 0.40, h * 0.9);
    path.lineTo(w * 0.46, h * 0.9);
    path.lineTo(w * 0.46, h * 0.3);
    path.lineTo(w * 0.50, h * 0.15); // Spire tower
    path.lineTo(w * 0.54, h * 0.3);
    path.lineTo(w * 0.54, h * 0.85);
    path.lineTo(w * 0.62, h * 0.85);
    path.lineTo(w * 0.62, h * 0.45);
    path.lineTo(w * 0.70, h * 0.45);
    path.lineTo(w * 0.70, h * 0.8);
    path.lineTo(w * 0.76, h * 0.8);
    path.lineTo(w * 0.76, h * 0.55);
    path.lineTo(w * 0.84, h * 0.55);
    path.lineTo(w * 0.84, h * 0.9);
    path.lineTo(w * 0.90, h * 0.9);
    path.lineTo(w * 0.90, h * 0.65);
    path.lineTo(w * 1.0, h * 0.65);
    path.lineTo(w * 1.0, h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
