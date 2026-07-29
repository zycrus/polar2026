import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String caseNumber;
  final String status;
  final Color statusColor;

  const ReportCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.caseNumber,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF532813),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caseNumber,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A6753),
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}