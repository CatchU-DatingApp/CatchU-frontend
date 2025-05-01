import 'package:flutter/material.dart';


class ProfileData {
  final String name;
  final List<String> images; // Changed from single image to list of images
  final String distance;
  final String bio;
  final String faculty;
  final List<String> interests;

  ProfileData({
    required this.name,
    required this.images, // Now a list
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
  late AnimationController _swipeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  int _currentProfileIndex = 0;
  bool _isAnimating = false;
  bool _showDetailView = false;
  ProfileData? _selectedProfile;
  Offset _currentSlide = Offset.zero;

  // Track current image index for each profile
  Map<int, int> _currentImageIndices = {};
  final ScrollController _scrollController = ScrollController();

  final List<ProfileData> _profiles = [
    ProfileData(
      name: 'Alice',
      images: [
        'assets/images/1_1.jpg',
        'assets/images/1_2.jpg',
        'assets/images/1_3.jpg',
        'assets/images/1_4.jpg',
      ],
      distance: '2 km',
      bio: 'Loves hiking and photography.',
      faculty: 'Informatics',
      interests: ['Hiking', 'Photography', 'Coding'],
    ),
    ProfileData(
      name: 'Bob',
      images: [
        'assets/images/2_1.jpg',
        'assets/images/2_2.jpg',
        'assets/images/2_3.jpg',
      ],
      distance: '5 km',
      bio: 'Enjoys painting and jazz music.',
      faculty: 'Art',
      interests: ['Painting', 'Jazz', 'Design'],
    ),
    ProfileData(
      name: 'Clara',
      images: [
        'assets/images/3_1.jpg',
        'assets/images/3_2.jpg',
        'assets/images/3_3.jpg',
        'assets/images/3_4.jpg',
        'assets/images/3_5.jpg',
        'assets/images/3_6.jpg',
      ],
      distance: '1.2 km',
      bio: 'Tech enthusiast and dog lover.',
      faculty: 'Fakultas Seni',
      interests: ['Tech', 'Dogs', 'Gaming'],
    ),
  ];

  double _dragStartX = 0;
  double _dragUpdateX = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutCubic,
    ));

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentProfileIndex = (_currentProfileIndex + 1) % _profiles.length;
          _isAnimating = false;
          _currentSlide = Offset.zero;
          _swipeController.reset();
        });
      }
    });

    for (int i = 0; i < _profiles.length; i++) {
      _currentImageIndices[i] = 0;
    }
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showProfileDetail(ProfileData profile) {
    setState(() {
      _selectedProfile = profile;
      _showDetailView = true;
    });
  }

  void _hideProfileDetail() {
    setState(() {
      _showDetailView = false;
      _selectedProfile = null;
    });
  }

  void _swipeLeft() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _currentSlide = Offset.zero;
      
      _slideAnimation = Tween<Offset>(
        begin: _currentSlide,
        end: Offset(-1.5, 0),
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOutCubic,
      ));

      _rotationAnimation = Tween<double>(
        begin: 0.0,
        end: -0.2,
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOutCubic,
      ));
    });

    _swipeController.forward(from: 0.0);
  }

  void _swipeRight() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _currentSlide = Offset.zero;
      
      _slideAnimation = Tween<Offset>(
        begin: _currentSlide,
        end: Offset(1.5, 0),
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOutCubic,
      ));

      _rotationAnimation = Tween<double>(
        begin: 0.0,
        end: 0.2,
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOutCubic,
      ));
    });

    _swipeController.forward(from: 0.0);
  }

  // Navigate to next image for the current profile
  void _nextImage() {
    final currentProfile = _profiles[_currentProfileIndex];
    final currentImageIndex = _currentImageIndices[_currentProfileIndex] ?? 0;

    if (currentImageIndex < currentProfile.images.length - 1) {
      setState(() {
        _currentImageIndices[_currentProfileIndex] = currentImageIndex + 1;
      });
    }
  }

  // Navigate to previous image for the current profile
  void _previousImage() {
    final currentImageIndex = _currentImageIndices[_currentProfileIndex] ?? 0;

    if (currentImageIndex > 0) {
      setState(() {
        _currentImageIndices[_currentProfileIndex] = currentImageIndex - 1;
      });
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_isAnimating) return;
    setState(() {
      _isDragging = true;
      _dragStartX = details.localPosition.dx;
      _dragUpdateX = _dragStartX;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isAnimating || !_isDragging) return;
    setState(() {
      _dragUpdateX = details.localPosition.dx;
      _currentSlide = Offset((_dragUpdateX - _dragStartX) / MediaQuery.of(context).size.width, 0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isAnimating || !_isDragging) return;
    final delta = _dragUpdateX - _dragStartX;
    final width = MediaQuery.of(context).size.width;
    
    if (delta.abs() > width * 0.2) { // Swipe threshold 20% of screen width
      if (delta < 0) {
        _swipeLeft();
      } else {
        _swipeRight();
      }
    } else {
      // Reset position if swipe wasn't far enough
      setState(() {
        _currentSlide = Offset.zero;
      });
    }
    _isDragging = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_showDetailView && _selectedProfile != null) {
      return _buildDetailView(_selectedProfile!);
    }

    final currentProfile = _profiles[_currentProfileIndex];
    final nextProfile = _profiles[(_currentProfileIndex + 1) % _profiles.length];

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
            padding: EdgeInsets.only(top: 110, bottom: 100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: _buildMainProfileCard(nextProfile),
                    ),
                    if (!_isAnimating && !_isDragging)
                      SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: _buildMainProfileCard(currentProfile),
                      )
                    else
                      AnimatedBuilder(
                        animation: _swipeController,
                        builder: (context, child) {
                          final offset = _isDragging ? _currentSlide : _slideAnimation.value;
                          final rotation = _isDragging 
                              ? (_currentSlide.dx * 0.2) 
                              : _rotationAnimation.value;
                          
                          return Transform.translate(
                            offset: offset * MediaQuery.of(context).size.width,
                            child: Transform.rotate(
                              angle: rotation,
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: _buildMainProfileCard(currentProfile),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionButton(
            icon: Icons.clear,
            iconColor: Colors.red,
            shadowColor: Colors.redAccent.withOpacity(0.4),
            onTap: _swipeLeft,
          ),
          SizedBox(width: 100),
          _actionButton(
            icon: Icons.favorite,
            iconColor: Colors.pink,
            shadowColor: Colors.pinkAccent.withOpacity(0.4),
            onTap: _swipeRight,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMainProfileCard(ProfileData profile) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onTap: () => _showProfileDetail(profile),
        child: Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                profile.images[0],
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: [0.6, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 30,
                child: Text(
                  profile.name,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: 32),
        ),
      ),
    );
  }

  Widget _buildDetailView(ProfileData profile) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: _hideProfileDetail,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image section with dot indicators
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  // PageView for images
                  PageView.builder(
                    itemCount: profile.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndices[_currentProfileIndex] = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        profile.images[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  // Dot indicators aligned with back button
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 56, // Same height as AppBar
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          profile.images.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentImageIndices[_currentProfileIndex]
                                  ? const Color.fromARGB(255, 250, 60, 60)
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Profile information in white container
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
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
                  SizedBox(height: 16),
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
                    children: profile.interests
                        .map((interest) => _interestTag(interest))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
