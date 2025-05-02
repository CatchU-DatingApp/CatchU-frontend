import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:google_ml_kit/google_ml_kit.dart';
import '../services/ml.dart';

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

  Future<bool> _checkForFace(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector.processImage(inputImage);
      return faces.isNotEmpty;
    } catch (e) {
      print('Error checking for face: $e');
      return false;
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

      // Periksa apakah ada wajah di foto yang diambil
      final hasFace = await _checkForFace(photo.path);
      if (!hasFace) {
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

      // Periksa apakah ada wajah di foto profil
      final hasProfileFace = await _checkForFace(profilePhotoPath);
      if (!hasProfileFace) {
        setState(() {
          _isValidated = false;
          _validationMessage = 'No face detected in the profile photo.';
        });
        await File(profilePhotoPath).delete();
        await File(photo.path).delete();
        return;
      }

      // Dapatkan embedding untuk kedua foto
      final List<double> profileEmbedding = await _faceEmbeddingModel
          .getEmbedding(File(profilePhotoPath))
          .then((value) => value.toList());
      final List<double> capturedEmbedding = await _faceEmbeddingModel
          .getEmbedding(File(photo.path))
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
    } catch (e) {
      print('Error during face validation: $e');
      setState(() {
        _isValidated = false;
        _validationMessage = 'Error during validation: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(_controller!),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          _isValidated == null
                              ? Colors.white
                              : _isValidated!
                              ? Colors.green
                              : Colors.red,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  width: 250,
                  height: 250,
                ),
                if (_validationMessage != null)
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _validationMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _validateFace,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child:
                  _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Validate Face'),
            ),
          ),
        ],
      ),
    );
  }
}
