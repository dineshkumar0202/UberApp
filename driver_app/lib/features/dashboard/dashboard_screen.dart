import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_driver/data/providers/auth_provider.dart';
import 'package:ridoo_driver/data/providers/driver_ride_provider.dart';
import 'package:ridoo_driver/features/dashboard/active_trip_panel.dart';
import 'package:ridoo_driver/shared/dialogs/incoming_request_dialog.dart';
import 'package:ridoo_driver/features/wallet/wallet_screen.dart';
import 'package:ridoo_driver/features/profile/profile_screen.dart';
import 'package:ridoo_driver/features/support/support_screen.dart';
import 'package:ridoo_driver/features/ratings/ratings_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rideProvider = Provider.of<DriverRideProvider>(context);
    
    final user = authProvider.user;
    final isOnline = rideProvider.isOnline;
    final activeRide = rideProvider.activeRide;
    final pendingRequests = rideProvider.pendingRequests;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Ridoo Driver',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await rideProvider.toggleOnlineStatus(false);
              await authProvider.logout();
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background/Body
          SafeArea(
            child: Column(
              children: [
                // Status bar
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isOnline ? 'ONLINE' : 'OFFLINE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: isOnline,
                        activeColor: Colors.green,
                        onChanged: (value) async {
                          await rideProvider.toggleOnlineStatus(value);
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome & Profile Section
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFF6C4DFF).withOpacity(0.1),
                              child: const Icon(Icons.person_rounded, size: 36, color: Color(0xFF6C4DFF)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?['name'] ?? 'Driver Partner',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Basic Vehicle (Verified)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Navigation Grid Section
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQuickLink(
                                icon: Icons.account_balance_wallet_rounded,
                                label: 'Wallet',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
                              ),
                              _buildQuickLink(
                                icon: Icons.star_rounded,
                                label: 'Ratings',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingsScreen())),
                              ),
                              _buildQuickLink(
                                icon: Icons.help_outline_rounded,
                                label: 'Support',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
                              ),
                              _buildQuickLink(
                                icon: Icons.person_rounded,
                                label: 'Profile',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Earnings Grid (only shown if not in active ride)
                        if (activeRide == null) ...[
                          const Text(
                            'Today\'s Stats',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Earnings',
                                  value: '₹1,240',
                                  icon: Icons.currency_rupee,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Rides',
                                  value: '8 Completed',
                                  icon: Icons.directions_car,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Rating',
                                  value: '4.95 ★',
                                  icon: Icons.star,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Online Hours',
                                  value: '5.2h',
                                  icon: Icons.access_time_filled,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Status card placeholder
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.explore_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Looking for Ride Requests',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isOnline
                                      ? 'Requests will show up here automatically. Coordinate: ${rideProvider.currentLat.toStringAsFixed(4)}, ${rideProvider.currentLng.toStringAsFixed(4)}'
                                      : 'Please go online to start receiving ride offers.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Map placeholder showing tracking
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.navigation_outlined, size: 48, color: Colors.blueAccent),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Simulated Navigation Tracking Active',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'GPS: ${rideProvider.currentLat.toStringAsFixed(4)}, ${rideProvider.currentLng.toStringAsFixed(4)}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pending request overlay dialog
          if (isOnline && pendingRequests.isNotEmpty && activeRide == null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: IncomingRequestDialog(
                  request: pendingRequests.first,
                ),
              ),
            ),

          // Active ride controls at bottom
          if (activeRide != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ActiveTripPanel(
                ride: activeRide,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLink({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C4DFF).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6C4DFF), size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
