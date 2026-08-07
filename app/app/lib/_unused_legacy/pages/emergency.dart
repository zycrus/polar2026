import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/card.dart';
import '../widgets/report_card.dart';
import 'distress_report.dart';
import 'signin.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

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
      case 'pending':
      default:
        return const Color(0xFFC62828);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color color1 = Color(0xFFFBEBC9);
    const Color color2 = Color(0xFFCF5B3B);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'EMERGENCY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFFB84A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SlideAction(
                        text: 'Slide to Call for Help',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        outerColor: color2,
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
                          }
                          return null;
                        },
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 36.0, right: 36.0, top: 16.0, bottom: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'RESPONSE TEAMS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Color(0xFF8C7B73),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          CustomCard(
                            title: 'CDRRMO — Disaster\nResponse',
                            subtitle: 'Evacuation, rescue, stranded citizens',
                            themeColor: color1,
                            icon: const Icon(Icons.tsunami, color: color2, size: 26),
                            onTap: () => _handleCardTap(context, 'CDRRMO'),
                          ),
                          CustomCard(
                            title: 'EMS & Rescue',
                            subtitle: 'Accidents, medical attention, abuse/violence',
                            themeColor: color1,
                            icon: const Icon(Icons.medical_services_rounded, color: color2, size: 26),
                            onTap: () => _handleCardTap(context, 'EMS'),
                          ),
                          CustomCard(
                            title: 'POSO — Public Order &\nSafety',
                            subtitle: 'Larger-scale distress, PNP coordination',
                            themeColor: color1,
                            icon: const Icon(Icons.local_police, color: color2, size: 26),
                            onTap: () => _handleCardTap(context, 'POSO'),
                          ),
                          CustomCard(
                            title: 'BFP — Fire & Rescue',
                            subtitle: 'Fire hazards, rescue emergencies',
                            themeColor: color1,
                            icon: const Icon(Icons.fire_truck, color: color2, size: 26),
                            onTap: () => _handleCardTap(context, 'BFP'),
                          ),
                        ],
                      ),
                    ),

                    // --- REPORTS HISTORY ---
                    if (currentUser != null) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 36.0, right: 36.0, top: 20.0, bottom: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'REPORT HISTORY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Color(0xFF8C7B73),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('reports')
                              .where('userId', isEqualTo: currentUser.uid)
                              .where('reportType', isEqualTo: 'emergency')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(color: color2),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Error loading reports: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text(
                                  'No distress reports submitted yet.',
                                  style: TextStyle(color: Color(0xFF8C7B73), fontSize: 13),
                                ),
                              );
                            }

                            final docs = snapshot.data!.docs;

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: docs.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final data = docs[index].data() as Map<String, dynamic>;

                                final category = data['category'] ?? 'Emergency';
                                final caseId = data['caseNumber'] ?? docs[index].id.substring(0, 6).toUpperCase();
                                final status = data['status'] ?? 'Pending';

                                return ReportCard(
                                icon: _getCategoryIcon(category),
                                iconColor: color2,
                                title: '$category Emergency',
                                caseNumber: 'CASE #$caseId',
                                status: status,
                                statusColor: _getStatusColor(status),

                                // Pass these extra Firestore document fields for the expansion drawer:
                                barangay: data['barangay'],
                                locationType: data['locationType'],
                                landmarkDetails: data['landmarkDetails'],
                                coordinates: data['coordinates'] as GeoPoint?,
                                natureOfReport: data['natureOfDistress'] ?? data['natureOfConcern'],
                                createdAt: data['createdAt'] as Timestamp?,
                              );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
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