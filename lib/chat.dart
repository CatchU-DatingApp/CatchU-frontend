import 'package:flutter/material.dart';
import 'profile.dart';
import 'homepage1.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _currentIndex = 1;

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DiscoverPage()),
      );
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Matches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildMatchAvatar('assets/images/1.png', 'Anita'),
                    _buildMatchAvatar('assets/images/2.png', 'Reshma'),
                    _buildMatchAvatar('assets/images/3.png', 'Roma'),
                    _buildMatchAvatar('assets/images/4.png', 'Yami'),
                    _buildMatchAvatar('assets/images/5.png', 'Priti'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Messages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _buildMessageTile(
                      'Anika',
                      'Oh i don\'t like fish 🙈',
                      'assets/images/1.png',
                      unread: 2,
                    ),
                    _buildMessageTile(
                      'Shreya',
                      'Can we go somewhere?',
                      'assets/images/2.png',
                      unread: 1,
                    ),
                    _buildMessageTile(
                      'Lilly',
                      'You: If I were a stop light, I’d turn',
                      'assets/images/3.png',
                    ),
                    _buildMessageTile(
                      'Mona',
                      'See you soon 😉',
                      'assets/images/4.png',
                    ),
                    _buildMessageTile(
                      'Sonia',
                      'Are you serious?!',
                      'assets/images/5.png',
                      unread: 1,
                    ),
                    _buildMessageTile(
                      'Monika ⭐',
                      'You: How about a movie and',
                      'assets/images/6.png',
                    ),
                    _buildMessageTile('Katrina', 'OK', 'assets/images/7.png'),
                    _buildMessageTile(
                      'Kiran',
                      'You: How are you?',
                      'assets/images/8.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildMatchAvatar(String imgPath, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(radius: 28, backgroundImage: AssetImage(imgPath)),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(name, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMessageTile(
    String name,
    String message,
    String imgPath, {
    int unread = 0,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(radius: 28, backgroundImage: AssetImage(imgPath)),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing:
          unread > 0
              ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unread.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
              : null,
    );
  }
}
