import 'package:flutter/material.dart';
import 'concern_report.dart';
import '../widgets/card.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
  const Color color1 = Color(0xFFFBEBC9);
  const Color color2 = Color(0xFFE4B559);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            const Text(
              'COMMUNITY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF7A4423),
              ),
            ),
            
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE4B559),
                  minimumSize: const Size(double.infinity, 60),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConcernReportPage(
                        // selectedCategory: 'Noise',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'File a Community Concern',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'CONCERN CATEGORIES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Color(0xFF8C7B73),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    CustomCard(
                      title: 'Noise Complaint',
                      subtitle: 'Routed to Barangay Office',
                      themeColor: color1,
                      icon: const Icon(Icons.volume_up, color: color2, size: 26),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConcernReportPage(
                              selectedCategory: 'Noise',
                            ),
                          ),
                        );
                      },
                    ),

                    CustomCard(
                      title: 'Disorder / Peace Concern',
                      subtitle: 'Routed to Barangay Police',
                      themeColor: color1,
                      icon: const Icon(Icons.gavel, color: color2, size: 26),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConcernReportPage(
                              selectedCategory: 'Disorder',
                            ),
                          ),
                        );
                      },
                    ),

                    CustomCard(
                      title: 'Waste, Waterways & Roads',
                      subtitle: 'Unattended waste, clogged, sewers, broken roads',
                      themeColor: color1,
                      icon: const Icon(Icons.construction, color: color2, size: 26),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConcernReportPage(
                              selectedCategory: 'Waste',
                            ),
                          ),
                        );
                      },
                    ),

                    CustomCard(
                      title: 'Illegal Parking / Blocked Road',
                      subtitle: 'Inaccessible roads',
                      themeColor: color1,
                      icon: const Icon(Icons.no_crash, color: color2, size: 26),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConcernReportPage(
                              selectedCategory: 'Parking',
                            ),
                          ),
                        );
                      },
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