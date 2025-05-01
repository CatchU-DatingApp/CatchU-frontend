// lib/firebase/firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getter untuk instance
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  // Fungsi helper untuk auth status
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Fungsi upload foto ke Firebase Storage
  Future<String> uploadPhotoToStorage(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Fungsi untuk menghapus foto dari Firebase Storage
  Future<void> deletePhotoFromStorage(String photoUrl) async {
    try {
      // Dapatkan reference dari URL
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting photo from storage: $e');
      throw e;
    }
  }

  // Tambahkan metode lain yang Anda butuhkan
}
