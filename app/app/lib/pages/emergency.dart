import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/report_card.dart';
import '../widgets/hotlines.dart';
import 'distress_report.dart';
import 'signin.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  /// Handles routing based on authentication status
  void _handleCardTap(BuildContext context, String category) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DistressReportPage(
            selectedCategory: category,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to submit an emergency report.'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInPage(),
        ),
      );
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'CDRRMO':
        return Icons.tsunami;
      case 'EMS':
        return Icons.medical_services_rounded;
      case 'POSO':
        return Icons.local_police;
      case 'BFP':
        return Icons.fire_truck;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'resolved':
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'in progress':
      case 'responding':
        return const Color(0xFFE65100);
      case 'closed':
      case 'withdrawn':
        return const Color(0xFF757575);
      case 'pending':
      default:
        return const Color(0xFFC62828);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFC8532B);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // --- SLIDE TO CALL BUTTON ---
                    SlideAction(
                      text: 'SLIDE TO CALL FOR HELP',
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                      outerColor: brandOrange,
                      innerColor: Colors.white,
                      sliderButtonIcon: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF2B1D19),
                        size: 20,
                      ),
                      height: 60,
                      sliderButtonYOffset: 0,
                      onSubmit: () async {
                        final Uri emergencyUri = Uri(scheme: 'tel', path: '911');
                        if (await canLaunchUrl(emergencyUri)) {
                          await launchUrl(emergencyUri);
                        } else {
                          debugPrint('Could not launch emergency call to 911.');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- SECTION TITLE: RESPONSE TEAMS ---
                    _buildSectionHeader(
                      title: 'RESPONSE TEAMS',
                      onViewAllTap: () {},
                    ),

                    const SizedBox(height: 12),

                    // --- RESPONSE TEAMS 2x2 GRID ---
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                      children: [
                        _buildTeamGridCard(
                          context: context,
                          title: 'CDRRMO',
                          subtitle: 'Disaster Response',
                          icon: Icons.tsunami,
                          category: 'CDRRMO',
                        ),
                        _buildTeamGridCard(
                          context: context,
                          title: 'EMS & Rescue',
                          subtitle: 'Medical Assistance',
                          icon: Icons.medical_services,
                          category: 'EMS',
                        ),
                        _buildTeamGridCard(
                          context: context,
                          title: 'POSO',
                          subtitle: 'Public Order & Safety',
                          icon: Icons.shield,
                          category: 'POSO',
                        ),
                        _buildTeamGridCard(
                          context: context,
                          title: 'BFP',
                          subtitle: 'Fire & Rescue',
                          icon: Icons.fire_truck,
                          category: 'BFP',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // --- NEED IMMEDIATE HELP CARD ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBECE6).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Need Immediate Help?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: brandOrange,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'If you or someone you know is in crisis, reach out to these hotlines.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8C7B73),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              EmergencyHotlinesDialog.show(context);
                            },
                            icon: const Icon(Icons.phone, size: 16, color: brandOrange),
                            label: const Text(
                              'View Hotlines',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: brandOrange,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: brandOrange),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- SECTION TITLE: RECENT REPORTS ---
                    _buildSectionHeader(
                      title: 'RECENT REPORTS',
                      onViewAllTap: () {},
                    ),

                    const SizedBox(height: 12),

                    // --- RECENT REPORTS LIST (FIRESTORE STREAM) ---
                    if (currentUser != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reports')
                            .where('userId', isEqualTo: currentUser.uid)
                            .where('reportType', isEqualTo: 'emergency')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: CircularProgressIndicator(color: brandOrange),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                'No recent reports filed.',
                                style: TextStyle(color: Color(0xFF8C7B73), fontSize: 13),
                              ),
                            );
                          }

                          final docs = snapshot.data!.docs.toList();

                          // Sort in memory by createdAt descending
                          docs.sort((a, b) {
                            final aData = a.data() as Map<String, dynamic>;
                            final bData = b.data() as Map<String, dynamic>;
                            final aTime = aData['updatedAt'] as Timestamp?;
                            final bTime = bData['updatedAt'] as Timestamp?;
                            if (aTime == null || bTime == null) return 0;
                            return bTime.compareTo(aTime);
                          });

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final reportData = doc.data() as Map<String, dynamic>;

                              final category = reportData['category'] ?? 'Emergency';
                              final caseId = reportData['caseNumber'] ?? doc.id.substring(0, 6).toUpperCase();
                              final status = reportData['status'] ?? 'Pending';

                              return ReportCard(
                                reportId: doc.id,
                                icon: _getCategoryIcon(category.toString()),
                                iconColor: brandOrange,
                                title: '$category',
                                caseNumber: 'CASE #$caseId',
                                status: status.toString(),
                                statusColor: _getStatusColor(status.toString()),
                                barangay: reportData['barangay'] as String?,
                                locationType: reportData['locationType'] as String?,
                                landmarkDetails: reportData['landmarkDetails'] as String?,
                                coordinates: reportData['coordinates'] as GeoPoint?,
                                natureOfReport: (reportData['natureOfDistress'] ?? reportData['natureOfConcern']) as String?,
                                createdAt: reportData['createdAt'] as Timestamp?,
                              );
                            },
                          );
                        },
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Sign in to view your recent report status.',
                          style: TextStyle(color: Color(0xFF8C7B73), fontSize: 13),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Header with Line & "View all"
  Widget _buildSectionHeader({required String title, required VoidCallback onViewAllTap}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Color(0xFF8C7B73),
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

  /// Grid Card Widget for Response Teams
  Widget _buildTeamGridCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String category,
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
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleCardTap(context, category),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBECE6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: const Color(0xFFC8532B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1D19),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8C7B73),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Color(0xFFC8532B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}