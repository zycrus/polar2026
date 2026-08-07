import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final bool isMultiLine;
  final Color color1;
  final Color color2;

  const InfoTile({
    super.key,
    required this.title,
    required this.value,
    this.color1 = const Color(0xFFF3E4CF),
    this.color2 = const Color(0xFFB8321B),
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8321B),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8321B),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}