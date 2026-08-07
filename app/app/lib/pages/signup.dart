import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore.dart';
import 'otp.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _brgyController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactNumberController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _brgyController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactNumberController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final inputPhone = _phoneController.text.trim();
    final formattedPhoneNumber = '+63${inputPhone.substring(1)}';

    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,

        // Auto-retrieval / Instant verification
        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          if (userCredential.user != null) {
            await _firestoreService.saveUserData(
              uid: userCredential.user!.uid,
              fullName: _fullNameController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              street: _streetController.text.trim(),
              brgy: _brgyController.text.trim(),
              emergencyContactName: _emergencyContactNameController.text.trim(),
              emergencyContactNumber: _emergencyContactNumberController.text.trim(),
            );
          }
          if (!mounted) return;
          setState(() => _isLoading = false);
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification failed')),
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() => _isLoading = false);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpPage(
                verificationId: verificationId,
                phoneNumber: inputPhone,
                fullName: _fullNameController.text.trim(),
                street: _streetController.text.trim(),
                brgy: _brgyController.text.trim(),
                emergencyContactName: _emergencyContactNameController.text.trim(),
                emergencyContactNumber: _emergencyContactNumberController.text.trim(),
                resendToken: resendToken,
              ),
            ),
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkTextColor),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 50,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    'Please fill in your details to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24.0),

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

                  // Mobile Number
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    decoration: _buildInputDecoration(
                        'Mobile Number', Icons.phone_outlined, '09123456789'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      final phone = value.trim();
                      if (!phone.startsWith('09')) {
                        return 'Mobile number must start with 09';
                      }
                      if (phone.length != 11) {
                        return 'Mobile number must be exactly 11 digits';
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

                  // Emergency Contact Phone Number
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
                        return 'Please enter an emergency contact number';
                      }
                      final contact = value.trim();
                      if (contact == _phoneController.text.trim()) {
                        return 'Cannot be the same as your mobile number';
                      }
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

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
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
                            'Continue to Verification',
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