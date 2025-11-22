import 'package:flutter/material.dart';
import '../models/scan_result.dart';

class StatusCard extends StatelessWidget {
  final SecurityStatus status;

  const StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text;
    String description;

    switch (status) {
      case SecurityStatus.safe:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        text = 'Safe';
        description = 'This URL appears to be safe to visit.';
        break;
      case SecurityStatus.suspicious:
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        text = 'Suspicious';
        description = 'Proceed with caution. This URL has some risk factors.';
        break;
      case SecurityStatus.dangerous:
        color = Colors.red;
        icon = Icons.dangerous_outlined;
        text = 'Dangerous';
        description = 'Do not visit this URL. High risk of phishing or malware.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 80, color: color),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
