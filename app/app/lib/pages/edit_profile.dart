import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({
    super.key,
    required this.userData,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _streetController;
  late TextEditingController _brgyController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactNumberController;

  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Extract address data
    final dynamic addressData =
        widget.userData['savedAddress'] ?? widget.userData['address'];
    String streetVal = '';
    String brgyVal = '';

    if (addressData is Map<String, dynamic>) {
      streetVal = (addressData['street'] ?? '').toString();
      brgyVal =
          (addressData['brgy'] ?? addressData['barangay'] ?? '').toString();
    } else {
      streetVal = (widget.userData['street'] ?? '').toString();
      brgyVal = (widget.userData['brgy'] ?? widget.userData['barangay'] ?? '')
          .toString();
    }

    // Extract emergency contact data
    String eNameVal = (widget.userData['emergencyContactName'] ?? '').toString();
    String eNumVal = (widget.userData['emergencyContactNumber'] ??
            widget.userData['emergencyContactPhone'] ??
            '')
        .toString();

    if (eNameVal.isEmpty && eNumVal.isEmpty) {
      final dynamic eData = widget.userData['emergencyContact'] ??
          widget.userData['emergency_contact'];
      if (eData is Map<String, dynamic>) {
        eNameVal = (eData['name'] ?? eData['fullName'] ?? '').toString();
        eNumVal = (eData['number'] ?? eData['phone'] ?? eData['phoneNumber'] ?? '')
            .toString();
      }
    }

    // Initialize controllers with current values
    _fullNameController = TextEditingController(
      text: widget.userData['fullName'] ?? widget.userData['name'] ?? '',
    );
    _streetController = TextEditingController(text: streetVal);
    _brgyController = TextEditingController(text: brgyVal);
    _emergencyContactNameController = TextEditingController(text: eNameVal);
    _emergencyContactNumberController = TextEditingController(text: eNumVal);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _streetController.dispose();
    _brgyController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final fullName = _fullNameController.text.trim();
      
      // Update Firebase Auth display name
      await user.updateDisplayName(fullName);

      // Save updated data to Firestore
      await _firestoreService.updateUserProfile(
        uid: user.uid,
        fullName: fullName,
        street: _streetController.text.trim(),
        brgy: _brgyController.text.trim(),
        emergencyContactName: _emergencyContactNameController.text.trim(),
        emergencyContactNumber: _emergencyContactNumberController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFC97A45);
    const darkTextColor = Color(0xFF532813);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkTextColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                      'Full Name', Icons.person_outline, 'e.g. Juan Dela Cruz'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Street Address
                TextFormField(
                  controller: _streetController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                      'Street Address', Icons.home_outlined, 'e.g. 123 Rizal St.'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your street address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Barangay
                TextFormField(
                  controller: _brgyController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                      'Barangay', Icons.location_city_outlined, 'e.g. Brgy. San Jose'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your barangay';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Emergency Contact Name
                TextFormField(
                  controller: _emergencyContactNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                      'Emergency Contact Name', Icons.contact_page_outlined, 'e.g. Maria Dela Cruz'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter emergency contact name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Emergency Contact Number
                TextFormField(
                  controller: _emergencyContactNumberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: _buildInputDecoration(
                      'Emergency Contact No.', Icons.contact_phone_outlined, '09123456789'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter emergency contact number';
                    }
                    final contact = value.trim();
                    if (!contact.startsWith('09')) {
                      return 'Contact number must start with 09';
                    }
                    if (contact.length != 11) {
                      return 'Contact number must be exactly 11 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28.0),

                // Save Changes Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, String hint) {
    const primaryColor = Color(0xFFC97A45);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
    );
  }
}