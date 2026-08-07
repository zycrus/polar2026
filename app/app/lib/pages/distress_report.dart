import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

enum LocationMode { gps, pin, landmark }

class DistressReportPage extends StatefulWidget {
  final String selectedCategory;

  const DistressReportPage({
    super.key,
    this.selectedCategory = 'CDRRMO',
  });

  @override
  State<DistressReportPage> createState() => _DistressReportPageState();
}

class _DistressReportPageState extends State<DistressReportPage> {
  late String _selectedCategory;
  LocationMode _locationMode = LocationMode.gps;
  bool _isLoadingGps = false;
  bool _isSubmitting = false;
  Position? _currentPosition;
  LatLng? _pinnedPosition;

  String? _selectedBarangay;
  final TextEditingController _natureController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  final List<String> _categories = ['CDRRMO', 'EMS', 'POSO', 'BFP'];

  final List<String> _barangays = [
    'Aplaya',
    'Balibago',
    'Caingin',
    'Dila',
    'Dita',
    'Don Jose',
    'Ibaba',
    'Kanluran',
    'Labas',
    'Macabling',
    'Malitlit',
    'Malusak',
    'Market Area',
    'Pooc',
    'Pulong Santa Cruz',
    'Santo Domingo',
    'Sinalhan',
    'Tagapo',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _fetchGpsLocation();
  }

  @override
  void dispose() {
    _natureController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() => _isLoadingGps = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled. Please enable GPS.')),
          );
        }
        setState(() => _isLoadingGps = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          setState(() => _isLoadingGps = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied.')),
          );
        }
        setState(() => _isLoadingGps = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      setState(() {
        _currentPosition = position;
        _isLoadingGps = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
      setState(() => _isLoadingGps = false);
    }
  }

  Future<void> _openMapPinPicker() async {
    LatLng initialCenter = _pinnedPosition ??
        (_currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : const LatLng(14.3122, 121.0913)); // Santa Rosa, Laguna default

    LatLng tempSelected = initialCenter;

    final LatLng? picked = await showDialog<LatLng>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pin Location on Map', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: initialCenter,
                      initialZoom: 15.0,
                      onTap: (tapPosition, point) {
                        setDialogState(() {
                          tempSelected = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.yzk1t.instarosapp',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: tempSelected,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFFD35331),
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD35331)),
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: const Text('Confirm Pin', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        _pinnedPosition = picked;
        _locationMode = LocationMode.pin;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_selectedBarangay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a barangay first.')),
      );
      return;
    }

    if (_locationMode == LocationMode.landmark && _landmarkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter street or landmark details.')),
      );
      return;
    }

    if (_locationMode == LocationMode.pin && _pinnedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a position on the map.')),
      );
      return;
    }

    if (_natureController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the nature of distress.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      String userName = 'User';
      String userPhone = '';

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          userName = userData?['fullName'] ?? userData?['name'] ?? currentUser.displayName ?? 'User';
          userPhone = userData?['phoneNumber'] ?? currentUser.phoneNumber ?? '';
        } else {
          userName = currentUser.displayName ?? 'User';
          userPhone = currentUser.phoneNumber ?? '';
        }
      }

      GeoPoint? geoPoint;
      if (_locationMode == LocationMode.gps && _currentPosition != null) {
        geoPoint = GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude);
      } else if (_locationMode == LocationMode.pin && _pinnedPosition != null) {
        geoPoint = GeoPoint(_pinnedPosition!.latitude, _pinnedPosition!.longitude);
      }

      final reportData = {
        'reportType': 'emergency',
        'category': _selectedCategory,
        'barangay': _selectedBarangay,
        'locationType': _locationMode.name.toUpperCase(),
        'landmarkDetails': _locationMode == LocationMode.landmark ? _landmarkController.text.trim() : null,
        'coordinates': geoPoint,
        'natureOfDistress': _natureController.text.trim(),
        'userId': currentUser?.uid ?? 'anonymous',
        'userName': userName,
        'userPhone': userPhone,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('reports').add(reportData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency report submitted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length >= 11) {
      final prefix = cleaned.substring(0, 4);
      final suffix = cleaned.substring(cleaned.length - 3);
      return '$prefix •• •• $suffix';
    }
    return phone.isNotEmpty ? phone : 'No phone number';
  }

  @override
  Widget build(BuildContext context) {
    const Color startColor = Color(0xFFF9C7B0);
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
        backgroundColor: Colors.transparent,
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
                                    'Distress Report',
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
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB84A2E),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'HIGH PRIORITY',
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
                              onTap: () => setState(() => _selectedCategory = cat),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF7C3D1D) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF6E5649),
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
                                icon: Icons.my_location,
                                iconColor: const Color(0xFFD94A6B),
                                label: 'GPS',
                                isSelected: _locationMode == LocationMode.gps,
                                onTap: () {
                                  setState(() => _locationMode = LocationMode.gps);
                                  if (_currentPosition == null) _fetchGpsLocation();
                                },
                              ),
                            ),
                            Expanded(
                              child: _buildLocationToggle(
                                icon: Icons.push_pin,
                                iconColor: const Color(0xFF7C3D1D),
                                label: 'Pin Map',
                                isSelected: _locationMode == LocationMode.pin,
                                onTap: _openMapPinPicker,
                              ),
                            ),
                            Expanded(
                              child: _buildLocationToggle(
                                icon: Icons.edit,
                                iconColor: const Color(0xFFD97746),
                                label: 'Landmark',
                                isSelected: _locationMode == LocationMode.landmark,
                                onTap: () => setState(() => _locationMode = LocationMode.landmark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBarangay,
                            hint: const Text('Select Barangay', style: TextStyle(color: Color(0xFF8C7B73), fontSize: 14)),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6E5649)),
                            items: _barangays.map((String barangay) {
                              return DropdownMenuItem<String>(
                                value: barangay,
                                child: Text('Brgy. $barangay', style: const TextStyle(color: Color(0xFF4A3E39), fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (newValue) => setState(() => _selectedBarangay = newValue),
                          ),
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
                        child: _locationMode == LocationMode.gps
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _isLoadingGps
                                        ? const Text('Acquiring GPS coordinates...', style: TextStyle(color: Color(0xFF8C7B73), fontSize: 14))
                                        : Text(
                                            _currentPosition != null
                                                ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, Long: ${_currentPosition!.longitude.toStringAsFixed(5)}'
                                                : 'GPS position unavailable',
                                            style: const TextStyle(color: Color(0xFF4A3E39), fontSize: 14),
                                          ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF7C3D1D)),
                                    onPressed: _fetchGpsLocation,
                                    tooltip: 'Refresh GPS',
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              )
                            : _locationMode == LocationMode.pin
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _pinnedPosition != null
                                              ? 'Pinned: ${_pinnedPosition!.latitude.toStringAsFixed(5)}, ${_pinnedPosition!.longitude.toStringAsFixed(5)}'
                                              : 'No map pin set',
                                          style: const TextStyle(color: Color(0xFF4A3E39), fontSize: 14),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _openMapPinPicker,
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                        child: const Text('Change Pin', style: TextStyle(color: Color(0xFF7C3D1D), fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  )
                                : TextField(
                                    controller: _landmarkController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter specific street or landmark details...',
                                      hintStyle: TextStyle(color: Color(0xFFAAA09A), fontSize: 14),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                      ),
                      const SizedBox(height: 20),

                      _buildSectionHeader('IDENTITY'),
                      const SizedBox(height: 8),
                      StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, authSnapshot) {
                          final currentUser = authSnapshot.data;
                          if (currentUser == null) return _buildIdentityBox('Guest User · Logged Out');

                          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
                            builder: (context, firestoreSnapshot) {
                              if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
                                return _buildIdentityBox('Loading user identity...');
                              }
                              final userData = firestoreSnapshot.data?.data();
                              final String name = userData?['fullName'] ?? userData?['name'] ?? currentUser.displayName ?? 'User';
                              final String rawPhone = userData?['phoneNumber'] ?? currentUser.phoneNumber ?? '';
                              return _buildIdentityBox('$name · ${_formatPhoneNumber(rawPhone)}');
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildSectionHeader('NATURE OF DISTRESS'),
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
                            hintStyle: TextStyle(color: Color(0xFFAAA09A), fontSize: 14),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                            elevation: 2,
                          ),
                          onPressed: _isSubmitting ? null : _submitReport,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text(
                                  'Submit Report',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildIdentityBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: const TextStyle(color: Color(0xFF4A3E39), fontSize: 14)),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF8C7B73)),
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
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4A3E39)),
            ),
          ],
        ),
      ),
    );
  }
}