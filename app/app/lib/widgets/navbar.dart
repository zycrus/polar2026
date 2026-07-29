import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // List of icons matching your design
    final List<IconData> navIcons = [
      Icons.emergency,          // Siren / Emergency
      Icons.people,             // Community
      Icons.person,             // Profile
      Icons.medical_services,   // Healthcare / Stethoscope
      Icons.menu,               // Services / Menu
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 60.0, right: 60.0, bottom: 20.0),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFCD733F), // Warm terracotta background
          borderRadius: BorderRadius.circular(20), // Rounded pill container
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navIcons.length, (index) {
            final isSelected = currentIndex == index;

            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  navIcons[index],
                  size: 26,
                  color: isSelected
                      ? const Color(0xFF8B1D13) // Dark red for active icon
                      : const Color(0xFFFBE8D3), // Cream/peach for inactive icons
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}