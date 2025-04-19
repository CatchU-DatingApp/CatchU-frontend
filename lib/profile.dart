import 'package:flutter/material.dart';
import 'chat.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 2;

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pop(context); // Balik ke DiscoverPage
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCF9F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // Profile Info
            SizedBox(height: 12),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/profile_pic.png'),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, size: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Rahul',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Delhi NCR',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),

            // About Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 32,
                    thickness: 1,
                    color: Colors.pink.shade100,
                  ),
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Full Name', 'Rahul Roy'),
                  _buildInfoRow('Email', 'rahul1988@gmail.com'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildInfoRow('Following', '21 Friends')),
                      SizedBox(width: 20),
                      Expanded(child: _buildInfoRow('Follower', '11 Friends')),
                    ],
                  ),
                  _buildInfoRow('Social URL', 'Facebook.com/rahul****'),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}
