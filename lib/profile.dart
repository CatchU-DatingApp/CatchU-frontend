import 'package:flutter/material.dart';
import 'chat.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 2;
  double profileCompletion = 0.58;
  TextEditingController bioController = TextEditingController();

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage()));
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildPhotoSlot({String? imagePath}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pink, width: 1.5, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
      ),
      child: imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            )
          : Center(
              child: Icon(Icons.add, color: Colors.pink, size: 32),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCF9F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Title
              Text(
                'Profile',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Profile completion box
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.pink, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${(profileCompletion * 100).toInt()}% complete'),
              ),
              SizedBox(height: 24),

              // Photos
              Text('Photos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('pick some that show the true you.'),
              SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildPhotoSlot(imagePath: 'assets/images/jawa.png'),
                  _buildPhotoSlot(),
                  _buildPhotoSlot(),
                  _buildPhotoSlot(),
                  _buildPhotoSlot(),
                  _buildPhotoSlot(),
                ],
              ),
              SizedBox(height: 24),

              // Bio
              Text('Bio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Write a fun and punchy intro.'),
              SizedBox(height: 8),
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Interest
              Text('Interest', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Get specific about the things you love.'),
              // Tambah section Interest lebih lanjut di sini
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
