import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../widgets/card.dart';
import 'distress_report.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
  const Color color1 = Color(0xFFFBEBC9);
  const Color color2 = Color(0xFFCF5B3B);
    return Container(
      width: double.infinity,
      height: double.infinity,
      // decoration: const BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [startColor, endColor],
      //   ),
      // ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                      onSubmit: () {
                        // Add your emergency call logic here (e.g. url_launcher)
                        debugPrint('Calling emergency services...');
                        return null;
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
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
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          CustomCard(
                            title: 'CDRRMO — Disaster\nResponse',
                            subtitle: 'Evacuation, rescue, stranded citizens',
                            themeColor: color1,
                            icon: const Icon(Icons.tsunami, color: color2, size: 26), // Or custom SVG
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DistressReportPage(
                                    selectedCategory: 'CDRRMO',
                                  ),
                                ),
                              );
                            },
                          ),

                          CustomCard(
                            title: 'EMS & Rescue',
                            subtitle: 'Accidents, medical attention, abuse/violence',
                            themeColor: color1,
                            icon: const Icon(Icons.medical_services_rounded, color: color2, size: 26),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DistressReportPage(
                                    selectedCategory: 'EMS',
                                  ),
                                ),
                              );
                            },
                          ),

                          CustomCard(
                            title: 'POSO — Public Order &\nSafety',
                            subtitle: 'Larger-scale distress, PNP coordination',
                            themeColor: color1,
                            icon: const Icon(Icons.local_police, color: color2, size: 26),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DistressReportPage(
                                    selectedCategory: 'POSO',
                                  ),
                                ),
                              );
                            },
                          ),

                          CustomCard(
                            title: 'BFP — Fire & Rescue',
                            subtitle: 'Fire hazards, rescue emergencies',
                            themeColor: color1,
                            icon: const Icon(Icons.fire_truck, color: color2, size: 26),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DistressReportPage(
                                    selectedCategory: 'BFP',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}