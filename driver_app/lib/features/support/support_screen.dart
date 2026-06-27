import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ridoo_driver/core/network/api_client.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'payout'; // payout, passenger, app, safety
  List<dynamic> _activeTickets = [];
  bool _isLoadingTickets = false;
  bool _isSubmitting = false;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How are driver payouts calculated?',
      'a': 'Payouts include completed trip fares minus Ridoo\'s 15% commission fee, plus active weekend incentives. Tips from passengers are 100% credited to the driver.'
    },
    {
      'q': 'When do I receive withdrawn funds?',
      'a': 'UPI withdrawals are processed instantly. Bank transfers are typically processed within 24 hours depending on bank business hours.'
    },
    {
      'q': 'What should I do in an emergency?',
      'a': 'If you feel unsafe or have an accident, tap the emergency helpline contact inside the support center or call the direct support line immediately.'
    },
    {
      'q': 'Can I reject ride requests?',
      'a': 'Yes, you can accept or decline any ride request. However, keeping a high acceptance rate (above 80%) qualifies you for weekly performance incentives.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoadingTickets = true;
    });
    try {
      final response = await ApiClient.get('/support/tickets');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _activeTickets = data;
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoadingTickets = false;
      });
    }
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await ApiClient.post('/support/tickets', {
        'subject': _subjectController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
      });

      if (response.statusCode == 201) {
        _subjectController.clear();
        _descriptionController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Support ticket raised successfully! Our team will contact you shortly.'),
              backgroundColor: Color(0xFF25A365),
            ),
          );
        }
        _fetchTickets();
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Partner Support', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF6C4DFF),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF6C4DFF),
            tabs: [
              Tab(text: 'Partner FAQ'),
              Tab(text: 'Tickets'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFaqTab(),
            _buildTicketsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTab() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text(
          'Partner Frequently Asked Questions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._faqs.map((faq) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
                ],
              ),
              child: ExpansionTile(
                iconColor: const Color(0xFF6C4DFF),
                title: Text(
                  faq['q']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(
                      faq['a']!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF6C4DFF).withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6C4DFF).withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Icon(Icons.headset_mic_rounded, size: 48, color: Color(0xFF6C4DFF)),
              const SizedBox(height: 12),
              const Text('Direct Helpline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                'Need immediate assistance? Call +91 1800-RIDOO-HELP to speak directly with driver partner operations.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsTab() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Raise Partner Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Ticket Category',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'payout', child: Text('Payout & Settlement')),
                    DropdownMenuItem(value: 'passenger', child: Text('Passenger Conduct')),
                    DropdownMenuItem(value: 'app', child: Text('Driver App Bug')),
                    DropdownMenuItem(value: 'safety', child: Text('Safety / Accident')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter subject' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Details',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C4DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Submit Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        const Text('Active Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),

        if (_isLoadingTickets)
          const Center(child: CircularProgressIndicator())
        else if (_activeTickets.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Center(
              child: Text(
                'No open tickets found.',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activeTickets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ticket = _activeTickets[index];
              final status = (ticket['status'] ?? 'pending').toString().toUpperCase();
              final isPending = status == 'PENDING' || status == 'OPEN';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ticket['subject'] ?? 'Support Request', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            ticket['description'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending ? const Color(0xFFFFC107).withOpacity(0.1) : const Color(0xFF25A365).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isPending ? const Color(0xFFFFC107) : const Color(0xFF25A365),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
