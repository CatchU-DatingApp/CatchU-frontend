import 'package:flutter/material.dart';
import 'profile.dart';
import 'chat.dart';


class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF7F6),
      body: Stack(
        children: [
          // Pink background header
          Container(
            height: 380,
            decoration: BoxDecoration(
              color: Color(0xFFFF375F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              SizedBox(height: 150), 

              // Profile Card
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 20,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: 300,
                        height: 400,
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: 320,
                      height: 420,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/jawa.png',
                              height: 340,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rohini',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '10 miles away',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '2',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Spacer(),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionButton(
                      icon: Icons.clear,
                      iconColor: Colors.red,
                      shadowColor: Colors.redAccent.withOpacity(0.4),
                    ),
                    _actionButton(
                      icon: Icons.favorite,
                      iconColor: Colors.pink,
                      shadowColor: Colors.pinkAccent.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Positioned header text "Discover"
          Positioned(
            top: 50,
            left: 16,
            child: Text(
              'Discover',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
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

  Widget _actionButton({
    required IconData icon,
    required Color iconColor,
    required Color shadowColor,
  }) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: 32),
      ),
    );
  }
}
