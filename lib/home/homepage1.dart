import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';


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
  bool _isCancellingSwipe = false;
  ProfileData? _selectedProfile;
  Offset _currentSlide = Offset.zero;
  final ValueNotifier<int> _currentImageIndex = ValueNotifier<int>(0);

  List<ProfileData> _profiles = [];
  bool _isLoadingProfiles = true;
  String? _profilesError;

  // Tambahkan variabel state untuk button
  double _loveScale = 1.0;
  double _xScale = 1.0;
  bool _loveActive = false;
  bool _xActive = false;

  // Tambahkan variabel swipe agar error hilang
  double _dragStartX = 0;
  double _dragStartY = 0;
  double _dragUpdateX = 0;
  double _dragUpdateY = 0;
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
          if (!_isCancellingSwipe && _profiles.isNotEmpty) {
            _currentProfileIndex = (_currentProfileIndex + 1) % _profiles.length;
          }
          _isAnimating = false;
          _currentSlide = Offset.zero;
          _swipeController.reset();
          _isCancellingSwipe = false;  // Reset the flag
        });
      }
    });

    _fetchProfilesFromFirebase();
  }

  Future<void> _fetchProfilesFromFirebase() async {
    setState(() {
      _isLoadingProfiles = true;
      _profilesError = null;
    });
    try {
      print('Fetching profiles from Firestore...');
      // Cek inisialisasi Firebase
      if (FirebaseFirestore.instance == null) {
        throw Exception('Firebase belum diinisialisasi. Pastikan Firebase.initializeApp() sudah dipanggil di main.dart');
      }
      final snapshot = await FirebaseFirestore.instance.collection('Users').limit(20).get().timeout(Duration(seconds: 7), onTimeout: () {
        throw Exception('Timeout: Gagal mengambil data user dari server.');
      });
      if (snapshot.docs == null) {
        throw Exception('Gagal mengambil data user: snapshot.docs null');
      }
      print('Fetched \\${snapshot.docs.length} user(s)');
      final List<ProfileData> profiles = [];
      for (var doc in snapshot.docs) {
        try {
          profiles.add(ProfileData(
            name: doc.data()['nama'] ?? '',
            images: List<String>.from(doc.data()['photos'] ?? []),
            distance: doc.data()['distance'] ?? '',
            bio: doc.data()['bio'] ?? '',
            faculty: doc.data()['faculty'] ?? '',
            interests: List<String>.from(doc.data()['interest'] ?? []),
          ));
        } catch (e) {
          print('Error parsing user doc id=\${doc.id}: $e');
        }
      }
      print('Parsed \\${profiles.length} valid user(s)');
      if (profiles.isEmpty) {
        profiles.add(ProfileData(
          name: 'No User',
          images: [],
          distance: '-',
          bio: 'No user data found.',
          faculty: '-',
          interests: [],
        ));
      }
      setState(() {
        _profiles = profiles;
        _isLoadingProfiles = false;
      });
    } catch (e) {
      print('Error fetching profiles: $e');
      setState(() {
        _profilesError = 'Gagal mengambil data user: $e';
        _isLoadingProfiles = false;
      });
    }
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _showProfileDetail(ProfileData profile) {
    // Selalu mulai dari image pertama saat membuka detail
    _currentImageIndex.value = 0;
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return _buildDetailView(profile);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating) return;
    setState(() {
      _isDragging = true;
      _dragStartX = details.localPosition.dx;
      _dragStartY = details.localPosition.dy;
      _dragUpdateX = _dragStartX;
      _dragUpdateY = _dragStartY;
      _currentSlide = Offset.zero;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating || !_isDragging) return;
    
    final deltaX = details.localPosition.dx - _dragStartX;
    final deltaY = details.localPosition.dy - _dragStartY;
    final resistance = 0.5;
    final normalizedDeltaX = deltaX * resistance;
    final normalizedDeltaY = deltaY * resistance;
    
    setState(() {
      _dragUpdateX = details.localPosition.dx;
      _dragUpdateY = details.localPosition.dy;
      _currentSlide = Offset(
        normalizedDeltaX / MediaQuery.of(context).size.width,
        normalizedDeltaY / MediaQuery.of(context).size.height
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating || !_isDragging) return;
    
    final velocityX = details.velocity.pixelsPerSecond.dx;
    final velocityY = details.velocity.pixelsPerSecond.dy;
    final deltaX = _dragUpdateX - _dragStartX;
    final deltaY = _dragUpdateY - _dragStartY;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    bool shouldCompleteSwipe = false;
    
    if (velocityX.abs() > 2000 || velocityY.abs() > 2000) {
      shouldCompleteSwipe = true;
    } else if (deltaX.abs() > width * 0.15 || deltaY.abs() > height * 0.15) {
      shouldCompleteSwipe = true;
    }
    
    if (shouldCompleteSwipe) {
      _isCancellingSwipe = false;
      
      // Calculate the direction of the swipe
      final angle = math.atan2(deltaY, deltaX);
      final distance = math.sqrt(deltaX * deltaX + deltaY * deltaY);
      
      // Determine the target offset based on the angle
      final targetOffset = Offset(
        math.cos(angle) * 1.5,
        math.sin(angle) * 1.5
      );
      
      setState(() {
        _isAnimating = true;
        
        _slideAnimation = Tween<Offset>(
          begin: _currentSlide,
          end: targetOffset,
        ).animate(CurvedAnimation(
          parent: _swipeController,
          curve: Curves.easeOut,
        ));

        // Add rotation based on the swipe direction
        _rotationAnimation = Tween<double>(
          begin: _currentSlide.dx * 0.2,
          end: targetOffset.dx * 0.2,
        ).animate(CurvedAnimation(
          parent: _swipeController,
          curve: Curves.easeOut,
        ));
      });

      _swipeController.forward(from: 0.0);
    } else {
      setState(() {
        _isAnimating = true;
        _currentSlide = Offset.zero;
        _isCancellingSwipe = true;
        
        _slideAnimation = Tween<Offset>(
          begin: Offset(
            (_dragUpdateX - _dragStartX) / width,
            (_dragUpdateY - _dragStartY) / height
          ),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _swipeController,
          curve: Curves.easeOut,
        ));

        _rotationAnimation = Tween<double>(
          begin: (_dragUpdateX - _dragStartX) / width * 0.2,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _swipeController,
          curve: Curves.easeOut,
        ));

        _swipeController.forward(from: 0.0).then((_) {
          if (mounted) {
            setState(() {
              _isAnimating = false;
            });
          }
        });
      });
    }
    
    _isDragging = false;
    _dragStartX = 0;
    _dragStartY = 0;
    _dragUpdateX = 0;
    _dragUpdateY = 0;
  }

  void _swipeLeft() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      
      _slideAnimation = Tween<Offset>(
        begin: _currentSlide,
        end: Offset(-1.5, 0),
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOut,
      ));

      _rotationAnimation = Tween<double>(
        begin: _currentSlide.dx * 0.2,
        end: -0.2,
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOut,
      ));
    });

    _swipeController.forward(from: 0.0);
  }

  void _swipeRight() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      
      _slideAnimation = Tween<Offset>(
        begin: _currentSlide,
        end: Offset(1.5, 0),
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOut,
      ));

      _rotationAnimation = Tween<double>(
        begin: _currentSlide.dx * 0.2,
        end: 0.2,
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOut,
      ));
    });

    _swipeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_showDetailView && _selectedProfile != null) {
      return _buildDetailView(_selectedProfile!);
    }

    if (_isLoadingProfiles) {
      return Scaffold(
        backgroundColor: Color(0xFFFDF7F6),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_profilesError != null) {
      return Scaffold(
        backgroundColor: Color(0xFFFDF7F6),
        body: Center(child: Text('Error: \n' + (_profilesError ?? 'Unknown error'))),
      );
    }
    if (_profiles.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFFFDF7F6),
        body: Center(child: Text('No users found.')),
      );
    }

    final currentProfile = _profiles[_currentProfileIndex];
    final nextProfile = _profiles[(_currentProfileIndex + 1) % _profiles.length];

    // Calculate button states based on swipe position and animation state
    final swipeProgress = _isDragging ? _currentSlide.dx : 0.0;
    final loveScale = 1.0 + (swipeProgress > 0 ? swipeProgress * 0.5 : 0.0);
    final loveActive = _isDragging && swipeProgress > 0;
    final xScale = 1.0 + (swipeProgress < 0 ? swipeProgress.abs() * 0.5 : 0.0);
    final xActive = _isDragging && swipeProgress < 0;

    return Scaffold(
      backgroundColor: Color(0xFFFDF7F6),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundHomepageCatchU.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
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
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionButton(
            icon: Icons.clear,
            iconColor: xActive ? Colors.white : Colors.pink,
            backgroundColor: xActive ? Colors.pink : Colors.white,
            shadowColor: Colors.pink,
            scale: xScale,
            onTap: () => _swipeLeft(),
          ),
          SizedBox(width: 100),
          _actionButton(
            icon: Icons.favorite,
            iconColor: loveActive ? Colors.white : Colors.pink,
            backgroundColor: loveActive ? Colors.pink : Colors.white,
            shadowColor: Colors.pink,
            scale: loveScale,
            onTap: () => _swipeRight(),
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
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTap: () => _showProfileDetail(profile),
        child: Hero(
          tag: 'profile-${profile.name}',
          child: Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                profile.images.isNotEmpty
                  ? Image.network(
                      profile.images[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 80, color: Colors.grey),
                    )
                  : Container(color: Colors.grey[300], child: Icon(Icons.person, size: 80, color: Colors.grey)),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(1),
                      ],
                      stops: [0.6, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            profile.distance,
                            style: TextStyle(
                              fontSize: 16,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    double scale = 1.0,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'profile-${profile.name}',
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Stack(
                  children: [
                    profile.images.isNotEmpty
                      ? PageView.builder(
                          itemCount: profile.images.length,
                          onPageChanged: (index) {
                            _currentImageIndex.value = index;
                          },
                          controller: PageController(
                            initialPage: _currentImageIndex.value,
                          ),
                          itemBuilder: (context, index) {
                            return Image.network(
                              profile.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 80, color: Colors.grey),
                            );
                          },
                        )
                      : Container(color: Colors.grey[300], child: Icon(Icons.person, size: 80, color: Colors.grey)),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 56,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: ValueListenableBuilder<int>(
                          valueListenable: _currentImageIndex,
                          builder: (context, currentIndex, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                profile.images.length,
                                (index) => Container(
                                  margin: EdgeInsets.symmetric(horizontal: 3),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == currentIndex
                                        ? const Color(0xFFFF375F)
                                        : Colors.white.withOpacity(0.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
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
            ),
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
