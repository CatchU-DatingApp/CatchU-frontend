import 'package:flutter/material.dart';
import 'profile.dart';
import 'homepage1.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _currentIndex = 1;
  int? selectedIndex;

  final List<Map<String, String>> messages = [
    {
      'name': 'Go Yoon Jung',
      'message': 'Oh i don\'t like fish 🙈',
      'image': 'assets/images/1.jpg',
    },
    {
      'name': 'Jeon Jong Seo',
      'message': 'Can we go somewhere?',
      'image': 'assets/images/2.jpg',
    },
    {
      'name': 'Baek Songmin',
      'message': 'You: If I were a stop light, I’d turn',
      'image': 'assets/images/3.jpg',
    },
    {
      'name': 'Orang Kendal',
      'message': 'See you soon 😉',
      'image': 'assets/images/jawa.png',
    },
    {
      'name': 'Orang Arab',
      'message': 'Are you serious?!',
      'image': 'assets/images/5.jpg',
    },
  ];

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

  void _onProfileSelected(int index) {
    setState(() {
      selectedIndex = selectedIndex == index ? null : index;
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
                'Your Match',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isSelected = selectedIndex == index;

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: AssetImage(msg['image']!),
                          ),
                          title: Text(
                            msg['name']!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            msg['message']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _onProfileSelected(index),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          switchInCurve: Curves.easeInOut,
                          child:
                              isSelected
                                  ? Container(
                                    key: ValueKey(index),
                                    margin: EdgeInsets.only(bottom: 12),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.pinkAccent,
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg['name']!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Instagram: @${msg['name']!.toLowerCase().replaceAll(' ', '_')}',
                                          style: TextStyle(
                                            color: Colors.pinkAccent,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Bio: This person is awesome and waiting to chat with you 😉',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
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
}
