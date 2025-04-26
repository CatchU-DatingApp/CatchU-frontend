import 'package:flutter/material.dart';
import 'chat.dart';
import 'homepage1.dart';
import 'profile_completion_popup.dart';
import 'interest_selector.dart';
import 'faculty_selector.dart';
import 'photo_selection.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';



class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();  // Initialize the ImagePicker
  List<ImageProvider> uploadedImages = [AssetImage('assets/images/jawa.png')];
  int _currentIndex = 2;
  double profileCompletion = 0.58;
  TextEditingController bioController = TextEditingController(
    text: 'baik sekali',
  );

  // Social media URL controllers
  TextEditingController facebookController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController xController = TextEditingController();
  TextEditingController lineController = TextEditingController();

  List<String> selectedInterests = [];

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

  // Profile completion details
  final Map<String, Map<String, dynamic>> profileItems = {
    'Photos': {'completed': 1, 'total': 6, 'icon': Icons.photo_library},
    'Interest': {'completed': 0, 'total': 3, 'icon': Icons.favorite},
    'Bio': {'completed': 0, 'total': 1, 'icon': Icons.description},
    'Faculty': {'completed': 0, 'total': 1, 'icon': Icons.school},
  };

  void _showProfileCompletionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProfileCompletionPopup(
          profileCompletion: profileCompletion,
          profileItems: profileItems,
        );
      },
    );
  }


  void _showInterestSelector() {
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
          onSave: (updatedInterests) {
            setState(() {
              selectedInterests = updatedInterests;
              profileItems['Interest']!['completed'] = selectedInterests.length;
            });
          },
        );
      },
    );
  }


  void _showFacultySelector() {
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
          onSave: (updatedFaculty) {
            setState(() {
              selectedFaculty = updatedFaculty;
              profileItems['Faculty']!['completed'] = selectedFaculty != null ? 1 : 0;
            });
          },
        );
      },
    );
  }


  void _showPhotoSelectionModal() {
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
            await _pickImageFromGallery();
          },
          onTakePhoto: () async {
            Navigator.pop(context); // Tutup bottom sheet dulu
            await _pickImageFromCamera();
          },
        );
      },
    );
  }
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        uploadedImages.add(FileImage(File(pickedFile.path)));
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        uploadedImages.add(FileImage(File(pickedFile.path)));
      });
    }
  }



  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DiscoverPage()),
      );
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatPage()),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildPhotoSlot({ImageProvider<Object>? image}) {
    return GestureDetector(
      onTap: () {
        _showPhotoSelectionModal();
      },
      child: Container(
        decoration: image != null
            ? ShapeDecoration(
          image: DecorationImage(
            image: image,  // Now using ImageProvider instead of String
            fit: BoxFit.cover,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        )
            : ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: const Color(0xFFFF375F)),
            borderRadius: BorderRadius.circular(16),
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
            : null,
      ),
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
        borderRadius: BorderRadius.circular(8),
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
                contentPadding: EdgeInsets.symmetric(vertical: 15),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.06;
    final contentWidth = screenWidth - (horizontalPadding * 2);
    final photoSize = (contentWidth - 32) / 3; // Size for each photo slot

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: screenWidth * 0.09,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.blue.shade300),
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
                          Icon(Icons.verified, color: Colors.blue, size: 16),
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
                          width: 2,
                          color: const Color(0xFFFF375F),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(3, (colIndex) {
                          int index = rowIndex * 3 + colIndex;
                          return SizedBox(
                            width: photoSize,
                            height: photoSize,
                            child: _buildPhotoSlot(
                              image: index < uploadedImages.length
                                  ? uploadedImages[index] // This is expected to be of type ImageProvider
                                  : null,
                            )
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
                        width: 2,
                        color: const Color(0xFFFF375F),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: TextField(
                    controller: bioController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(18),
                      border: InputBorder.none,
                      hintText: 'Write something about yourself...',
                    ),
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        profileItems['Bio']!['completed'] =
                            value.isNotEmpty ? 1 : 0;
                      });
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
                          width: 2,
                          color: const Color(0xFFFF375F),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        selectedInterests.isEmpty
                            ? Text(
                              'Tap to choose up to 3 interests',
                              style: TextStyle(color: Colors.grey[600]),
                            )
                            : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  selectedInterests.map((interest) {
                                    final icon =
                                        interests.firstWhere(
                                              (e) => e['label'] == interest,
                                            )['icon']
                                            as IconData;
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.pink[300],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
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
                                              fontWeight: FontWeight.w600,
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
                          width: 2,
                          color: const Color(0xFFFF375F),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        selectedFaculty == null
                            ? Text(
                              'Tap to choose your faculty',
                              style: TextStyle(color: Colors.grey[600]),
                            )
                            : Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.pink[300],
                                borderRadius: BorderRadius.circular(20),
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
                        width: 2,
                        color: const Color(0xFFFF375F),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

}
