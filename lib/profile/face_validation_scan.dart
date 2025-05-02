import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:google_ml_kit/google_ml_kit.dart';
import '../services/ml.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/mainpage.dart';

class FaceValidationScanPage extends StatefulWidget {
  final String profilePhotoUrl;

  const FaceValidationScanPage({Key? key, required this.profilePhotoUrl})
    : super(key: key);

  @override
  State<FaceValidationScanPage> createState() => _FaceValidationScanPageState();
}

class _FaceValidationScanPageState extends State<FaceValidationScanPage> {
  CameraController? _controller;
  late FaceEmbeddingModel _faceEmbeddingModel;
  late FaceDetector _faceDetector;
  bool _isProcessing = false;
  String? _validationMessage;
  bool? _isValidated;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceEmbeddingModel = FaceEmbeddingModel();
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
        minFaceSize: 0.15,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset
          .high, // Menggunakan resolusi tinggi untuk deteksi wajah yang lebih baik
      enableAudio: false,
      imageFormatGroup:
          ImageFormatGroup.yuv420, // Format yang kompatibel untuk ML Kit
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<String> _downloadAndSaveProfilePhoto() async {
    final response = await http.get(Uri.parse(widget.profilePhotoUrl));
    final tempDir = await getTemporaryDirectory();
    final tempPath = path.join(tempDir.path, 'profile_photo.jpg');
    await File(tempPath).writeAsBytes(response.bodyBytes);
    return tempPath;
  }

  // Fungsi utilitas untuk crop wajah dari file gambar
  Future<File> _cropFaceFromImage(
    String imagePath,
    Face face,
    String outputName,
  ) async {
    final imageBytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Tidak dapat membaca gambar');
    // Ambil bounding box wajah
    final rect = face.boundingBox;
    int x = rect.left.toInt().clamp(0, image.width - 1);
    int y = rect.top.toInt().clamp(0, image.height - 1);
    int w = rect.width.toInt().clamp(1, image.width - x);
    int h = rect.height.toInt().clamp(1, image.height - y);
    // Crop dan resize ke 112x112 (atau 160x160 sesuai model)
    final cropped = img.copyResize(
      img.copyCrop(image, x: x, y: y, width: w, height: h),
      width: 112,
      height: 112,
    );
    final tempDir = await getTemporaryDirectory();
    final outPath = path.join(tempDir.path, outputName);
    await File(outPath).writeAsBytes(img.encodeJpg(cropped));
    return File(outPath);
  }

  // Fungsi untuk deteksi wajah dan crop otomatis, return file crop
  Future<File?> _detectAndCropFace(String imagePath, String outputName) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;
    return await _cropFaceFromImage(imagePath, faces.first, outputName);
  }

  Future<void> _setUserVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update(
        {'verified': true},
      );
    }
  }

  void _resetValidation() {
    setState(() {
      _isValidated = null;
      _validationMessage = null;
    });
  }

  Future<void> _onValidationSuccess() async {
    await _setUserVerified();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainPage()),
        (route) => false,
      );
    }
  }

  Future<void> _validateFace() async {
    if (_controller == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _validationMessage = 'Processing...';
      _isValidated = null;
    });

    try {
      // Ambil foto dari kamera
      final XFile photo = await _controller!.takePicture();

      // Deteksi dan crop wajah dari foto kamera
      final File? croppedCameraFace = await _detectAndCropFace(
        photo.path,
        'captured_face.jpg',
      );
      if (croppedCameraFace == null) {
        setState(() {
          _isValidated = false;
          _validationMessage =
              'No face detected in the captured image. Please try again.';
        });
        await File(photo.path).delete();
        return;
      }

      // Download dan simpan foto profil
      final String profilePhotoPath = await _downloadAndSaveProfilePhoto();

      // Deteksi dan crop wajah dari foto profil
      final File? croppedProfileFace = await _detectAndCropFace(
        profilePhotoPath,
        'profile_face.jpg',
      );
      if (croppedProfileFace == null) {
        setState(() {
          _isValidated = false;
          _validationMessage = 'No face detected in the profile photo.';
        });
        await File(profilePhotoPath).delete();
        await File(photo.path).delete();
        await croppedCameraFace.delete();
        return;
      }

      // Dapatkan embedding untuk kedua crop wajah
      final List<double> profileEmbedding = await _faceEmbeddingModel
          .getEmbedding(croppedProfileFace)
          .then((value) => value.toList());
      final List<double> capturedEmbedding = await _faceEmbeddingModel
          .getEmbedding(croppedCameraFace)
          .then((value) => value.toList());

      // Hitung similarity
      final double similarity = cosineSimilarity(
        profileEmbedding,
        capturedEmbedding,
      );
      final bool isMatch = similarity >= 0.7; // Threshold untuk kecocokan

      setState(() {
        _isValidated = isMatch;
        _validationMessage =
            isMatch
                ? 'Face validation successful! (Similarity: ${(similarity * 100).toStringAsFixed(1)}%)'
                : 'Face validation failed. Please try again. (Similarity: ${(similarity * 100).toStringAsFixed(1)}%)';
      });

      // Hapus file temporary
      await File(profilePhotoPath).delete();
      await File(photo.path).delete();
      await croppedCameraFace.delete();
      await croppedProfileFace.delete();
    } catch (e) {
      print('Error during face validation: $e');
      setState(() {
        _isValidated = false;
        _validationMessage = 'Error during validation: \\${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget _buildValidationFeedback() {
    if (_validationMessage == null) return SizedBox.shrink();
    Color bgColor;
    IconData icon;
    if (_isProcessing) {
      bgColor = Colors.blueAccent;
      icon = Icons.info_outline;
    } else if (_isValidated == true) {
      bgColor = Colors.green;
      icon = Icons.check_circle_outline;
    } else {
      bgColor = Colors.red;
      icon = Icons.error_outline;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: bgColor, size: 24),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _validationMessage!,
              style: TextStyle(color: bgColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceOverlay() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Lingkaran transparan
            Container(
              width: 260,
              height: 340,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color:
                      _isValidated == null
                          ? Colors.white
                          : _isValidated!
                          ? Colors.green
                          : Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(130),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CameraPreview(_controller!),
                  // Overlay judul dan subjudul
                  Positioned(
                    top: 32,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: const [
                        Text(
                          'Scan Your Face',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 8, color: Colors.black26),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Find proper lighting source\nfor best result',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(blurRadius: 8, color: Colors.black26),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Overlay lingkaran dan ikon wajah
                  _buildFaceOverlay(),
                  // Tombol back di pojok kiri atas, selalu di atas kamera
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            // Feedback validasi
            _buildValidationFeedback(),
            // Tombol dinamis di bawah
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isProcessing
                        ? null
                        : (_isValidated == true
                            ? _onValidationSuccess
                            : _validateFace),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isValidated == true
                          ? Colors.green
                          : const Color(0xFFFF4D6D),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child:
                    _isProcessing
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          _isValidated == true ? 'Verified' : 'Scan My Face',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
