import 'package:flutter/material.dart';
import 'package:ridoo_customer/core/theme/colors.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Under Maintenance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'We are upgrading our booking systems to provide a faster, safer, and more reliable ride-sharing experience. Ridoo will be back online shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 32),

              // Maintenance details card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Start Time', '02:00 AM IST'),
                    const Divider(height: 20),
                    _buildDetailRow('Estimated Return', '05:00 AM IST'),
                    const Divider(height: 20),
                    _buildDetailRow('Inquiries', 'support@ridoo.com'),
                  ],
                ),
              ),
              const Spacer(),
              
              Text(
                'Thank you for your patience!',
                style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.charcoalBlack)),
      ],
    );
  }
}
