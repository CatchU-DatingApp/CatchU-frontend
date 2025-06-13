// lib/auth/auth_controller.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../firebase/firebase_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

class AuthController {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkPhoneNumberRegistered(String phoneNumber) async {
    try {
      final phoneNumberWithoutPlus = phoneNumber.replaceFirst('+', '');

      final response = await http.get(
        Uri.parse('http://172.20.10.3:8080/users/check-phone?phoneNumber=$phoneNumberWithoutPlus'),
      );

      if (response.statusCode == 200) {
        final exists = jsonDecode(response.body) as bool;
        return exists;
      } else {
        print('API error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error checking phone via API: $e');
      return false;
    }
  }

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      print('Error sending OTP: $e');
      verificationFailed(
        FirebaseAuthException(
          code: 'unknown',
          message: 'Failed to send OTP. Please try again.',
        ),
      );
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

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error verifying OTP: $e');
      throw FirebaseAuthException(
        code: 'invalid-verification-code',
        message: 'Invalid verification code. Please try again.',
      );
    }
  }

  Future<bool> checkFirestoreAccess() async {
    try {
      print('Checking Firestore access...');

      // Try to read a document from Users collection
      final testDoc = await _firestore.collection('Users').limit(1).get();

      print(
        'Firestore access test result: ${testDoc.docs.isNotEmpty ? 'Success' : 'No documents found'}',
      );
      return true;
    } catch (e) {
      print('Firestore access error: $e');
      if (e is FirebaseException) {
        print('Firebase Error Code: ${e.code}');
        print('Firebase Error Message: ${e.message}');
      }
      return false;
    }
  }

  Future<void> deleteCurrentUserWithReauth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          // Re-authenticate dengan Google
          final googleUser = await GoogleSignIn().signIn();
          if (googleUser == null) return;
          final googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user.reauthenticateWithCredential(credential);
          await user.delete();
        }
      }
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      print('Starting Google sign in process...');
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('Google sign in was cancelled by user');
        throw FirebaseAuthException(
          code: 'google-sign-in-cancelled',
          message: 'Google sign in was cancelled',
        );
      }
      print('Google user obtained: ${googleUser.email}');

      // Cek email di Firestore
      final emailCheck =
          await _firestore
              .collection('Users')
              .where('email', isEqualTo: googleUser.email)
              .get();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Google auth obtained successfully');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Google credential created');

      // Cek metode login yang sudah terdaftar untuk email ini
      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(
        googleUser.email,
      );

      // Jika sudah pernah daftar/login dengan Google, langsung login
      if (signInMethods.contains('google.com')) {
        final googleUserCredential = await _auth.signInWithCredential(
          credential,
        );
        final googleUid = googleUserCredential.user!.uid;
        // Update lastLogin jika user sudah ada di Firestore
        if (emailCheck.docs.isNotEmpty) {
          await _firestore.collection('Users').doc(googleUid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
        print('Google sign in process completed successfully (login Google).');
        return googleUserCredential;
      }

      // Jika sudah pernah daftar dengan email/password, tampilkan pesan error
      if (signInMethods.contains('password')) {
        throw FirebaseAuthException(
          code: 'account-exists-with-different-credential',
          message:
              'Akun sudah terdaftar dengan email & password. Silakan login dengan email & password, lalu tambahkan Google dari menu pengaturan akun.',
        );
      }

      // Jika belum ada user di Firestore, buat baru
      final googleUserCredential = await _auth.signInWithCredential(credential);
      final googleUid = googleUserCredential.user!.uid;
      if (emailCheck.docs.isEmpty) {
        // Hapus user yang baru saja dibuat di Auth (dengan re-authenticate jika perlu)
        await deleteCurrentUserWithReauth();
        throw FirebaseAuthException(
          code: 'user-not-found',
          message:
              'Akun belum terdaftar. Silakan daftar terlebih dahulu melalui menu sign up.',
        );
      } else {
        // Jika sudah ada user di Firestore tapi belum pernah login Google, update lastLogin
        await _firestore.collection('Users').doc(googleUid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        print(
          'Google sign in process completed successfully (update lastLogin).',
        );
        return googleUserCredential;
      }
    } catch (e) {
      print('Google sign in error: $e');
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
      } else if (e is PlatformException) {
        print('Platform Error Code: ${e.code}');
        print('Platform Error Message: ${e.message}');
      }
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

  Future<void> linkPhoneCredentialToCurrentUser(
    PhoneAuthCredential credential,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is currently signed in');
    try {
      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        // Sudah terhubung, tidak masalah
      } else if (e.code == 'credential-already-in-use') {
        throw Exception('Nomor telepon sudah terdaftar di akun lain.');
      } else {
        rethrow;
      }
    }
  }
}
