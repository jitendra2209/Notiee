import 'package:flutter/material.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Bills Yet...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your bills will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
