import 'package:flutter/material.dart';

class ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color backgroundColor;
  final Color labelColor;
  final Color valueColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const ProfileInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.backgroundColor = Colors.white,
    this.labelColor = const Color(0xFF6E4327), // Soft brownish/tan color from mockup
    this.valueColor = const Color(0xFF4A1A00), // Darker bold brown from mockup
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}