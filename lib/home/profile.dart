import 'package:flutter/material.dart';
import 'chat.dart';
import 'homepage1.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  void _showInterestSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        List<String> tempSelected = List.from(selectedInterests);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Interests (Max 3)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        interests.map((interest) {
                          final label = interest['label'];
                          final icon = interest['icon'];
                          final isSelected = tempSelected.contains(label);

                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  tempSelected.remove(label);
                                } else {
                                  if (tempSelected.length < 3) {
                                    tempSelected.add(label);
                                  }
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.pink[400]
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.pink.shade100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    size: 18,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.pink[400],
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedInterests = List.from(tempSelected);
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? tempSelectedFaculty = selectedFaculty;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Faculty",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        faculties.map((faculty) {
                          final isSelected = tempSelectedFaculty == faculty;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (tempSelectedFaculty == faculty) {
                                  tempSelectedFaculty = null;
                                } else {
                                  tempSelectedFaculty = faculty;
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.pink[400]
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.pink.shade100),
                              ),
                              child: Text(
                                faculty,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedFaculty = tempSelectedFaculty;
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
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

  Widget _buildPhotoSlot({String? imagePath}) {
    return Container(
      decoration:
          imagePath != null
              ? ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
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
      child:
          imagePath == null
              ? Center(
                child: Icon(
                  Icons.add,
                  color: const Color(0xFFFF375F),
                  size: 32,
                ),
              )
              : null,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.06;
    final contentWidth = screenWidth - (horizontalPadding * 2);
    final photoSize = (contentWidth - 32) / 3;

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
                Text(
                  'Profile',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: screenWidth * 0.09,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Container(
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
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Text(
                      '${(profileCompletion * 100).toInt()}% complete',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Photos',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'pick some that show the true you.',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: photoSize,
                      height: photoSize,
                      child: _buildPhotoSlot(
                        imagePath: 'assets/images/jawa.png',
                      ),
                    ),
                    SizedBox(
                      width: photoSize,
                      height: photoSize,
                      child: _buildPhotoSlot(),
                    ),
                    SizedBox(
                      width: photoSize,
                      height: photoSize,
                      child: _buildPhotoSlot(),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: photoSize,
                      height: photoSize,
                      child: _buildPhotoSlot(),
                    ),
                    SizedBox(
                      width: photoSize,
                      height: photoSize,
                      child: _buildPhotoSlot(),
                    ),
                    SizedBox(
                      width: photoSize,
                      height: photoSize,
                      child: _buildPhotoSlot(),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Bio',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Write a fun and punchy intro.',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
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
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Interest',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Get specific about the things you love.',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
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
                                            color: Colors.pink,
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
                Text(
                  'Faculty',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Time to flex your faculty with pride.',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
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
                Text(
                  'Social URLs',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Show us where you’re hanging out online!.',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
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
