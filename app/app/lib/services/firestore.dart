import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates or merges full user data upon sign up
  Future<void> saveUserData({
    required String uid,
    required String fullName,
    required String phoneNumber,
    required String street,
    required String brgy,
    required String emergencyContactName,
    required String emergencyContactNumber,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'savedAddress': {
        'street': street,
        'brgy': brgy,
      },
      'emergencyContactName': emergencyContactName,
      'emergencyContactNumber': emergencyContactNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Updates existing user profile fields
  Future<void> updateUserProfile({
    required String uid,
    required String fullName,
    required String street,
    required String brgy,
    required String emergencyContactName,
    required String emergencyContactNumber,
  }) async {
    await _db.collection('users').doc(uid).update({
      'fullName': fullName,
      'savedAddress': {
        'street': street,
        'brgy': brgy,
      },
      'emergencyContactName': emergencyContactName,
      'emergencyContactNumber': emergencyContactNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}