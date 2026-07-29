import 'package:flutter/material.dart';

class ConcernReportPage extends StatefulWidget {
  final String selectedCategory;

  const ConcernReportPage({
    super.key,
    this.selectedCategory = 'CDRRMO',
  });

  @override
  State<ConcernReportPage> createState() => _ConcernReportPageState();
}

class _ConcernReportPageState extends State<ConcernReportPage> {
  late String _selectedCategory;
  bool _useGps = true;
  final TextEditingController _natureController = TextEditingController();

  final List<String> _categories = ['Noise', 'Disorder', 'Infrastructure', 'Parking'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  void dispose() {
    _natureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color startColor = Color(0xFFFBEBC9);
    const Color endColor = Colors.white;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [startColor, endColor],
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent, // Make the scaffold background transparent
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: Color(0xFF6E5649)),
                    label: const Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFF6E5649),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Distress Report Card Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Barangay Concern',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B1D19),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Central office verifies &\njudges severity',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8C7B73),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB8843A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'STANDARD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildSectionHeader('CATEGORY'),
                      const SizedBox(height: 8),
                      Row(
                        children: _categories.map((cat) {
                          final isSelected = cat == _selectedCategory;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF7C3D1D)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF6E5649),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      _buildSectionHeader('LOCATION'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildLocationToggle(
                                icon: Icons.push_pin,
                                iconColor: const Color(0xFFD94A6B),
                                label: 'Use GPS',
                                isSelected: _useGps,
                                onTap: () => setState(() => _useGps = true),
                              ),
                            ),
                            Expanded(
                              child: _buildLocationToggle(
                                icon: Icons.edit,
                                iconColor: const Color(0xFFD97746),
                                label: 'Type Landmark',
                                isSelected: !_useGps,
                                onTap: () => setState(() => _useGps = false),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Brgy. Pulong Sta. Cruz, near Chowking',
                          style: TextStyle(
                            color: Color(0xFF4A3E39),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildSectionHeader('IDENTITY'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Maria Reyes · 0917 •• •• 214',
                          style: TextStyle(
                            color: Color(0xFF4A3E39),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildSectionHeader('NATURE OF CONCERN'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _natureController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: "Describe what's happening...",
                            hintStyle: TextStyle(
                              color: Color(0xFFAAA09A),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD35331),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            // Handle report submission
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Report Submitted!')),
                            );
                          },
                          child: const Text(
                            'Submit Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Color(0xFF8C7B73),
      ),
    );
  }

  Widget _buildLocationToggle({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7D9BA) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF4A3E39),
              ),
            ),
          ],
        ),
      ),
    );
  }
}