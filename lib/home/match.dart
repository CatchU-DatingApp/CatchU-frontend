import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class MatchPage extends StatefulWidget {
  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  List<int> expandedIndices = [];

  final List<Map<String, String>> messages = [
    {
      'name': 'Valdez',
      'message': 'Aku orangnya baik banget sampai a...',
      'image': 'assets/images/3_1.jpg',
      'instagram': 'valdezbrz',
      'facebook': 'valdezb',
      'twitter': 'deculein',
      'line': 'vlebnia245',
    },
    {
      'name': 'Keilaa',
      'message': 'janda anak 10',
      'image': 'assets/images/3_2.jpg',
      'instagram': 'loifu6969',
      'facebook': 'loifu6969',
      'twitter': 'loifu6969',
      'line': 'loifu6969',
    },
    {
      'name': 'Mikaela',
      'message': 'aku pacarnya kuv',
      'image': 'assets/images/3_3.jpg',
      'instagram': 'loifu6969',
      'facebook': 'loifu6969',
      'twitter': 'loifu6969',
      'line': 'loifu6969',
    },
    {
      'name': 'kuvukiland',
      'message': 'Asli kendal 😂',
      'image': 'assets/images/jawa.png',
      'instagram': 'loifu6969',
      'facebook': 'loifu6969',
      'twitter': 'loifu6969',
      'line': 'loifu6969',
    },
    {
      'name': 'Muhammad Roif Baktiar',
      'message': 'Aku orangnya baik banget sampai a...',
      'image': 'assets/images/5.jpg',
      'instagram': 'loifu6969',
      'facebook': 'loifu6969',
      'twitter': 'loifu6969',
      'line': 'loifu6969',
    },
  ];

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
      case 'line':
        url = 'https://line.me/R/ti/p/~$username';
        break;
      default:
        url = '';
    }

    final uri = Uri.parse(url);

    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!success) {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Exception launching $url: $e');
    }
  }

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {
      // Update your messages list here if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundHomepageCatchU.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: 80,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'MatchU',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Perfect match with you!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xFFFF426D),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isExpanded = expandedIndices.contains(index);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(22),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              msg['name']!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              msg['message']!,
                                              style: TextStyle(
                                                color: const Color.fromARGB(
                                                  255,
                                                  86,
                                                  86,
                                                  86,
                                                ),
                                                fontSize: 12,
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
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
                  onTap:
                      () => _launchSocialMedia(
                        'instagram',
                        profile['instagram']!,
                      ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.facebook,
                  username: '@${profile['facebook']}',
                  backgroundColor: Color(0xFFFF426D),
                  onTap:
                      () =>
                          _launchSocialMedia('facebook', profile['facebook']!),
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
                  onTap:
                      () => _launchSocialMedia('twitter', profile['twitter']!),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.phone_iphone,
                  username: '@${profile['line']}',
                  backgroundColor: Color(0xFFFF426D),
                  onTap: () => _launchSocialMedia('line', profile['line']!),
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
          borderRadius: BorderRadius.circular(10),
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
