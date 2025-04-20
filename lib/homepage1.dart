import 'package:flutter/material.dart';
import 'profile.dart';
import 'chat.dart';
import 'dart:math';

// Model untuk data profil
class ProfileData {
  final String name;
  final String image;
  final String distance;
  final int notificationCount;

  ProfileData({
    required this.name,
    required this.image,
    required this.distance,
    required this.notificationCount,
  });
}

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _swipeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  int _currentProfileIndex = 0;
  bool _isAnimating = false;

  // Dummy profile data
  final List<ProfileData> _profiles = [
    ProfileData(
      name: 'Rohini',
      image: 'assets/images/jawa.png',
      distance: '10 miles away',
      notificationCount: 2,
    ),
    ProfileData(
      name: 'Aisha',
      image: 'assets/images/1.jpg',
      distance: '5 miles away',
      notificationCount: 1,
    ),
    ProfileData(
      name: 'Priya',
      image: 'assets/images/2.jpg',
      distance: '7 miles away',
      notificationCount: 3,
    ),
    ProfileData(
      name: 'Zara',
      image: 'assets/images/3.jpg',
      distance: '12 miles away',
      notificationCount: 0,
    ),
    ProfileData(
      name: 'Mei',
      image: 'assets/images/5.jpg',
      distance: '3 miles away',
      notificationCount: 5,
    ),
    ProfileData(
      name: 'Sofia',
      image: 'assets/images/jawa.png',
      distance: '8 miles away',
      notificationCount: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
    
    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentProfileIndex = (_currentProfileIndex + 1) % _profiles.length;
          _isAnimating = false;
          _swipeController.reset();
        });
      }
    });
  }

  @override
  void dispose() {
    _swipeController.dispose();
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

    setState(() {
      _currentIndex = index;
    });
  }

  void _swipeLeft() {
    if (_isAnimating) return; // Prevent multiple swipes while animating
    
    setState(() {
      _isAnimating = true;
    });
    
    // Update animation parameters for left swipe
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-3.0, 0.2), // Move left and slightly down
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: -0.3, // Rotate counter-clockwise
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
    
    // Start the animation
    _swipeController.forward();
  }

  void _swipeRight() {
    if (_isAnimating) return; // Prevent multiple swipes while animating
    
    setState(() {
      _isAnimating = true;
    });
    
    // Update animation parameters for right swipe
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(3.0, 0.2), // Move right and slightly down
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3, // Rotate clockwise
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
    
    // Start the animation
    _swipeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Get current profile and next profiles for stack effect
    final currentProfile = _profiles[_currentProfileIndex];
    final nextProfileIndex = (_currentProfileIndex + 1) % _profiles.length;
    final nextProfile = _profiles[nextProfileIndex];
    final nextNextProfileIndex = (_currentProfileIndex + 2) % _profiles.length;
    final nextNextProfile = _profiles[nextNextProfileIndex];

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

              // Stack of Profile Cards with animations
              SizedBox(
                height: 450, // Fixed height for card stack area
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Third card (bottom of stack)
                    Transform.scale(
                      scale: 0.8, // Even smaller
                      child: Transform.translate(
                        offset: Offset(0, -30), // Even higher
                        child: Opacity(
                          opacity: 0.4,
                          child: _buildProfileCard(nextNextProfile),
                        ),
                      ),
                    ),
                    
                    // Second card (middle of stack)
                    Transform.scale(
                      scale: 0.9, // Slightly smaller
                      child: Transform.translate(
                        offset: Offset(0, -15), // Slightly higher
                        child: Opacity(
                          opacity: 0.7,
                          child: _buildProfileCard(nextProfile),
                        ),
                      ),
                    ),
                    
                    // Current card with animation (top of stack)
                    AnimatedBuilder(
                      animation: _swipeController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _slideAnimation.value * MediaQuery.of(context).size.width,
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildProfileCard(currentProfile),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _swipeLeft,
                      child: _actionButton(
                        icon: Icons.clear,
                        iconColor: Colors.red,
                        shadowColor: Colors.redAccent.withOpacity(0.4),
                      ),
                    ),
                    GestureDetector(
                      onTap: _swipeRight,
                      child: _actionButton(
                        icon: Icons.favorite,
                        iconColor: Colors.pink,
                        shadowColor: Colors.pinkAccent.withOpacity(0.4),
                      ),
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
          
          // Optional: Like/Dislike indicators during swipe
          _isAnimating ? AnimatedBuilder(
            animation: _swipeController,
            builder: (context, child) {
              // Show like indicator when swiping right
              if (_slideAnimation.value.dx > 0.5) {
                return Positioned(
                  top: 250,
                  right: 40,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'LIKE',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                );
              }
              
              // Show dislike indicator when swiping left
              if (_slideAnimation.value.dx < -0.5) {
                return Positioned(
                  top: 250,
                  left: 40,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NOPE',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                );
              }
              
              return SizedBox.shrink();
            },
          ) : SizedBox.shrink(),
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

  Widget _buildProfileCard(ProfileData profile) {
    return Stack(
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
                    profile.image,
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
                        profile.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            profile.distance,
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(width: 8),
                          if (profile.notificationCount > 0)
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${profile.notificationCount}',
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