// lib/auth/auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/firebase_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

class AuthController {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkPhoneNumberRegistered(String phoneNumber) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('Users')
              .where('nomorTelepon', isEqualTo: phoneNumber)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone number: $e');
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

  Future<UserCredential> signInWithGoogle() async {
    try {
      print('Starting Google sign in process...');

      // Trigger the authentication flow
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign out first to ensure clean state
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

      // Check if email exists in Firestore before proceeding
      final emailCheck =
          await _firestore
              .collection('Users')
              .where('email', isEqualTo: googleUser.email)
              .get();

      if (emailCheck.docs.isEmpty) {
        print('Email not registered in Firestore: ${googleUser.email}');
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Email belum terdaftar. Silakan sign up terlebih dahulu.',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Google auth obtained successfully');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Google credential created');

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      print('Firebase sign in successful: ${userCredential.user?.email}');

      // Update last login timestamp
      await _firestore.collection('Users').doc(userCredential.user!.uid).update(
        {'lastLogin': FieldValue.serverTimestamp()},
      );
      print('User document updated with last login timestamp');

      print('Google sign in process completed successfully');
      return userCredential;
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
}
