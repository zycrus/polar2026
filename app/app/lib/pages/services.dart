import 'package:flutter/material.dart';
import '../widgets/card.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
  const Color color1 = Color(0xFFF7D8B8);
  const Color color2 = Color(0xFFC97A45);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            const Text(
              'SERVICES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF7A4423),
              ),
            ),

            const SizedBox(height: 2),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'EDUCATION & TRAINING',
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
                      title: 'Schools & Open Enrollment',
                      subtitle: 'Public Schools and Tech-Voc Centers',
                      themeColor: color1,
                      icon: const Icon(Icons.volume_up, color: color2, size: 26),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const ConcernReportPage(
                        //       selectedCategory: 'Noise',
                        //     ),
                        //   ),
                        // );
                      },
                    ),

                    CustomCard(
                      title: 'Scholarships',
                      subtitle: 'Available educational assistance programs',
                      themeColor: color1,
                      icon: const Icon(Icons.gavel, color: color2, size: 26),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const ConcernReportPage(
                        //       selectedCategory: 'Disorder',
                        //     ),
                        //   ),
                        // );
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'LEGAL ASSISTANCE',
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
                      title: 'City Legal Office',
                      subtitle: 'Notary, legal advice, dispute resolution',
                      themeColor: color1,
                      icon: const Icon(Icons.construction, color: color2, size: 26),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const ConcernReportPage(
                        //       selectedCategory: 'Waste',
                        //     ),
                        //   ),
                        // );
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'PERMITS & REGULATION',
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
                      title: 'Business Permits & Licensing',
                      subtitle: 'Application and renewal of business permits',
                      themeColor: color1,
                      icon: const Icon(Icons.no_crash, color: color2, size: 26),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const ConcernReportPage(
                        //       selectedCategory: 'Parking',
                        //     ),
                        //   ),
                        // );
                      },
                    ),

                    CustomCard(
                      title: 'Building & Construction Permits',
                      subtitle: 'Application and renewal of building permits',
                      themeColor: color1,
                      icon: const Icon(Icons.no_crash, color: color2, size: 26),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const ConcernReportPage(
                        //       selectedCategory: 'Parking',
                        //     ),
                        //   ),
                        // );
                      },
                    ),

                    CustomCard(
                      title: 'Sanitation & Health Permits',
                      subtitle: 'Application and renewal of sanitation and health permits',
                      themeColor: color1,
                      icon: const Icon(Icons.no_crash, color: color2, size: 26),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const ConcernReportPage(
                        //       selectedCategory: 'Parking',
                        //     ),
                        //   ),
                        // );
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