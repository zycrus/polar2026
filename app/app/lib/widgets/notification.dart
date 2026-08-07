import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({super.key});

  /// Static helper method to trigger the popup easily from anywhere
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const NotificationsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    const Color brandOrange = Color(0xFFC8532B);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- POPUP HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: brandOrange,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'NOTIFICATIONS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Color(0xFF2B1D19),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, color: Color(0xFF8C7B73), size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEBE3DF)),
            const SizedBox(height: 12),

            // --- NOTIFICATION CONTENT ---
            Expanded(
              child: currentUser == null
                  ? const Center(
                      child: Text(
                        'Please sign in to view notifications.',
                        style: TextStyle(color: Color(0xFF8C7B73), fontSize: 13),
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('reports')
                          .where('userId', isEqualTo: currentUser.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: brandOrange),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No notifications yet.',
                              style: TextStyle(color: Color(0xFF8C7B73), fontSize: 13),
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs.toList();

                        // Sort descending by creation date
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
                          itemCount: docs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final reportData = docs[index].data() as Map<String, dynamic>;
                            final category = reportData['category'] ?? 'Emergency';
                            final status = reportData['status'] ?? 'Pending';
                            final caseId = reportData['caseNumber'] ?? docs[index].id.substring(0, 6).toUpperCase();
                            final timestamp = reportData['createdAt'] as Timestamp?;

                            String timeString = '';
                            if (timestamp != null) {
                              final date = timestamp.toDate();
                              timeString = '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                            }

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF6F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFBECE6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.error_outline_rounded,
                                      color: brandOrange,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$category Report',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2B1D19),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Case #$caseId status is now $status.',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF5C4B43),
                                          ),
                                        ),
                                        if (timeString.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            timeString,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFF8C7B73),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}