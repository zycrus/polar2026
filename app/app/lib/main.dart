import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pages/emergency.dart';
import 'pages/community.dart';
import 'pages/services.dart';
import 'pages/healthcare.dart';
import 'pages/profile.dart';
import 'widgets/navbar.dart';
import 'widgets/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const MainScreen());
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Start on the center tab

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color emergencyGradientColor = Color(0xFFF9C7B0);
    const Color communityGradientColor = Color(0xFFFBEBC9);
    const Color profileGradientColor = Color(0xFFF7D8B8);
    const Color healthcareGradientColor = Color(0xFFF6D3D3);
    const Color servicesGradientColor = Color(0xFFF3E4CF);
    final List<Color> pageGradientColors = [
      emergencyGradientColor,
      communityGradientColor,
      profileGradientColor,
      healthcareGradientColor,
      servicesGradientColor,
    ];

    final List<Widget> pages = [
      const EmergencyPage(),
      const CommunityPage(),
      ProfilePage(onTabSelected: _changeTab),
      const HealthcarePage(),
      const ServicesPage(),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [pageGradientColors[_selectedIndex].withValues(alpha: 0.25), Colors.white],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- LEFT COLUMN: LOGO + SUBTEXT ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/logo.svg',
                            height: 50, // Slightly adjusted for better vertical balance
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Sa Santa Rosa, instant ang serbisyo sa 'yo.",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 10, // Increased slightly for better legibility
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6E5D53),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- RIGHT ICON: NOTIFICATION WITH BADGE ---
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none,
                            size: 28,
                            color: Color(0xFF3E2723),
                          ),
                          onPressed: () {
                            NotificationsDialog.show(context);
                          },
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC8532B),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: pages[_selectedIndex],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _changeTab,
      ),
    );
  }
}
