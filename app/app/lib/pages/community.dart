import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'concern_report.dart';
import '../widgets/report_card.dart';
import 'signin.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  /// Handles routing based on authentication status
  void _handleCategoryTap(BuildContext context, String category) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConcernReportPage(
            selectedCategory: category,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to submit a community concern.'),
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
    switch (category?.toLowerCase()) {
      case 'noise':
        return Icons.volume_up;
      case 'disorder':
        return Icons.gavel;
      case 'infrastructure':
        return Icons.construction;
      case 'waste':
        return Icons.construction;
      case 'parking':
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
    const Color brandYellow = Color(0xFFE4B559);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // --- FILE A CONCERN BUTTON ---
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: brandYellow,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (currentUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConcernReportPage(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInPage(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'FILE A COMMUNITY CONCERN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- SECTION TITLE: CONCERN CATEGORIES ---
                    _buildSectionHeader(
                      title: 'CONCERN CATEGORIES',
                      onViewAllTap: () {},
                    ),

                    const SizedBox(height: 12),

                    // --- CONCERN CATEGORIES 2x2 GRID ---
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                      children: [
                        _buildCategoryGridCard(
                          context: context,
                          title: 'Noise Complaint',
                          subtitle: 'Barangay Office',
                          icon: Icons.volume_up,
                          category: 'Noise',
                        ),
                        _buildCategoryGridCard(
                          context: context,
                          title: 'Disorder / Peace',
                          subtitle: 'Barangay Police',
                          icon: Icons.gavel,
                          category: 'Disorder',
                        ),
                        _buildCategoryGridCard(
                          context: context,
                          title: 'Waste & Waterways',
                          subtitle: 'Roads & Sewers',
                          icon: Icons.construction,
                          category: 'Infrastructure',
                        ),
                        _buildCategoryGridCard(
                          context: context,
                          title: 'Illegal Parking',
                          subtitle: 'Blocked Roads',
                          icon: Icons.no_crash,
                          category: 'Parking',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- SECTION TITLE: REPORT HISTORY ---
                    _buildSectionHeader(
                      title: 'REPORT HISTORY',
                      onViewAllTap: () {},
                    ),

                    const SizedBox(height: 12),

                    // --- REPORT HISTORY LIST (FIRESTORE STREAM) ---
                    if (currentUser != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reports')
                            .where('userId', isEqualTo: currentUser.uid)
                            .where('reportType', isEqualTo: 'community')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: CircularProgressIndicator(color: brandYellow),
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
                                'No community concerns submitted yet.',
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

                              final category = reportData['category'] ?? 'Concern';
                              final caseId = reportData['caseNumber'] ?? doc.id.substring(0, 6).toUpperCase();
                              final status = reportData['status'] ?? 'Pending';

                              return ReportCard(
                                reportId: doc.id,
                                icon: _getCategoryIcon(category.toString()),
                                iconColor: brandYellow,
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
                          'Sign in to view your report history.',
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

  /// Grid Card Widget for Community Categories
  Widget _buildCategoryGridCard({
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
          onTap: () => _handleCategoryTap(context, category),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDF6E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: const Color(0xFFE4B559),
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
                  color: Color(0xFFE4B559),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}