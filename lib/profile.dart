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
  TextEditingController bioController = TextEditingController(text: 'baik sekali');

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
      decoration: imagePath != null
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
                side: BorderSide(
                  width: 1,
                  color: const Color(0xFFFF375F),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
      child: imagePath == null
          ? Center(
              child: Icon(Icons.add, color: const Color(0xFFFF375F), size: 32),
            )
          : null,
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
                      child: _buildPhotoSlot(imagePath: 'assets/images/jawa.png'),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests.map((interest) {
                    final label = interest['label'];
                    final icon = interest['icon'];
                    final isSelected = selectedInterests.contains(label);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedInterests.contains(label)) {
                            selectedInterests.remove(label);
                          } else {
                            if (selectedInterests.length < 3) {
                              selectedInterests.add(label);
                            }
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.pink[400] : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.pink.shade100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: isSelected ? Colors.white : Colors.pink[400],
                            ),
                            SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
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
