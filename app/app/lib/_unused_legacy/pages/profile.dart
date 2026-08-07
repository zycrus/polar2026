import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/quickaction.dart';
import '../widgets/info_tile.dart';
import '../pages/signin.dart';
import 'edit_profile.dart'; // Import Edit Profile Page

class ProfilePage extends StatelessWidget {
  final ValueChanged<int> onTabSelected;

  const ProfilePage({
    super.key,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            final currentUser = authSnapshot.data;
            final bool isSignedIn = currentUser != null;

            if (!isSignedIn) {
              return _buildProfileContent(
                context: context,
                isSignedIn: false,
                username: 'Guest User',
                subtitle: 'Tap to sign in',
                address: '*******',
                emergencyContact: '*******\n*******',
                userData: {},
              );
            }

            // Stream user document from Firestore
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

                // --- Extract Saved Address ---
                String address = 'Not set';
                String street = '';
                String brgy = '';

                final dynamic addressData = userData['savedAddress'] ?? userData['address'];

                if (addressData is Map<String, dynamic>) {
                  street = (addressData['street'] ?? '').toString().trim();
                  brgy = (addressData['brgy'] ?? addressData['barangay'] ?? '').toString().trim();
                } else if (addressData is String && addressData.trim().isNotEmpty) {
                  address = addressData.trim();
                }

                if (street.isEmpty && brgy.isEmpty && address == 'Not set') {
                  street = (userData['street'] ?? '').toString().trim();
                  brgy = (userData['brgy'] ?? userData['barangay'] ?? '').toString().trim();
                }

                if (street.isNotEmpty || brgy.isNotEmpty) {
                  if (street.isNotEmpty && brgy.isNotEmpty) {
                    address = '$street, $brgy';
                  } else {
                    address = street.isNotEmpty ? street : brgy;
                  }
                }

                // --- Extract Emergency Contact ---
                String emergencyContact = 'Not set';
                final String eName = (userData['emergencyContactName'] ?? '').toString().trim();
                final String eNum = (userData['emergencyContactNumber'] ?? userData['emergencyContactPhone'] ?? '').toString().trim();

                if (eName.isNotEmpty || eNum.isNotEmpty) {
                  if (eName.isNotEmpty && eNum.isNotEmpty) {
                    emergencyContact = '$eName\n$eNum';
                  } else {
                    emergencyContact = eName.isNotEmpty ? eName : eNum;
                  }
                } else {
                  final dynamic eData = userData['emergencyContact'] ?? userData['emergency_contact'];
                  if (eData is Map<String, dynamic>) {
                    final name = (eData['name'] ?? eData['fullName'] ?? '').toString().trim();
                    final phone = (eData['number'] ?? eData['phone'] ?? eData['phoneNumber'] ?? '').toString().trim();
                    if (name.isNotEmpty && phone.isNotEmpty) {
                      emergencyContact = '$name\n$phone';
                    } else if (name.isNotEmpty || phone.isNotEmpty) {
                      emergencyContact = name.isNotEmpty ? name : phone;
                    }
                  } else if (eData is String && eData.trim().isNotEmpty) {
                    emergencyContact = eData.trim();
                  }
                }

                return _buildProfileContent(
                  context: context,
                  isSignedIn: true,
                  username: username,
                  subtitle: currentUser.phoneNumber ?? userData['phoneNumber'] ?? currentUser.email ?? 'Logged In',
                  address: address,
                  emergencyContact: emergencyContact,
                  userData: userData,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent({
    required BuildContext context,
    required bool isSignedIn,
    required String username,
    required String subtitle,
    required String address,
    required String emergencyContact,
    required Map<String, dynamic> userData,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                if (isSignedIn) {
                  await FirebaseAuth.instance.signOut();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInPage(),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFC97A45).withAlpha(50),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF532813),
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A6753),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSignedIn ? 'Sign Out' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC97A45),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Icon(
                          isSignedIn ? Icons.logout : Icons.login,
                          size: 18,
                          color: const Color(0xFFC97A45),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuickActionButton(
                icon: Icons.emergency,
                label: 'Emergency',
                onTap: () => onTabSelected(0),
              ),
              QuickActionButton(
                icon: Icons.people,
                label: 'Community',
                onTap: () => onTabSelected(1),
              ),
              QuickActionButton(
                icon: Icons.medical_services,
                label: 'Healthcare',
                onTap: () => onTabSelected(3),
              ),
              QuickActionButton(
                icon: Icons.menu,
                label: 'Other',
                onTap: () => onTabSelected(4),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Details Header with Edit Button
          if (isSignedIn) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF532813),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(userData: userData),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16, color: Color(0xFFC97A45)),
                  label: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Color(0xFFC97A45),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Saved Address Tile
          InfoTile(
            title: 'Saved Address',
            value: address,
          ),
          const SizedBox(height: 10),

          // Emergency Contact Tile
          InfoTile(
            title: 'Emergency Contact',
            value: emergencyContact,
            isMultiLine: true,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}