import 'package:flutter/material.dart';
import 'profile.dart';
import 'chat.dart';

class ProfileData {
  final String name;
  final String image;
  final String distance;
  final String bio;
  final String faculty;
  final List<String> interests;

  ProfileData({
    required this.name,
    required this.image,
    required this.distance,
    this.bio = 'No bio available',
    this.faculty = 'Unspecified',
    this.interests = const [],
  });
}

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _swipeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  int _currentProfileIndex = 0;
  bool _isAnimating = false;

  final ScrollController _scrollController = ScrollController();

  final List<ProfileData> _profiles = [
    ProfileData(
      name: 'Alice',
      image: 'assets/images/1.jpg',
      distance: '2 km',
      bio: 'Loves hiking and photography.',
      faculty: 'Informatics',
      interests: ['Hiking', 'Photography', 'Coding'],
    ),
    ProfileData(
      name: 'Bob',
      image: 'assets/images/2.jpg',
      distance: '5 km',
      bio: 'Enjoys painting and jazz music.',
      faculty: 'Art',
      interests: ['Painting', 'Jazz', 'Design'],
    ),
    ProfileData(
      name: 'Clara',
      image: 'assets/images/3.jpg',
      distance: '1.2 km',
      bio: 'Tech enthusiast and dog lover.',
      faculty: 'Fakultas Seni',
      interests: ['Tech', 'Dogs', 'Gaming'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentProfileIndex = (_currentProfileIndex + 1) % _profiles.length;
          _isAnimating = false;
          _swipeController.reset();
          _scrollController.jumpTo(0); // Reset scroll to top
        });
      }
    });
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
    setState(() => _currentIndex = index);
  }

  void _swipeLeft() {
    if (_isAnimating) return;
    _scrollController.jumpTo(0); // Reset scroll before swipe
    setState(() => _isAnimating = true);
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: -0.3,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));
    _swipeController.forward();
  }

  void _swipeRight() {
    if (_isAnimating) return;
    _scrollController.jumpTo(0); // Reset scroll before swipe
    setState(() => _isAnimating = true);
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.0, 0.0),
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));
    _swipeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = _profiles[_currentProfileIndex];
    final nextProfile =
        _profiles[(_currentProfileIndex + 1) % _profiles.length];
    final nextNextProfile =
        _profiles[(_currentProfileIndex + 2) % _profiles.length];

    final screenHeight = MediaQuery.of(context).size.height;
    final cardTopOffset = 110.0;
    final cardBottomOffset = 70.0;
    final cardHeight = screenHeight - cardTopOffset - cardBottomOffset;

    return Scaffold(
      backgroundColor: Color(0xFFFDF7F6),
      body: Stack(
        children: [
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
          Padding(
            padding: EdgeInsets.only(top: cardTopOffset),
            child: SizedBox(
              height: cardHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: Transform.translate(
                      offset: Offset(0, -30),
                      child: _buildProfileCard(nextNextProfile, cardHeight),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: Transform.translate(
                      offset: Offset(0, -15),
                      child: _buildProfileCard(nextProfile, cardHeight),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _swipeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset:
                            _slideAnimation.value *
                            MediaQuery.of(context).size.width,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: _buildProfileCard(currentProfile, cardHeight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() {}),
            child: _actionButton(
              icon: Icons.clear,
              iconColor: Colors.red,
              shadowColor: Colors.redAccent.withOpacity(0.4),
            ),
            onTap: _swipeLeft,
          ),
          SizedBox(width: 100),
          GestureDetector(
            onTapDown: (_) => setState(() {}),
            child: _actionButton(
              icon: Icons.favorite,
              iconColor: Colors.pink,
              shadowColor: Colors.pinkAccent.withOpacity(0.4),
            ),
            onTap: _swipeRight,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  Widget _buildProfileCard(ProfileData profile, double cardHeight) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 520,
        height: cardHeight,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 0.63,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    profile.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          profile.distance,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.school, size: 16, color: Colors.pinkAccent),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.faculty,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Text(
                      'About Me',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      profile.bio,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Interests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          profile.interests
                              .map((interest) => _interestTag(interest))
                              .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _interestTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.5), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.pinkAccent,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color iconColor,
    required Color shadowColor,
  }) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: 0.7,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: shadowColor, blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: Center(child: Icon(icon, color: iconColor, size: 32)),
      ),
    );
  }
}
