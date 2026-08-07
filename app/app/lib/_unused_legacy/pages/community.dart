import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'concern_report.dart';
import '../widgets/card.dart';
import '../widgets/report_card.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Noise':
        return Icons.volume_up;
      case 'Disorder':
        return Icons.gavel;
      case 'Infrastructure':
      case 'Waste':
        return Icons.construction;
      case 'Parking':
        return Icons.no_crash;
      default:
        return Icons.report_problem_rounded;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'resolved':
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'in progress':
      case 'investigating':
        return const Color(0xFFE65100);
      case 'pending':
      default:
        return const Color(0xFFC62828);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color color1 = Color(0xFFFBEBC9);
    const Color color2 = Color(0xFFE4B559);
    final currentUser = FirebaseAuth.instance.currentUser;

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
                      builder: (context) => const ConcernReportPage(),
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12.0, top: 16.0, bottom: 8.0),
                      child: Text(
                        'CONCERN CATEGORIES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Color(0xFF8C7B73),
                        ),
                      ),
                    ),

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
                      subtitle: 'Unattended waste, clogged sewers, broken roads',
                      themeColor: color1,
                      icon: const Icon(Icons.construction, color: color2, size: 26),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConcernReportPage(
                              selectedCategory: 'Infrastructure',
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

                    // --- REPORT HISTORY ---
                    if (currentUser != null) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0, top: 20.0, bottom: 8.0),
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

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reports')
                            .where('userId', isEqualTo: currentUser.uid)
                            .where('reportType', isEqualTo: 'community')
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
                              child: Center(
                                child: Text(
                                  'No community concerns submitted yet.',
                                  style: TextStyle(color: Color(0xFF8C7B73), fontSize: 13),
                                ),
                              ),
                            );
                          }

                          final docs = snapshot.data!.docs.toList();

                          // Sort in memory by createdAt descending
                          docs.sort((a, b) {
                            final aData = a.data() as Map<String, dynamic>;
                            final bData = b.data() as Map<String, dynamic>;
                            final aTime = aData['createdAt'] as Timestamp?;
                            final bTime = bData['createdAt'] as Timestamp?;
                            if (aTime == null || bTime == null) return 0;
                            return bTime.compareTo(aTime);
                          });

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;

                              final category = data['category'] ?? 'Concern';
                              final caseId = data['caseNumber'] ?? docs[index].id.substring(0, 6).toUpperCase();
                              final status = data['status'] ?? 'Pending';

                              return ReportCard(
                                icon: _getCategoryIcon(category),
                                iconColor: color2,
                                title: '$category Community',
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