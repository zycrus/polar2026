import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHotlinesDialog extends StatelessWidget {
  const EmergencyHotlinesDialog({super.key});

  /// Static helper method to trigger the popup easily from anywhere
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const EmergencyHotlinesDialog(),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFC8532B);

    final List<Map<String, dynamic>> hotlines = [
      {
        'department': 'SANTA ROSA CITY DISASTER RISK REDUCTION AND MANAGEMENT OFFICE',
        'icon': Icons.shield_outlined,
        'contacts': [
          {'label': 'GLOBE', 'number': '0995-650-1943', 'raw': '09956501943'},
          {'label': 'SMART', 'number': '0999-873-5431', 'raw': '09998735431'},
        ]
      },
      {
        'department': 'BUREAU OF FIRE PROTECTION',
        'icon': Icons.local_fire_department_outlined,
        'contacts': [
          {'label': 'LANDLINE', 'number': '(049) 534-1291', 'raw': '0495341291'},
          {'label': 'LANDLINE', 'number': '(049) 502-5410', 'raw': '0495025410'},
          {'label': 'MOBILE', 'number': '0922-780-7570', 'raw': '09227807570'},
        ]
      },
      {
        'department': 'PHILIPPINE NATIONAL POLICE',
        'icon': Icons.local_police_outlined,
        'contacts': [
          {'label': 'MOBILE', 'number': '0905-550-5288', 'raw': '09055505288'},
          {'label': 'MOBILE', 'number': '0998-598-5629', 'raw': '09985985629'},
        ]
      },
      {
        'department': 'PUBLIC ORDER AND SAFETY OFFICE',
        'icon': Icons.security_outlined,
        'contacts': [
          {'label': 'MOBILE', 'number': '0961-722-1414', 'raw': '09617221414'},
        ]
      },
    ];

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
          maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                      Icons.phone_in_talk_outlined,
                      color: brandOrange,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'EMERGENCY HOTLINES',
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

            // --- HOTLINES LIST ---
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: hotlines.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final group = hotlines[index];
                  final String deptName = group['department'];
                  final IconData deptIcon = group['icon'];
                  final List contacts = group['contacts'];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFBECE6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                deptIcon,
                                color: brandOrange,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                deptName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2B1D19),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: Color(0xFFEBE3DF)),
                        const SizedBox(height: 6),
                        ...contacts.map((contact) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact['label']!,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8C7B73),
                                      ),
                                    ),
                                    Text(
                                      contact['number']!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B1D19),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFFBECE6),
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  icon: const Icon(
                                    Icons.call_outlined,
                                    color: brandOrange,
                                    size: 18,
                                  ),
                                  onPressed: () => _makePhoneCall(contact['raw']!),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
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