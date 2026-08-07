import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/report_card.dart'; // Adjust import path as needed
import '../pages/signin.dart';
import 'edit_profile.dart';

class ProfilePage extends StatelessWidget {
  final ValueChanged<int> onTabSelected;

  const ProfilePage({
    super.key,
    required this.onTabSelected,
  });

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
    const Color brandPrimary = Color(0xFFC8532B);
    const Color textPrimary = Color(0xFF2B1D19);
    const Color textSecondary = Color(0xFF8C7B73);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            final currentUser = authSnapshot.data;
            final bool isSignedIn = currentUser != null;

            if (!isSignedIn) {
              return _buildLoggedOutView(context);
            }

            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, firestoreSnapshot) {
                final userData = firestoreSnapshot.data?.data() ?? {};

                final String username = userData['fullName'] ??
                    userData['name'] ??
                    currentUser.displayName ??
                    'User';
                final String phone = currentUser.phoneNumber ??
                    userData['phoneNumber'] ??
                    'No phone number';
                final String bloodType = userData['bloodType'] ?? 'Not set';
                final String medicalInfo =
                    userData['medicalInfo'] ?? 'No medical information added';

                // --- Extract Saved Address ---
                String address = 'Not set';
                final dynamic addressData =
                    userData['savedAddress'] ?? userData['address'];
                if (addressData is Map<String, dynamic>) {
                  final street = (addressData['street'] ?? '').toString().trim();
                  final brgy = (addressData['brgy'] ?? addressData['barangay'] ?? '')
                      .toString()
                      .trim();
                  address = '$street ${brgy.isNotEmpty ? ", $brgy" : ""}';
                } else if (addressData is String && addressData.trim().isNotEmpty) {
                  address = addressData.trim();
                }

                // --- Extract Emergency Contact ---
                String emergencyContact = 'Not set';
                final String eName =
                    (userData['emergencyContactName'] ?? '').toString().trim();
                final String eNum = (userData['emergencyContactNumber'] ??
                        userData['emergencyContactPhone'] ??
                        '')
                    .toString()
                    .trim();
                if (eName.isNotEmpty || eNum.isNotEmpty) {
                  emergencyContact = '$eName • $eNum';
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER PROFILE CARD ---
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: brandPrimary,
                                  child: Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        style: const TextStyle(
                                          fontSize: 20, // Standard header title size
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        phone,
                                        style: const TextStyle(
                                          fontSize: 14, // Standard body size
                                          color: textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 16,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Verified',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => FirebaseAuth.instance.signOut(),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Sign Out',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: brandPrimary,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.logout,
                                          size: 18,
                                          color: brandPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- QUICK ACCESS SECTION ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Quick Access',
                            style: TextStyle(
                              fontSize: 18, // Standard section header
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
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
                      Row(
                        children: [
                          _buildQuickAccessCard(
                            icon: Icons.medical_services_outlined,
                            title: 'Emergency',
                            subtitle: 'Get help',
                            onTap: () => onTabSelected(0),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickAccessCard(
                            icon: Icons.people_outline,
                            title: 'Community',
                            subtitle: 'Connect',
                            onTap: () => onTabSelected(1),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickAccessCard(
                            icon: Icons.work_outline,
                            title: 'Healthcare',
                            subtitle: 'Services',
                            onTap: () => onTabSelected(3),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickAccessCard(
                            icon: Icons.menu,
                            title: 'More',
                            subtitle: 'Other',
                            onTap: () => onTabSelected(4),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // --- PERSONAL INFORMATION ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18, // Standard section header
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFEBE3DF),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(userData: userData),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.edit, size: 16, color: brandPrimary),
                                SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: brandPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.location_on_outlined,
                              title: 'Saved Address',
                              value: address,
                            ),
                            const Divider(height: 1, color: Color(0xFFFAF6F2)),
                            _buildInfoRow(
                              icon: Icons.phone_outlined,
                              title: 'Emergency Contact',
                              value: emergencyContact,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- RECENT ACTIVITY SECTION ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18, // Standard section header
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
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

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reports')
                            .where('userId', isEqualTo: currentUser.uid)
                            .limit(3)
                            .snapshots(),
                        builder: (context, activitySnapshot) {
                          if (activitySnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: brandPrimary),
                            );
                          }

                          if (!activitySnapshot.hasData ||
                              activitySnapshot.data!.docs.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'No recent activity',
                                  style: TextStyle(color: textSecondary, fontSize: 14),
                                ),
                              ),
                            );
                          }

                          final docs = activitySnapshot.data!.docs;

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final reportData = doc.data() as Map<String, dynamic>;

                              final category = reportData['category'] ?? 'Emergency';
                              final caseId = reportData['caseNumber'] ??
                                  doc.id.substring(0, 6).toUpperCase();
                              final status = reportData['status'] ?? 'Pending';

                              return ReportCard(
                                reportId: doc.id,
                                icon: _getCategoryIcon(category.toString()),
                                iconColor: brandPrimary,
                                title: '$category',
                                caseNumber: 'CASE #$caseId',
                                status: status.toString(),
                                statusColor: _getStatusColor(status.toString()),
                                barangay: reportData['barangay'] as String?,
                                locationType: reportData['locationType'] as String?,
                                landmarkDetails: reportData['landmarkDetails'] as String?,
                                coordinates: reportData['coordinates'] as GeoPoint?,
                                natureOfReport: (reportData['natureOfDistress'] ??
                                    reportData['natureOfConcern']) as String?,
                                createdAt: reportData['createdAt'] as Timestamp?,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: Color(0xFFC8532B)),
          const SizedBox(height: 12),
          const Text(
            'You are not signed in',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8532B),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
              );
            },
            child: const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFFBECE6),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFC8532B)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8C7B73)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? const Color(0xFF2B1D19),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFC8532B), size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B1D19),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8C7B73)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFBECE6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFC8532B), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1D19),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8C7B73)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}