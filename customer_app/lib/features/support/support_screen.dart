import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ridoo_customer/core/theme/colors.dart';
import 'package:ridoo_customer/core/network/api_client.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'booking'; // booking, payment, safety, feedback
  List<dynamic> _activeTickets = [];
  bool _isLoadingTickets = false;
  bool _isSubmitting = false;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I book a Ridoo ride?',
      'a': 'Simply open the Ridoo app, search for your destination in the search bar, select your preferred vehicle tier (Economy, Comfort, Premium, XL), pick a payment method, and tap Confirm!'
    },
    {
      'q': 'What payment methods are supported?',
      'a': 'Ridoo supports in-app digital wallets, Credit/Debit cards via Stripe, UPI & NetBanking via Razorpay, or Cash directly to the driver.'
    },
    {
      'q': 'Are there cancellation fees?',
      'a': 'If you cancel within 5 minutes of driver acceptance, there is no fee. A small convenience fee may apply if cancelled after 5 minutes.'
    },
    {
      'q': 'How does Ridoo ensure passenger safety?',
      'a': 'All Ridoo driver partners undergo criminal record checks and document inspections. We also offer an active in-app Emergency SOS trigger to contact help instantly.'
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
              content: Text('Support ticket raised successfully! Our support team will contact you.'),
              backgroundColor: AppColors.accentGreen,
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
          title: const Text('Support & Help', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'FAQ & Help'),
              Tab(text: 'Support Tickets'),
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
          'Frequently Asked Questions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.charcoalBlack),
        ),
        const SizedBox(height: 16),
        ..._faqs.map((faq) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ExpansionTile(
                iconColor: AppColors.primary,
                title: Text(
                  faq['q']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.charcoalBlack),
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
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Icon(Icons.support_agent_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              const Text('Still need help?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                'Submit an inquiry ticket on the next tab, and we will get back to you immediately.',
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
        // Raise ticket form
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Raise Support Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),

                // Category Selection
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'booking', child: Text('Booking Issues')),
                    DropdownMenuItem(value: 'payment', child: Text('Payment & Wallet')),
                    DropdownMenuItem(value: 'safety', child: Text('Safety Concern')),
                    DropdownMenuItem(value: 'feedback', child: Text('App Feedback')),
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

                // Subject
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    hintText: 'Brief summary of the issue',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter ticket subject' : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Detailed Description',
                    hintText: 'Provide as much details as possible...',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter details' : null,
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
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

        const Text('My Active Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),

        if (_isLoadingTickets)
          const Center(child: CircularProgressIndicator())
        else if (_activeTickets.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Text(
                'No open tickets found.',
                style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
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
                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
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
                        color: isPending ? const Color(0xFFFFC107).withOpacity(0.1) : AppColors.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isPending ? const Color(0xFFFFC107) : AppColors.accentGreen,
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
