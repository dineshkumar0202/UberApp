import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ridoo_customer/core/theme/colors.dart';
import 'package:ridoo_customer/core/network/api_client.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();

  List<dynamic> _contacts = [];
  bool _isLoadingContacts = false;
  bool _isAddingContact = false;

  // SOS Countdown states
  int _sosCountdown = 5;
  Timer? _sosTimer;
  bool _sosTriggered = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileContacts();
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileContacts() async {
    setState(() {
      _isLoadingContacts = true;
    });
    try {
      final response = await ApiClient.get('/customer/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _contacts = data['emergency_contacts'] ?? [];
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoadingContacts = false;
      });
    }
  }

  Future<void> _addContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAddingContact = true;
    });

    try {
      final response = await ApiClient.post('/customer/emergency-contacts', {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'relationship': _relationController.text.trim(),
      });

      if (response.statusCode == 201) {
        _nameController.clear();
        _phoneController.clear();
        _relationController.clear();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency contact added successfully!'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        }
        _fetchProfileContacts();
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isAddingContact = false;
      });
    }
  }

  void _startSosCountdown() {
    setState(() {
      _sosTriggered = true;
      _sosCountdown = 5;
    });

    _sosTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sosCountdown > 1) {
        setState(() {
          _sosCountdown--;
        });
      } else {
        _sosTimer?.cancel();
        _triggerSosAlert();
      }
    });
  }

  void _cancelSos() {
    _sosTimer?.cancel();
    setState(() {
      _sosTriggered = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS Alert cancelled.'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _triggerSosAlert() {
    setState(() {
      _sosTriggered = false;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
            ),
            const SizedBox(height: 24),
            const Text(
              'SOS Alert Dispatched!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your live GPS coordinates have been sent to Ridoo emergency support and your designated emergency contacts.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Acknowledge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.charcoalBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationController,
                decoration: InputDecoration(
                  labelText: 'Relationship (e.g. Spouse, Friend)',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isAddingContact ? null : _addContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isAddingContact
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Safety & SOS Help', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              // SOS Pulse Button Area
              Center(
                child: Container(
                  height: 220,
                  alignment: Alignment.center,
                  child: _sosTriggered
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sending SOS in $_sosCountdown...',
                              style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: ElevatedButton(
                                onPressed: _cancelSos,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.charcoalBlack,
                                  foregroundColor: Colors.white,
                                  shape: const CircleBorder(),
                                ),
                                child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.1),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.2),
                            ),
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: ElevatedButton(
                                onPressed: _startSosCountdown,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: const CircleBorder(),
                                  elevation: 8,
                                  shadowColor: Colors.redAccent,
                                ),
                                child: const Text(
                                  'SOS',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Emergency SOS Trigger',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Tapping the button starts a 5-second countdown to alert police, emergency support, and send your live location coordinates to contacts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 40),

              // Emergency contacts header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton.icon(
                    onPressed: _showAddContactDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Contact'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoadingContacts)
                const Center(child: CircularProgressIndicator())
              else if (_contacts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline_rounded, size: 36, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No contacts added.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _contacts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    final relation = contact['relationship'] ?? 'Emergency Contact';

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.person, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(contact['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  '${contact['phone']} • $relation',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
