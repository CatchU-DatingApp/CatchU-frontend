// lib/auth/auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/firebase_service.dart';

class AuthController {
  final FirebaseService _firebaseService = FirebaseService();

  // New method to check if phone number is registered
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
      // In case of error, return false to be safe
      return false;
    }
  }

  // Langkah 1: Kirim OTP ke nomor telepon
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
  }) async {
    try {
      // Note: Phone number check is now done in the LoginPage before calling this method
      // So we can remove the check here to avoid duplicate checks

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

  // Langkah 2: Verifikasi OTP dan login
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Buat credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Login dengan credential
      return await _firebaseService.auth.signInWithCredential(credential);
    } catch (e) {
      print('OTP verification error: $e');
      rethrow;
    }
  }

  // Alternatif: Login dengan Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Gunakan GoogleSignIn package (perlu ditambahkan ke pubspec.yaml)
      // Implementasi lengkap memerlukan google_sign_in package

      // Ini placeholder, implementasi sebenarnya perlu package tambahan
      throw UnimplementedError('Google Sign In belum diimplementasikan');
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  // Sign up (untuk alur pendaftaran)
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
      // Simpan data tambahan ke Firestore
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

  // Logout
  Future<void> logout() async {
    await _firebaseService.auth.signOut();
  }

  // Cek apakah user sudah login
  bool isUserLoggedIn() {
    return _firebaseService.auth.currentUser != null;
  }

  // Dapatkan user saat ini
  User? getCurrentUser() {
    return _firebaseService.auth.currentUser;
  }
}
