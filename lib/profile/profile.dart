import 'package:flutter/material.dart';
import '../home/match.dart';
import '../home/homepage1.dart';
import 'profile_completion_popup.dart';
import 'interest_selector.dart';
import 'faculty_selector.dart';
import 'photo_selection.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'face_validation.dart';
import '../services/session_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import '../firebase/firebase_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  List<ImageProvider> uploadedImages = [];
  double profileCompletion = 0.0;
  TextEditingController bioController = TextEditingController();

  TextEditingController facebookController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController xController = TextEditingController();
  TextEditingController lineController = TextEditingController();

  List<String> selectedInterests = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> interests = [
    {"label": "Reading", "icon": Icons.menu_book},
    {"label": "Photography", "icon": Icons.camera_alt},
    {"label": "Gaming", "icon": Icons.videogame_asset},
    {"label": "Music", "icon": Icons.music_note},
    {"label": "Travel", "icon": Icons.flight},
    {"label": "Painting", "icon": Icons.brush},
    {"label": "Politics", "icon": Icons.how_to_vote},
    {"label": "Charity", "icon": Icons.volunteer_activism},
    {"label": "Cooking", "icon": Icons.restaurant_menu},
    {"label": "Pets", "icon": Icons.pets},
    {"label": "Sports", "icon": Icons.sports_soccer},
    {"label": "Fashion", "icon": Icons.checkroom},
  ];

  String? selectedFaculty;
  final List<String> faculties = [
    'Fakultas Industri Kreatif',
    'Fakultas Komunikasi dan Bisnis',
    'Fakultas Ekonomi dan Bisnis',
    'Fakultas Informatika',
    'Fakultas Teknik Elektro',
    'Fakultas Rekayasa Industri',
    'Fakultas Ilmu Terapan',
  ];

  final Map<String, Map<String, dynamic>> profileItems = {
    'Photos': {'completed': 0, 'total': 6, 'icon': Icons.photo_library},
    'Interest': {'completed': 0, 'total': 3, 'icon': Icons.favorite},
    'Bio': {'completed': 0, 'total': 1, 'icon': Icons.description},
    'Faculty': {'completed': 0, 'total': 1, 'icon': Icons.school},
  };

  final ValueNotifier<double> profileCompletionNotifier = ValueNotifier(0.0);
  final ValueNotifier<Map<String, Map<String, dynamic>>> profileItemsNotifier =
      ValueNotifier({});

  late final StreamSubscription<bool> _keyboardSubscription;
  final FocusNode bioFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    profileItemsNotifier.value = Map<String, Map<String, dynamic>>.from(
      profileItems,
    );
    // Keyboard visibility listener
    _keyboardSubscription = KeyboardVisibilityController().onChange.listen((
      bool visible,
    ) {
      if (!visible) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get(GetOptions(source: Source.serverAndCache));

        if (doc.exists) {
          final data = doc.data()!;

          if (mounted) {
            setState(() {
              bioController.text = data['bio'] ?? '';
              facebookController.text = data['facebook'] ?? '';
              instagramController.text = data['instagram'] ?? '';
              xController.text = data['x'] ?? '';
              lineController.text = data['line'] ?? '';
              selectedInterests = List<String>.from(data['interest'] ?? []);
              selectedFaculty = data['faculty'];

              uploadedImages = [];
              _preloadImages(data['photos'] as List<dynamic>? ?? []);

              profileItems['Photos']!['completed'] =
                  (data['photos'] as List<dynamic>? ?? []).length;
              profileItems['Interest']!['completed'] = selectedInterests.length;
              profileItems['Bio']!['completed'] =
                  bioController.text.isNotEmpty ? 1 : 0;
              profileItems['Faculty']!['completed'] =
                  selectedFaculty != null ? 1 : 0;
              profileCompletion =
                  (profileItems['Photos']!['completed'] +
                      profileItems['Interest']!['completed'] +
                      profileItems['Bio']!['completed'] +
                      profileItems['Faculty']!['completed']) /
                  11.0;
              profileCompletionNotifier.value = profileCompletion;
              profileItemsNotifier
                  .value = Map<String, Map<String, dynamic>>.from(profileItems);

              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _preloadImages(List<dynamic> imageUrls) async {
    List<ImageProvider> images = [];
    for (var url in imageUrls) {
      images.add(NetworkImage(url as String));
    }

    if (mounted) {
      setState(() {
        uploadedImages = images;
      });
    }
  }

  void _showProfileCompletionPopup() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProfileCompletionPopup(
          profileCompletionNotifier: profileCompletionNotifier,
          profileItemsNotifier: profileItemsNotifier,
        );
      },
    ).then((_) {
      // Ensure focus is removed when dialog is closed
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _showInterestSelector() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return InterestSelectorBottomSheet(
          selectedInterests: selectedInterests,
          interests: interests,
          onSave: (updatedInterests) async {
            setState(() {
              selectedInterests = updatedInterests;
              profileItems['Interest']!['completed'] = selectedInterests.length;
              profileCompletion =
                  (profileItems['Photos']!['completed'] +
                      profileItems['Interest']!['completed'] +
                      profileItems['Bio']!['completed'] +
                      profileItems['Faculty']!['completed']) /
                  11.0;
              profileCompletionNotifier.value = profileCompletion;
              profileItemsNotifier
                  .value = Map<String, Map<String, dynamic>>.from(profileItems);
            });
            await _updateUserProfile({'interest': selectedInterests});
          },
        );
      },
    ).then((_) {
      // Ensure focus is removed when modal is closed by any means (including tapping outside)
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _showFacultySelector() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FacultySelectorBottomSheet(
          selectedFaculty: selectedFaculty,
          faculties: faculties,
          onSave: (updatedFaculty) async {
            setState(() {
              selectedFaculty = updatedFaculty;
              profileItems['Faculty']!['completed'] =
                  selectedFaculty != null ? 1 : 0;
              profileCompletion =
                  (profileItems['Photos']!['completed'] +
                      profileItems['Interest']!['completed'] +
                      profileItems['Bio']!['completed'] +
                      profileItems['Faculty']!['completed']) /
                  11.0;
              profileCompletionNotifier.value = profileCompletion;
              profileItemsNotifier
                  .value = Map<String, Map<String, dynamic>>.from(profileItems);
            });
            await _updateUserProfile({'faculty': selectedFaculty});
          },
        );
      },
    ).then((_) {
      // Ensure focus is removed when modal is closed by any means (including tapping outside)
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _showPhotoSelectionModal() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return PhotoSelectionBottomSheet(
          onUploadPhoto: () async {
            Navigator.pop(context); // Tutup bottom sheet dulu
            FocusScope.of(context).unfocus();
            await _pickImageFromGallery();
          },
          onTakePhoto: () async {
            Navigator.pop(context); // Tutup bottom sheet dulu
            FocusScope.of(context).unfocus();
            await _pickImageFromCamera();
          },
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    if (uploadedImages.length >= 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Maximum 6 photos allowed.')));
      return;
    }
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    final user = FirebaseAuth.instance.currentUser;
    if (pickedFile != null && user != null) {
      setState(() {
        uploadedImages.add(FileImage(File(pickedFile.path)));
        profileItems['Photos']!['completed'] = uploadedImages.length;
        profileCompletion =
            (profileItems['Photos']!['completed'] +
                profileItems['Interest']!['completed'] +
                profileItems['Bio']!['completed'] +
                profileItems['Faculty']!['completed']) /
            11.0;
        profileCompletionNotifier.value = profileCompletion;
        profileItemsNotifier.value = Map<String, Map<String, dynamic>>.from(
          profileItems,
        );
      });
      try {
        final firebaseService = FirebaseService();
        final url = await firebaseService.uploadPhotoToStorage(
          File(pickedFile.path),
          'user_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}',
        );
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
              'photos': FieldValue.arrayUnion([url]),
            });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update photos: $e')),
          );
        }
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    if (uploadedImages.length >= 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Maximum 6 photos allowed.')));
      return;
    }
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    final user = FirebaseAuth.instance.currentUser;
    if (pickedFile != null && user != null) {
      setState(() {
        uploadedImages.add(FileImage(File(pickedFile.path)));
        profileItems['Photos']!['completed'] = uploadedImages.length;
        profileCompletion =
            (profileItems['Photos']!['completed'] +
                profileItems['Interest']!['completed'] +
                profileItems['Bio']!['completed'] +
                profileItems['Faculty']!['completed']) /
            11.0;
        profileCompletionNotifier.value = profileCompletion;
        profileItemsNotifier.value = Map<String, Map<String, dynamic>>.from(
          profileItems,
        );
      });
      // Upload ke Firebase Storage, dapatkan URL download, lalu simpan ke Firestore
      try {
        final firebaseService = FirebaseService();
        final url = await firebaseService.uploadPhotoToStorage(
          File(pickedFile.path),
          'user_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}',
        );
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
              'photos': FieldValue.arrayUnion([url]),
            });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update photos: $e')),
          );
        }
      }
    }
  }

  Widget _buildPhotoSlot({ImageProvider<Object>? image, required int index}) {
    final isLastPhoto = uploadedImages.length == 1;
    return Stack(
      children: [
        GestureDetector(
          onTap:
              image == null
                  ? () {
                    _showPhotoSelectionModal();
                  }
                  : null,
          child: Container(
            width: 100,
            height: 100,
            decoration:
                image != null
                    ? ShapeDecoration(
                      image: DecorationImage(image: image, fit: BoxFit.cover),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                    : ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 0,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
            child:
                image == null
                    ? Center(
                      child: Icon(
                        Icons.add,
                        color: const Color(0xFFFF375F),
                        size: 32,
                      ),
                    )
                    : null,
          ),
        ),
        if (image != null && !isLastPhoto)
          Positioned(
            top: 7,
            right: 14,
            child: GestureDetector(
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                try {
                  // Ambil data user terbaru dari Firestore
                  final doc =
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user.uid)
                          .get();
                  List<dynamic> photos = List.from(doc['photos'] ?? []);

                  // Hapus foto dari Storage terlebih dahulu
                  if (index < photos.length) {
                    final photoUrl = photos[index];
                    final firebaseService = FirebaseService();
                    await firebaseService.deletePhotoFromStorage(photoUrl);

                    // Hapus URL dari array
                    photos.removeAt(index);

                    // Update Firestore dengan array baru
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .update({'photos': photos});

                    setState(() {
                      uploadedImages.removeAt(index);
                      profileItems['Photos']!['completed'] =
                          uploadedImages.length;
                      profileCompletion =
                          (profileItems['Photos']!['completed'] +
                              profileItems['Interest']!['completed'] +
                              profileItems['Bio']!['completed'] +
                              profileItems['Faculty']!['completed']) /
                          11.0;
                      profileCompletionNotifier.value = profileCompletion;
                      profileItemsNotifier.value =
                          Map<String, Map<String, dynamic>>.from(profileItems);
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete photo: $e')),
                    );
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(12),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSocialMediaInput({
    required String platform,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      height: 56,
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF375F), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFFFF375F), size: 24),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Input $platform URL',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) async {
                try {
                  await _updateUserProfile({platform.toLowerCase(): value});
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update $platform: $e')),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFFFF375F)),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
      ],
    );
  }

  Future<void> _updateUserProfile(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update(data);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.06;
    final contentWidth = screenWidth - (horizontalPadding * 2);
    final photoSize = (contentWidth - 32) / 3; // Size for each photo slot

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/backgroundHomepageCatchU.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child:
                _isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: const Color(0xFFFF375F),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading profile...',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadUserProfile,
                      color: const Color(0xFFFF375F),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.03),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Profile',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      fontSize: screenWidth * 0.08,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      // Navigate to the FaceValidation page when the button is clicked
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  FaceValidationPhotoPage(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.blue.shade300,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Get Verified',
                                          style: TextStyle(
                                            color: Colors.blue.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.03),
                              GestureDetector(
                                onTap: _showProfileCompletionPopup,
                                child: Container(
                                  width: contentWidth,
                                  height: 56,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 0,
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${(profileCompletion * 100).toInt()}% complete',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: const Color(0xFFFF375F),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.03),
                              _buildSectionHeader(
                                'Photos',
                                'Pick some that show the true you.',
                                profileItems['Photos']!['icon'],
                              ),
                              SizedBox(height: 12),
                              // Photo grid
                              Column(
                                children: List.generate(2, (rowIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(3, (colIndex) {
                                        int index = rowIndex * 3 + colIndex;
                                        return SizedBox(
                                          width: photoSize,
                                          height: photoSize,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: _buildPhotoSlot(
                                              image:
                                                  index < uploadedImages.length
                                                      ? uploadedImages[index]
                                                      : null,
                                              index: index,
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  );
                                }),
                              ),

                              SizedBox(height: screenHeight * 0.03),
                              _buildSectionHeader(
                                'Bio',
                                'Write a fun and punchy intro.',
                                profileItems['Bio']!['icon'],
                              ),
                              SizedBox(height: 12),
                              Container(
                                width: contentWidth,
                                height: screenHeight * 0.15,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 0,
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  focusNode: bioFocusNode,
                                  controller: bioController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(18),
                                    border: InputBorder.none,
                                    hintText:
                                        'Write something about yourself...',
                                  ),
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  onChanged: (value) async {
                                    setState(() {
                                      profileItems['Bio']!['completed'] =
                                          value.isNotEmpty ? 1 : 0;
                                      profileCompletion =
                                          (profileItems['Photos']!['completed'] +
                                              profileItems['Interest']!['completed'] +
                                              profileItems['Bio']!['completed'] +
                                              profileItems['Faculty']!['completed']) /
                                          11.0;
                                      profileCompletionNotifier.value =
                                          profileCompletion;
                                      profileItemsNotifier.value = Map<
                                        String,
                                        Map<String, dynamic>
                                      >.from(profileItems);
                                    });
                                    await _updateUserProfile({'bio': value});
                                  },
                                  autofocus: false,
                                  enableInteractiveSelection: true,
                                  onEditingComplete: () {
                                    // Explicitly unfocus on editing complete
                                    bioFocusNode.unfocus();
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                  onTapOutside: (_) {
                                    // Unfocus when tapped outside
                                    bioFocusNode.unfocus();
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.03),
                              _buildSectionHeader(
                                'Interest',
                                'Get specific about the things you love.',
                                profileItems['Interest']!['icon'],
                              ),
                              SizedBox(height: 12),
                              GestureDetector(
                                onTap: _showInterestSelector,
                                child: Container(
                                  width: contentWidth,
                                  padding: EdgeInsets.all(12),
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 0,
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                                                      shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  ),
                                  child:
                                      selectedInterests.isEmpty
                                          ? Text(
                                            'Tap to choose up to 3 interests',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          )
                                          : Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children:
                                                selectedInterests.map((
                                                  interest,
                                                ) {
                                                  final icon =
                                                      interests.firstWhere(
                                                            (e) =>
                                                                e['label'] ==
                                                                interest,
                                                          )['icon']
                                                          as IconData;
                                                  return Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFF375F),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          icon,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          interest,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.03),
                              _buildSectionHeader(
                                'Faculty',
                                'Time to flex your faculty with pride.',
                                profileItems['Faculty']!['icon'],
                              ),
                              SizedBox(height: 12),
                              GestureDetector(
                                onTap: _showFacultySelector,
                                child: Container(
                                  width: contentWidth,
                                  padding: EdgeInsets.all(12),
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 0,
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                                                      shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  ),
                                  child:
                                      selectedFaculty == null
                                          ? Text(
                                            'Tap to choose your faculty',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          )
                                          : Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF375F),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              selectedFaculty!,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                ),
                              ),

                              // Social Media URLs Section
                              SizedBox(height: screenHeight * 0.03),
                              _buildSectionHeader(
                                'Social URLs',
                                'Show us where you\'re hanging out online!',
                                Icons.link,
                              ),
                              SizedBox(height: 12),
                              Container(
                                width: contentWidth,
                                padding: EdgeInsets.all(12),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 0,
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildSocialMediaInput(
                                      platform: 'Facebook',
                                      controller: facebookController,
                                      icon: Icons.facebook,
                                    ),
                                    _buildSocialMediaInput(
                                      platform: 'Instagram',
                                      controller: instagramController,
                                      icon: Icons.camera_alt,
                                    ),
                                    _buildSocialMediaInput(
                                      platform: 'X',
                                      controller: xController,
                                      icon: Icons.alternate_email,
                                    ),
                                    _buildSocialMediaInput(
                                      platform: 'Line',
                                      controller: lineController,
                                      icon: Icons.chat,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              // Logout Button
                              Center(
                                child: TextButton(
                                  onPressed: () async {
                                    // Clear session
                                    await SessionManager.clearSession();
                                    // Sign out from Firebase Auth
                                    await FirebaseAuth.instance.signOut();
                                    // Sign out from Google Sign-In
                                    final googleSignIn = GoogleSignIn();
                                    await googleSignIn.signOut();
                                    // Navigate to get_started
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/get_started',
                                      (route) => false,
                                    );
                                  },
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _keyboardSubscription.cancel();
    bioFocusNode.dispose();
    bioController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    xController.dispose();
    lineController.dispose();
    profileCompletionNotifier.dispose();
    profileItemsNotifier.dispose();
    super.dispose();
  }
}
