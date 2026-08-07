import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/card.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color cardBackgroundColor = Color(0xFFF7D8B8);
    const Color iconColor = Color(0xFFC97A45);

    return SizedBox(
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
                    _buildSectionHeader('EDUCATION & TRAINING'),

                    // 1. e-TESDA Online Programs
                    CustomCard(
                      title: 'e-TESDA Portal',
                      subtitle: 'Access free online technical & vocational courses',
                      themeColor: cardBackgroundColor,
                      icon: const Icon(Icons.computer, color: iconColor, size: 26),
                      onTap: () async {
                        final Uri url = Uri.parse('https://e-tesda.gov.ph/');
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                    ),

                    // 2. City Educational Assistance Program (CEAP)
                    CustomCard(
                      title: 'CEAP Scholarship',
                      subtitle: 'Santa Rosa City educational assistance & scholar portal',
                      themeColor: cardBackgroundColor,
                      icon: const Icon(Icons.school, color: iconColor, size: 26),
                      onTap: () async {
                        final Uri url = Uri.parse('http://ceap.santarosacity.gov.ph');
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                    ),

                    // 3. TESDA Laguna Accredited Centers
                    CustomCard(
                      title: 'TESDA Laguna Centers',
                      subtitle: 'List of accredited schools & training centers in Laguna',
                      themeColor: cardBackgroundColor,
                      icon: const Icon(Icons.location_city, color: iconColor, size: 26),
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://tesdatrainingcourses.com/tesda-accredited-schools-and-training-centers-in-laguna.html',
                        );
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                    ),

                    // 4. Santa Rosa Manpower Training Center Courses
                    CustomCard(
                      title: 'Santa Rosa TESDA Courses',
                      subtitle: 'Explore skills training at Santa Rosa Manpower Center',
                      themeColor: cardBackgroundColor,
                      icon: const Icon(Icons.build_circle_outlined, color: iconColor, size: 26),
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://tesdatrainingcourses.com/santa-rosa-manpower-training-center.html',
                        );
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                    ),

                    _buildSectionHeader('LEGAL ASSISTANCE'),

                    CustomCard(
                      title: 'City Legal Office',
                      subtitle: 'Notary, legal advice, dispute resolution',
                      themeColor: cardBackgroundColor,
                      icon: const Icon(Icons.gavel, color: iconColor, size: 26),
                      onTap: () => _showComingSoon(context),
                    ),

                    _buildSectionHeader('PERMITS & REGULATION'),

                    CustomCard(
                      title: 'Business Permits & Licensing',
                      subtitle: 'Application and renewal of business permits',
                      themeColor: cardBackgroundColor,
                      icon: const Icon(Icons.store, color: iconColor, size: 26),
                      onTap: () => _showComingSoon(context),
                    ),

                    CustomCard(
                      title: 'Building & Construction Permits',
                      subtitle: 'Application and renewal of building permits',
                      themeColor: cardBackgroundColor,
                      icon: const Icon(Icons.engineering, color: iconColor, size: 26),
                      onTap: () => _showComingSoon(context),
                    ),

                    CustomCard(
                      title: 'Sanitation & Health Permits',
                      subtitle: 'Application and renewal of sanitation and health permits',
                      themeColor: cardBackgroundColor,
                      icon: const Icon(Icons.local_hospital, color: iconColor, size: 26),
                      onTap: () => _showComingSoon(context),
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

  /// Shows a "Coming soon" snackbar for services that aren't wired up yet.
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Section title with a trailing divider line, used to group service cards.
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8C7B73),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFEBE3DF),
          ),
        ),
      ],
    );
  }
}
