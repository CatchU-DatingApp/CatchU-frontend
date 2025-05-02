import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'face_validation_scan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../services/ml.dart';

//MASIH DEMO, BELUM BISA KONEK KE FIREBASE, MAKA BISA LANGSUNG NEXT UNTUK DEBUGGING
class FaceValidationPhotoPage extends StatefulWidget {
  const FaceValidationPhotoPage({Key? key}) : super(key: key);

  @override
  State<FaceValidationPhotoPage> createState() =>
      _FaceValidationPhotoPageState();
}

class _FaceValidationPhotoPageState extends State<FaceValidationPhotoPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _selectedPhotoUrl;
  List<String> userPhotos = [];
  Map<String, bool> photoHasFace = {};
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = Uuid();
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      minFaceSize: 0.15,
    ),
  );
  final FaceEmbeddingModel _faceEmbeddingModel = FaceEmbeddingModel();

  @override
  void initState() {
    super.initState();
    _loadUserPhotos();
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<bool> _checkForFace(String imageUrl) async {
    try {
      // Download gambar ke file temporary
      final response = await http.get(Uri.parse(imageUrl));
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(tempDir.path, '${uuid.v4()}.jpg');
      await File(tempPath).writeAsBytes(response.bodyBytes);

      // Deteksi wajah menggunakan ML Kit
      final inputImage = InputImage.fromFilePath(tempPath);
      final faces = await _faceDetector.processImage(inputImage);

      // Hapus file temporary
      await File(tempPath).delete();

      return faces.isNotEmpty;
    } catch (e) {
      print('Error checking for face: $e');
      return false;
    }
  }

  Future<void> _loadUserPhotos() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .get();

        if (doc.exists && doc.data()!.containsKey('photos')) {
          final photos = List<String>.from(doc.data()!['photos']);

          // Check each photo for faces
          for (String photo in photos) {
            final hasFace = await _checkForFace(photo);
            photoHasFace[photo] = hasFace;
          }

          setState(() {
            userPhotos = photos;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load photos: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Choose Your Photo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select one of your profile photos\nto use as face validation reference',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (userPhotos.isEmpty)
                const Center(
                  child: Text(
                    'No photos available.\nPlease upload photos in your profile first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: userPhotos.length,
                    itemBuilder: (context, index) {
                      final photo = userPhotos[index];
                      final hasFace = photoHasFace[photo] ?? false;

                      return GestureDetector(
                        onTap:
                            hasFace
                                ? () {
                                  setState(() {
                                    _selectedPhotoUrl = photo;
                                  });
                                }
                                : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'This photo does not contain a clear face. Please choose another photo.',
                                      ),
                                    ),
                                  );
                                },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    _selectedPhotoUrl == photo
                                        ? Border.all(
                                          color: Colors.pink,
                                          width: 3,
                                        )
                                        : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  photo,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (!hasFace)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.face_retouching_off,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed:
                    _selectedPhotoUrl == null
                        ? null
                        : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => FaceValidationScanPage(
                                    profilePhotoUrl: _selectedPhotoUrl!,
                                  ),
                            ),
                          );
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D6D),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Use Selected Photo',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
