// lib/firebase/firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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

  // Fungsi untuk mengompres gambar sebelum upload
  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Cek ukuran file dalam bytes
    final fileSize = await file.length();
    final maxSize = 2 * 1024 * 1024; // Turunkan ke 2MB maksimum

    // Baca file
    final image = img.decodeImage(await file.readAsBytes());
    if (image == null) return file;

    // Base quality dan width
    int quality = 80;
    int targetWidth = 800;

    // Jika file lebih besar dari maxSize, kompres lebih agresif
    if (fileSize > maxSize) {
      // Semakin besar file, semakin agresif kompresi
      quality = ((maxSize / fileSize) * 85).round().clamp(50, 80);
      targetWidth = ((maxSize / fileSize) * image.width).round().clamp(
        600,
        1000,
      );
    }

    // Resize dengan mempertahankan aspect ratio
    final compressedImage = img.copyResize(
      image,
      width: targetWidth,
      maintainAspect: true,
      interpolation: img.Interpolation.linear,
    );

    // Simpan hasil kompresi dengan format JPEG
    final compressedFile = File('$path/$fileName.jpg')
      ..writeAsBytesSync(img.encodeJpg(compressedImage, quality: quality));

    // Verifikasi hasil kompresi
    final compressedSize = await compressedFile.length();
    print('Original size: ${fileSize / 1024 / 1024}MB');
    print('Compressed size: ${compressedSize / 1024 / 1024}MB');
    print('Compression quality: $quality');
    print('Target width: $targetWidth');

    return compressedFile;
  }

  // Update fungsi upload untuk menggunakan kompresi
  Future<String> uploadPhotoToStorage(File file, String path) async {
    try {
      // Kompres file sebelum upload
      final compressedFile = await compressImage(file);
      final fileSize = await compressedFile.length();

      // Verifikasi ukuran final
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception(
          'File masih terlalu besar setelah kompresi (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). Maksimum 5MB.',
        );
      }

      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        cacheControl: 'public,max-age=31536000',
        contentType: 'image/jpeg',
      );

      final uploadTask = ref.putFile(compressedFile, metadata);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading photo: $e');
      throw e;
    }
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
