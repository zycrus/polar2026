import 'package:flutter/material.dart';
import '../widgets/card.dart';

class HealthcarePage extends StatelessWidget {
  const HealthcarePage({super.key});

  @override
  Widget build(BuildContext context) {
  const Color color1 = Color(0xFFF6D3D3);
  const Color color2 = Color(0xFFD97A6E);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            const Text(
              'HEALTHCARE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF7A4423),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    CustomCard(
                      title: 'e-Konsulta',
                      subtitle: 'Remote medical consultation with healthcare professionals',
                      themeColor: color1,
                      icon: const Icon(Icons.volume_up, color: color2, size: 26),
                      onTap: () {},
                    ),
                    CustomCard(
                      title: 'Barangay Health Center',
                      subtitle: 'Book a checkup appointment',
                      themeColor: color1,
                      icon: const Icon(Icons.volume_up, color: color2, size: 26),
                      onTap: () {},
                    ),
                    CustomCard(
                      title: 'Santa Rosa City Hospital',
                      subtitle: 'Book a checkup appointment',
                      themeColor: color1,
                      icon: const Icon(Icons.volume_up, color: color2, size: 26),
                      onTap: () {},
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'MENTAL HEALTH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Color(0xFF8C7B73),
                          ),
                        ),
                      ),
                    ),
                    CustomCard(
                      title: 'Mental Health Services',
                      subtitle: 'Access mental health support and resources',
                      themeColor: color1,
                      icon: const Icon(Icons.volume_up, color: color2, size: 26),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}