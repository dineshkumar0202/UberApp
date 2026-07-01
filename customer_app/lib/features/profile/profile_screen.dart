import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_customer/core/theme/colors.dart';
import 'package:ridoo_customer/data/providers/auth_provider.dart';
import 'package:ridoo_customer/features/common/no_internet_screen.dart';
import 'package:ridoo_customer/features/common/maintenance_screen.dart';
import 'package:ridoo_customer/features/common/location_permission_screen.dart';
import 'package:ridoo_customer/features/common/force_update_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  
  bool _isEditing = false;
  bool _isLoading = false;
  String _selectedLanguage = 'English'; // English, Tamil, Hindi

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?['name'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate saving changes
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit_note_rounded, color: AppColors.primary),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Reset fields
                  _nameController.text = user?['name'] ?? '';
                  _emailController.text = user?['email'] ?? '';
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Avatar Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          (user?['name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?['name'] ?? 'Rider',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoalBlack),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?['phone'] ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Profile Form
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personal Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.black54),
                        filled: true,
                        fillColor: _isEditing ? Colors.grey[50] : Colors.grey[200],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: _isEditing,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
                        filled: true,
                        fillColor: _isEditing ? Colors.grey[50] : Colors.grey[200],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!regex.hasMatch(val.trim())) return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Language Settings Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('App Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildLanguageOption('English'),
                  _buildLanguageOption('Tamil'),
                  _buildLanguageOption('Hindi'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About Ridoo Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About Ridoo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildAboutRow('App Version', 'v1.4.2'),
                  const Divider(height: 24),
                  _buildAboutRow('Company', 'Ridoo Technologies Inc.'),
                  const Divider(height: 24),
                  _buildAboutRow('Terms of Service', 'Read', isLink: true),
                  const Divider(height: 24),
                  _buildAboutRow('Privacy Policy', 'Read', isLink: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // UI Demo Screens Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('UI Demo Screens', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('No Connection Screen', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black38),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoInternetScreen())),
                  ),
                  const Divider(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('System Maintenance Screen', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black38),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceScreen())),
                  ),
                  const Divider(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('GPS Permission Screen', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black38),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationPermissionScreen())),
                  ),
                  const Divider(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('App Update Screen', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black38),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForceUpdateScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String lang) {
    final isSelected = _selectedLanguage == lang;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(lang, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87)),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = lang;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $lang'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.black,
          ),
        );
      },
    );
  }

  Widget _buildAboutRow(String title, String value, {bool isLink = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLink ? Colors.blue : Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
