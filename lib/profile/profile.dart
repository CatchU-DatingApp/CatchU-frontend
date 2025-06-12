import 'package:flutter/material.dart';
import '../home/match.dart';
import '../home/homepage1.dart';
import 'profile_completion_popup.dart';
import 'interest_selector.dart';
import 'faculty_selector.dart';
import 'photo_selection.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'face_validation.dart';
import '../services/session_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import '../firebase/firebase_service.dart';
import '../utils/image_helper.dart';

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
  TextEditingController whatsappController = TextEditingController();

  List<String> selectedInterests = [];
  bool _isLoading = true;
  bool isVerified = false;

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
        final uid = user.uid;
        final response = await http.get(Uri.parse('http://192.168.0.102:8080/users/$uid'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (mounted) {
            setState(() {
              bioController.text = data['bio'] ?? '';
              facebookController.text = data['facebook'] ?? '';
              instagramController.text = data['instagram'] ?? '';
              xController.text = data['x'] ?? '';
              whatsappController.text = data['whatsapp'] ?? '';
              selectedInterests = List<String>.from(data['interest'] ?? []);
              selectedFaculty = data['faculty'];
              isVerified = data['verified'] == true;

              uploadedImages = [];
              _preloadImages(List<String>.from(data['photos'] ?? []));

              profileItems['Photos']!['completed'] = (data['photos'] as List?)?.length ?? 0;
              profileItems['Interest']!['completed'] = selectedInterests.length;
              profileItems['Bio']!['completed'] = bioController.text.isNotEmpty ? 1 : 0;
              profileItems['Faculty']!['completed'] = selectedFaculty != null ? 1 : 0;

              profileCompletion =
                  (profileItems['Photos']!['completed'] +
                      profileItems['Interest']!['completed'] +
                      profileItems['Bio']!['completed'] +
                      profileItems['Faculty']!['completed']) / 11.0;

              profileCompletionNotifier.value = profileCompletion;
              profileItemsNotifier.value =
              Map<String, Map<String, dynamic>>.from(profileItems);

              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          print("Failed to load user: ${response.statusCode}");
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
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
        final response = await http.post(
          Uri.parse('http://192.168.0.102:8080/users/${user.uid}/photos'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'photoUrl': url}),
        );

        if (response.statusCode != 200) {
          throw Exception('Backend rejected the update: ${response.body}');
        }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum 6 photos allowed.')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    final user = FirebaseAuth.instance.currentUser;

    if (pickedFile != null && user != null) {
      final imageFile = File(pickedFile.path);
      final image = FileImage(imageFile);

      setState(() {
        uploadedImages.add(image);
        profileItems['Photos']!['completed'] = uploadedImages.length;
        profileCompletion = (profileItems['Photos']!['completed'] +
            profileItems['Interest']!['completed'] +
            profileItems['Bio']!['completed'] +
            profileItems['Faculty']!['completed']) /
            11.0;
        profileCompletionNotifier.value = profileCompletion;
        profileItemsNotifier.value =
        Map<String, Map<String, dynamic>>.from(profileItems);
      });

      try {
        // Upload ke Firebase Storage
        final firebaseService = FirebaseService();
        final photoUrl = await firebaseService.uploadPhotoToStorage(
          imageFile,
          'user_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}',
        );

        // Kirim URL ke backend API
        final response = await http.post(
          Uri.parse('http://192.168.0.102:8080/users/${user.uid}/photos'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'photoUrl': photoUrl}),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to update photo to API: ${response.body}');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload photo: $e')),
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
          onTap: image == null
              ? () {
            _showPhotoSelectionModal();
          }
              : null,
          child: Container(
            width: 100,
            height: 100,
            decoration: image != null
                ? ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            )
                : ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 0, color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: image == null
                ? Center(
              child: Icon(
                Icons.add,
                color: const Color(0xFFFF375F),
                size: 32,
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: image is FileImage
                  ? Image(image: image, fit: BoxFit.cover)
                  : ImageHelper.loadCachedImage(
                imageUrl: (image as NetworkImage).url,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
                  // 1. Fetch list photo dari backend
                  final response = await http.get(
                    Uri.parse('http://192.168.0.102:8080/users/${user.uid}/photos'),
                  );

                  if (response.statusCode != 200) {
                    throw Exception('Failed to fetch photos');
                  }

                  List<dynamic> photos = jsonDecode(response.body);
                  if (index >= photos.length) return;

                  final photoUrl = photos[index];

                  // 2. Hapus dari Firebase Storage DULU
                  final firebaseService = FirebaseService();
                  await firebaseService.deletePhotoFromStorage(photoUrl);

                  // 3. Hapus dari backend database
                  final deleteResponse = await http.post(
                    Uri.parse('http://192.168.0.102:8080/users/${user.uid}/photos/delete'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'photoUrl': photoUrl}),
                  );

                  if (deleteResponse.statusCode != 200) {
                    throw Exception('Failed to delete photo in backend: ${deleteResponse.body}');
                  }

                  // 4. Update UI
                  setState(() {
                    uploadedImages.removeAt(index);
                    profileItems['Photos']!['completed'] = uploadedImages.length;
                    profileCompletion = (profileItems['Photos']!['completed'] +
                        profileItems['Interest']!['completed'] +
                        profileItems['Bio']!['completed'] +
                        profileItems['Faculty']!['completed']) /
                        11.0;
                    profileCompletionNotifier.value = profileCompletion;
                    profileItemsNotifier.value =
                    Map<String, Map<String, dynamic>>.from(profileItems);
                  });
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
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }


  Widget _buildSocialMediaInput({
    required String platform,
    required TextEditingController controller,
    required String icon,
  }) {
    String hintText = 'Input username';
    String guideText = 'Enter your username without "@"';

    if (platform == 'WhatsApp') {
      hintText = 'Input phone number';
      guideText = 'Start with country code (e.g. 62812345xxxx)';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
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
                  child: Image.asset(
                    icon,
                    width: 24,
                    height: 24,
                    color: const Color(0xFFFF375F),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) async {
                      try {
                        await _updateUserProfile({
                          platform.toLowerCase(): value,
                        });
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update $platform: $e'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12, top: 4),
            child: Text(
              guideText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
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
      final uid = user.uid;
      final url = Uri.parse('http://192.168.0.102:8080/users/update-fields/$uid');

      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to update profile: ${response.body}');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: $e')),
          );
        }
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
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ),
                                      fontSize: screenWidth * 0.08,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  isVerified
                                      ? OutlinedButton(
                                        onPressed: null,
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          side: BorderSide(color: Colors.blue),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Verified',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.verified,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      )
                                      : OutlinedButton(
                                        onPressed: () {
                                          // Navigate to the FaceValidation page when the button is clicked
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      FaceValidationPhotoPage(),
                                            ),
                                          ).then((_) => _loadUserProfile());
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.blue.shade300,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                        color: const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
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
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ),
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
                                        color: const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
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
                                                      color: const Color(
                                                        0xFFFF375F,
                                                      ),
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
                                        color: const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
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
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ),
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
                                      icon: 'assets/images/facebook.png',
                                    ),
                                    _buildSocialMediaInput(
                                      platform: 'Instagram',
                                      controller: instagramController,
                                      icon: 'assets/images/instagram.png',
                                    ),
                                    _buildSocialMediaInput(
                                      platform: 'X',
                                      controller: xController,
                                      icon: 'assets/images/twitter.png',
                                    ),
                                    _buildSocialMediaInput(
                                      platform: 'WhatsApp',
                                      controller: whatsappController,
                                      icon: 'assets/images/whatsapp.png',
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
    whatsappController.dispose();
    profileCompletionNotifier.dispose();
    profileItemsNotifier.dispose();
    super.dispose();
  }
}
