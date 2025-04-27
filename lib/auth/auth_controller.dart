// lib/auth/auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/firebase_service.dart';

class AuthController {
  final FirebaseService _firebaseService = FirebaseService();

  Future<bool> checkPhoneNumberRegistered(String phoneNumber) async {
    try {
      final querySnapshot =
          await _firebaseService.firestore
              .collection('Users')
              .where('nomor_telepon', isEqualTo: phoneNumber)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone number: $e');
      return false;
    }
  }

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
  }) async {
    try {
      await _firebaseService.auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _firebaseService.auth.signInWithCredential(credential);
    } catch (e) {
      print('OTP verification error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      throw UnimplementedError('Google Sign In belum diimplementasikan');
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required int age,
    required String gender,
    required List<String> interests,
    required String location,
    String? profilePicUrl,
    required String phoneNumber,
  }) async {
    try {
      await _firebaseService.firestore.collection('Users').doc(uid).set({
        'name': name,
        'phoneNumber': phoneNumber,
        'age': age,
        'gender': gender,
        'interests': interests,
        'location': location,
        'profilePicUrl': profilePicUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Create user profile error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebaseService.auth.signOut();
  }

  bool isUserLoggedIn() {
    return _firebaseService.auth.currentUser != null;
  }

  User? getCurrentUser() {
    return _firebaseService.auth.currentUser;
  }
}
