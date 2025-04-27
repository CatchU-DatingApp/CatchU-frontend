import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'face_validation_scan.dart';
//MASIH DEMO, BELUM BISA KONEK KE FIREBASE, MAKA BISA LANGSUNG NEXT UNTUK DEBUGGING
class FaceValidationPhotoPage extends StatefulWidget {
  const FaceValidationPhotoPage({Key? key}) : super(key: key);

  @override
  State<FaceValidationPhotoPage> createState() =>
      _FaceValidationPhotoPageState();
}

class _FaceValidationPhotoPageState extends State<FaceValidationPhotoPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _uploadedImageUrl;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = Uuid();

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
                'Get verified after choosing\nyour best profile photo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => _pickImageFromGallery(),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                      : const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _navigateToScanPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D6D),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_imageFile == null) return;
    setState(() => _isLoading = true);

    try {
      String fileName = '${uuid.v4()}${path.extension(_imageFile!.path)}';
      final storageRef = _storage.ref().child('face_validation/$fileName');
      final uploadTask = storageRef.putFile(_imageFile!);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _uploadedImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      setState(() {
        _uploadedImageUrl = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      print('Upload error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToScanPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FaceValidationScanPage(
          profilePhotoUrl: _uploadedImageUrl ?? '',
        ),
      ),
    );
  }
}
