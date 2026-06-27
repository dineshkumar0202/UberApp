import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_driver/data/providers/auth_provider.dart';

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
  String _selectedLanguage = 'English';

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
          content: Text('Profile details updated successfully!'),
          backgroundColor: Color(0xFF25A365),
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
        title: const Text('Driver Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit_note_rounded, color: const Color(0xFF6C4DFF)),
            onPressed: () {
              setState(() {
                if (_isEditing) {
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
            // Profile header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: const Color(0xFF6C4DFF).withOpacity(0.1),
                        child: Text(
                          (user?['name'] ?? 'D')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF6C4DFF)),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF6C4DFF), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?['name'] ?? 'Driver Partner',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Partner Code: RIDO-DRV-${user?['id'] ?? '100'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Profile info
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Partner Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        filled: true,
                        fillColor: _isEditing ? Colors.grey[50] : Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: _isEditing ? Colors.grey[50] : Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!regex.hasMatch(val.trim())) return 'Enter valid email';
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
                            backgroundColor: const Color(0xFF6C4DFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

            // Languages Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
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

            // About Ridoo Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Partner Policies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildAboutRow('App Version', 'v1.4.2 (Driver)'),
                  const Divider(height: 24),
                  _buildAboutRow('Terms & Conditions', 'Read', isLink: true),
                  const Divider(height: 24),
                  _buildAboutRow('Privacy Policy', 'Read', isLink: true),
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
      title: Text(lang, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6C4DFF)) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = lang;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Driver app language changed to $lang'),
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFF6C4DFF),
          ),
        );
      },
    );
  }

  Widget _buildAboutRow(String title, String value, {bool isLink = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLink ? const Color(0xFF6C4DFF) : Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
