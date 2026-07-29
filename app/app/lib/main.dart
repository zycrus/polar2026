import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/navbar.dart';

//#FCC8B2

import 'pages/emergency.dart';
import 'pages/community.dart';
import 'pages/services.dart';
import 'pages/healthcare.dart';
import 'pages/profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
    const Color color1 = Color(0xFFF9C7B0);
    const Color color2 = Color(0xFFFBEBC9);
    const Color color3 = Color(0xFFF7D8B8);
    const Color color4 = Color(0xFFF6D3D3);
    const Color color5 = Color(0xFFF3E4CF);
    final List<Color> pageGradientColors = [
      color1, // EmergencyPage
      color2, // CommunityPage
      color3, // ProfilePage
      color4, // HealthcarePage
      color5, // ServicesPage
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
                padding: const EdgeInsets.only(top: 0.0, bottom: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/logo.svg',
                          height: 60,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 16),
                        const Text(
                          "Sa Santa Rosa, instant ang serbisyo sa 'yo.",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 6,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6E5D53),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
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

      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.white,
      //   type: BottomNavigationBarType.fixed,
      //   enableFeedback: false,
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   selectedItemColor: Colors.redAccent,
      //   unselectedItemColor: Colors.grey,
      //   items: [
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.phone),
      //       label: 'Emergency',
      //     ),

      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.people),
      //       label: 'Community',
      //     ),

      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.search),
      //       label: 'Services', // Empty label to keep it clean
      //     ),

      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.favorite),
      //       label: 'Healthcare',
      //     ),

      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),
    );
  }
}
