import 'package:flutter/material.dart';
import '../profile/profile.dart';
import 'homepage1.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _currentIndex = 1;
  List<int> expandedIndices = [];

  final List<Map<String, String>> messages = [
    {
      'name': 'Muhammad Roif Baktiar',
      'message': 'Aku orangnya baik banget sampai a...',
      'image': 'assets/images/3_1.jpg',
      'instagram': 'loifu6969',
      'facebook': 'loifu6969',
      'twitter': 'loifu6969',
      'whatsapp': 'loifu6969',
    },
    {
      'name': 'Muhammad Roif Baktiar',
      'message': 'Aku orangnya baik banget sampai a...',
      'image': 'assets/images/3_2.jpg',
      'instagram': 'loifu6969',
      'facebook': 'loifu6969',
      'twitter': 'loifu6969',
      'whatsapp': 'loifu6969',
    },
    {
      'name': 'Muhammad Roif Baktiar',
      'message': 'Aku orangnya baik banget sampai a...',
      'image': 'assets/images/3_3.jpg',
      'instagram': 'loifu6969',
      'facebook': 'loifu6969',
      'twitter': 'loifu6969',
      'whatsapp': 'loifu6969',
    },
    {
      'name': 'Muhammad Roif Baktiar',
      'message': 'Aku orangnya baik banget sampai a...',
      'image': 'assets/images/jawa.png',
      'instagram': 'loifu6969',
      'facebook': 'loifu6969',
      'twitter': 'loifu6969',
      'whatsapp': 'loifu6969',
    },
    {
      'name': 'Muhammad Roif Baktiar',
      'message': 'Aku orangnya baik banget sampai a...',
      'image': 'assets/images/5.jpg',
      'instagram': 'loifu6969',
      'facebook': 'loifu6969',
      'twitter': 'loifu6969',
      'whatsapp': 'loifu6969',
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

  void _toggleExpanded(int index) {
    setState(() {
      if (expandedIndices.contains(index)) {
        expandedIndices.remove(index);
      } else {
        expandedIndices.add(index);
      }
    });
  }

  void _launchSocialMedia(String platform, String username) async {
    String url;
    switch (platform) {
      case 'instagram':
        url = 'https://instagram.com/$username';
        break;
      case 'facebook':
        url = 'https://facebook.com/$username';
        break;
      case 'twitter':
        url = 'https://twitter.com/$username';
        break;
      case 'whatsapp':
        url = 'https://wa.me/$username';
        break;
      default:
        url = '';
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'MatchU',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            Text(
              'Perfect match with you!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isExpanded = expandedIndices.contains(index);

                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.pinkAccent),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _toggleExpanded(index),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  msg['image']!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg['name']!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      msg['message']!,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: SizedBox.shrink(),
                        secondChild: _buildSocialMediaSection(msg),
                        crossFadeState:
                        isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection(Map<String, String> profile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.camera_alt,
                  username: '@${profile['instagram']}',
                  backgroundColor: Color(0xFFFF426D),
                  onTap: () => _launchSocialMedia('instagram', profile['instagram']!),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.facebook,
                  username: '@${profile['facebook']}',
                  backgroundColor: Color(0xFFFF426D),
                  onTap: () => _launchSocialMedia('facebook', profile['facebook']!),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.close,
                  username: '@${profile['twitter']}',
                  backgroundColor: Color(0xFFFF426D),
                  onTap: () => _launchSocialMedia('twitter', profile['twitter']!),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.phone_iphone,
                  username: '@${profile['whatsapp']}',
                  backgroundColor: Color(0xFFFF426D),
                  onTap: () => _launchSocialMedia('whatsapp', profile['whatsapp']!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String username,
    required Color backgroundColor,
    required Function onTap,
  }) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              username,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
