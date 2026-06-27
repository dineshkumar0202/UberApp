import 'package:flutter/material.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  final List<Map<String, dynamic>> _reviews = const [
    {
      'name': 'Amit Kumar',
      'rating': 5,
      'date': '2026-06-27',
      'comment': 'Polite driver, clean vehicle, and drove very safely. Highly recommended!'
    },
    {
      'name': 'Priya S.',
      'rating': 5,
      'date': '2026-06-26',
      'comment': 'Arrived on time and helped me load my heavy luggage. Thank you!'
    },
    {
      'name': 'Rajesh Patel',
      'rating': 4,
      'date': '2026-06-25',
      'comment': 'Good trip, took the fastest route to avoid traffic.'
    },
    {
      'name': 'Sneha Sharma',
      'rating': 5,
      'date': '2026-06-24',
      'comment': 'Excellent behavior. The ride was very comfortable.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ratings & Reviews', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating overview card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Rating',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            '4.95',
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ 5',
                            style: TextStyle(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Stats column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatColumn('Acceptance Rate', '96%'),
                      const SizedBox(height: 12),
                      _buildStatColumn('Completion Rate', '99%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            const Text(
              'Customer Comments',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = _reviews[index];
                final rating = review['rating'] as int;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            review['date'],
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star_rounded,
                            color: i < rating ? Colors.amber : Colors.grey[200],
                            size: 16,
                          ),
                        ),
                      ),
                      if (review['comment'] != null && review['comment'].isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          review['comment'],
                          style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6C4DFF)),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
