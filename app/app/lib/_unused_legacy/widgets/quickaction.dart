import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color1;
  final Color color2;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color1 = const Color(0xFFF3E4CF),
    this.color2 = const Color(0xFF9C5F32),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: const Color(0xFF333333)),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB8321B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}