import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'make_appointment.dart';

class HealthcarePage extends StatelessWidget {
  const HealthcarePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFFC8532B);
    const Color textSecondary = Color(0xFF8C7B73);
    const Color circleBg = Color(0xFFFBECE6);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: MEDICAL SERVICES ---
              Row(
                children: [
                  const Text(
                  'MEDICAL SERVICES',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
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
              ),
              const SizedBox(height: 12),

              // 1. e-Konsulta
              _buildServiceCard(
                icon: Icons.medical_services_outlined,
                circleBg: circleBg,
                iconColor: brandPrimary,
                title: 'e-Konsulta',
                subtitle: 'Remote medical consultation with licensed healthcare professionals',
                badge: _buildBadge(
                  icon: Icons.circle,
                  iconSize: 8,
                  iconColor: Colors.green,
                  label: 'Available 24/7',
                  bgColor: Colors.green.withOpacity(0.1),
                  textColor: Colors.green.shade800,
                ),
                onTap: () async {
                  final Uri url = Uri.parse('https://www.ekonsultaclinic.ph/');
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                },
              ),
              const SizedBox(height: 12),

              // 2. Barangay Health Center
              _buildServiceCard(
                icon: Icons.add_box,
                circleBg: circleBg,
                iconColor: brandPrimary,
                title: 'Barangay Health Center',
                subtitle: 'Book a checkup appointment at your barangay health center',
                badge: _buildBadge(
                  icon: Icons.access_time,
                  iconSize: 12,
                  iconColor: brandPrimary,
                  label: 'Mon - Fri • 8:00 AM - 4:00 PM',
                  bgColor: const Color(0xFFFBECE6),
                  textColor: brandPrimary,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckupAppointmentPage(
                        facilityName: 'Barangay Health Center',
                        facilityAddress: 'Brgy. Tagapo Health Center, Santa Rosa, Laguna',
                        facilityIcon: Icons.add_box,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // 3. Santa Rosa City Hospital
              _buildServiceCard(
                icon: Icons.apartment,
                circleBg: circleBg,
                iconColor: brandPrimary,
                title: 'Santa Rosa City Hospital',
                subtitle: 'Book a checkup appointment at Santa Rosa City Hospital',
                badge: _buildBadge(
                  icon: Icons.access_time,
                  iconSize: 12,
                  iconColor: brandPrimary,
                  label: 'Mon - Fri • 8:00 AM - 4:00 PM',
                  bgColor: const Color(0xFFFBECE6),
                  textColor: brandPrimary,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckupAppointmentPage(
                        facilityName: 'Santa Rosa City Hospital',
                        facilityAddress: 'Tagapo, Brgy. Tagapo, Santa Rosa, Laguna 4026',
                        facilityIcon: Icons.apartment,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // --- SECTION 2: MENTAL HEALTH ---
              Row(
                children: [
                  const Text(
                  'MENTAL HEALTH',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
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
              ),
              const SizedBox(height: 12),

              _buildServiceCard(
                icon: Icons.psychology,
                circleBg: circleBg,
                iconColor: brandPrimary,
                title: 'Mental Health Services',
                subtitle: 'Access mental health support, counseling, and resources',
                badge: _buildBadge(
                  icon: Icons.verified_user_outlined,
                  iconSize: 12,
                  iconColor: Colors.green,
                  label: 'Confidential & Safe',
                  bgColor: Colors.green.withOpacity(0.1),
                  textColor: Colors.green.shade800,
                ),
                onTap: () async {
                  final Uri url = Uri.parse('https://app.recoveryhub.ph/');
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildServiceCard({
    required IconData icon,
    required Color circleBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget badge,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: circleBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
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
                          color: Color(0xFF2B1D19),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8C7B73),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      badge,
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF8C7B73),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required double iconSize,
    required Color iconColor,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}