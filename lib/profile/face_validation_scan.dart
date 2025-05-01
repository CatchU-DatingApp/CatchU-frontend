import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/face_recognition_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class FaceValidationScanPage extends StatefulWidget {
  final String profilePhotoUrl;

  const FaceValidationScanPage({Key? key, required this.profilePhotoUrl})
    : super(key: key);

  @override
  State<FaceValidationScanPage> createState() => _FaceValidationScanPageState();
}

class _FaceValidationScanPageState extends State<FaceValidationScanPage> {
  CameraController? _controller;
  late FaceRecognitionService _faceRecognitionService;
  bool _isProcessing = false;
  String? _validationMessage;
  bool? _isValidated;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceRecognitionService = FaceRecognitionService();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<String> _downloadAndSaveProfilePhoto() async {
    final response = await http.get(Uri.parse(widget.profilePhotoUrl));
    final tempDir = await getTemporaryDirectory();
    final tempPath = path.join(tempDir.path, 'profile_photo.jpg');
    await File(tempPath).writeAsBytes(response.bodyBytes);
    return tempPath;
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

      // Download dan simpan foto profil
      final String profilePhotoPath = await _downloadAndSaveProfilePhoto();

      // Dapatkan embedding untuk kedua foto
      final List<double> profileEmbedding = await _faceRecognitionService
          .getFaceEmbedding(profilePhotoPath);
      final List<double> capturedEmbedding = await _faceRecognitionService
          .getFaceEmbedding(photo.path);

      // Bandingkan wajah
      final bool isMatch = _faceRecognitionService.areFacesMatching(
        profileEmbedding,
        capturedEmbedding,
      );

      setState(() {
        _isValidated = isMatch;
        _validationMessage =
            isMatch
                ? 'Face validation successful!'
                : 'Face validation failed. Please try again.';
      });

      // Hapus file temporary
      await File(profilePhotoPath).delete();
      await File(photo.path).delete();
    } catch (e) {
      setState(() {
        _isValidated = false;
        _validationMessage = 'Error: ${e.toString()}';
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
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _validationMessage!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _validateFace,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child:
                  _isProcessing
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Validate Face'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
