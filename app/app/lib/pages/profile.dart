import 'package:flutter/material.dart';
import '../widgets/quickaction.dart';
import '../widgets/info_tile.dart';
import '../widgets/report_card.dart';

class ProfilePage extends StatelessWidget {
  final ValueChanged<int> onTabSelected;

  const ProfilePage({
    super.key,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
  // const Color color1 = Color(0xFFF3E4CF);
  // const Color color2 = Color(0xFF9C5F32);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container (
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
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/300?img=12', // Placeholder avatar image
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Rhyan x Polai',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF532813),
                          ),
                        ),
                        Text(
                          'Brgy. Pulong Sta. Cruz',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8A6753),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              InfoTile(
                title: 'Mobile',
                value: '0917 •• •• 214',
              ),
              const SizedBox(height: 10),
              InfoTile(
                title: 'Saved Address',
                value: 'Blk • Lot •',
              ),
              const SizedBox(height: 10),
              InfoTile(
                title: 'Emergency Contact',
                value: 'Allen Poli Bob\n0917 •• •• 153',
                isMultiLine: true,
              ),

              const SizedBox(height: 16),

              const Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF532813),
                ),
              ),

              const SizedBox(height: 8),

              ReportCard(
                icon: Icons.notifications_active,
                iconColor: const Color(0xFFB8321B),
                title: 'Emergency',
                caseNumber: 'Case #1042',
                status: 'Dispatched',
                statusColor: const Color(0xFFB8321B),
              ),
              const SizedBox(height: 8),
              ReportCard(
                icon: Icons.groups,
                iconColor: const Color(0xFF8A3B1B),
                title: 'Community',
                caseNumber: 'Case #0981',
                status: 'Under Review',
                statusColor: const Color(0xFFB8531B),
              ),
              const SizedBox(height: 8),
              ReportCard(
                icon: Icons.assignment_turned_in_outlined,
                iconColor: const Color(0xFFB8321B),
                title: 'Business Permit',
                caseNumber: 'Case #0774',
                status: 'Approved',
                statusColor: const Color(0xFFB8321B),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}