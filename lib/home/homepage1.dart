import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/image_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './mainpage.dart'; // Add import for MainPage

class ProfileData {
  final String name;
  final List<String> images; // Changed from single image to list of images
  final String distance;
  final String bio;
  final String faculty;
  final List<String> interests;
  final List<double> location; // Add location field
  final int matchingInterestsCount;
  final String userId;

  ProfileData({
    required this.name,
    required this.images,
    required this.distance,
    this.bio = 'No bio available',
    this.faculty = 'Unspecified',
    this.interests = const [],
    this.location = const [0.0, 0.0], // Default location
    required this.matchingInterestsCount,
    required this.userId,
  });
  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      userId: json['userId'],
      name: json['name'],
      images: List<String>.from(json['images'] ?? []),
      distance: json['distance'],
      bio: json['bio'],
      faculty: json['faculty'],
      interests: List<String>.from(json['interests'] ?? []),
      location: List<double>.from(json['location']?.map((e) => e.toDouble()) ?? [0.0, 0.0]),
      matchingInterestsCount: json['matchingInterestsCount'],
    );
  }
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
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (!_isCancellingSwipe && _profiles.isNotEmpty) {
            _currentProfileIndex =
                (_currentProfileIndex + 1) % _profiles.length;
          }
          _isAnimating = false;
          _currentSlide = Offset.zero;
          _swipeController.reset();
          _isCancellingSwipe = false; // Reset the flag
        });
      }
    });

    _fetchProfilesFromApi();
  }

  Future<void> _fetchProfilesFromApi() async {
    setState(() {
      _isLoadingProfiles = true;
      _profilesError = null;
    });

    try {

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      final String uid = currentUser.uid;
      final uri = Uri.parse('http://192.168.18.40:8080/profiles');// Ganti dengan URL API-mu

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Firebase-UID': uid,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final profiles = data.map((jsonItem) => ProfileData.fromJson(jsonItem)).toList();

        if (mounted) {
          setState(() {
            _profiles = profiles;
            _isLoadingProfiles = false;
          });
        }
      } else {
        throw Exception('Failed to load profiles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profiles from API: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfiles = false;
          _profilesError = e.toString();
        });
      }
    }
  }

  // Add helper function to calculate distance
  Future<double> _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    try {
      // Validasi koordinat
      if (!_isValidCoordinate(lat1, lon1) || !_isValidCoordinate(lat2, lon2)) {
        print('Invalid coordinates detected');
        return 0.0;
      }

      // Gunakan Geolocator dengan pengaturan akurasi tinggi
      double distanceInMeters = await Geolocator.distanceBetween(
        lat1,
        lon1,
        lat2,
        lon2,
      );

      // Konversi ke kilometer dengan pembulatan ke 1 desimal
      double distanceInKm = distanceInMeters / 1000;

      // Handle kasus khusus
      if (distanceInKm < 0.1) {
        return 0.1; // Minimum 100m ditampilkan sebagai 0.1km
      } else if (distanceInKm > 1000) {
        return 999.9; // Maximum 999.9km untuk jarak yang terlalu jauh
      }

      return double.parse(distanceInKm.toStringAsFixed(1));
    } catch (e) {
      print('Error calculating distance: $e');
      return 0.0;
    }
  }

  // Helper function untuk validasi koordinat
  bool _isValidCoordinate(double lat, double lon) {
    if (lat == null || lon == null) return false;
    if (lat == 0.0 && lon == 0.0) return false; // Koordinat default/invalid
    if (lat < -90 || lat > 90) return false; // Latitude valid: -90 to 90
    if (lon < -180 || lon > 180) return false; // Longitude valid: -180 to 180
    return true;
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
          return FadeTransition(opacity: animation, child: child);
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
        normalizedDeltaY / MediaQuery.of(context).size.height,
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
      final targetOffset = Offset(math.cos(angle) * 1.5, math.sin(angle) * 1.5);

      setState(() {
        _isAnimating = true;

        _slideAnimation = Tween<Offset>(
          begin: _currentSlide,
          end: targetOffset,
        ).animate(
          CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
        );

        // Add rotation based on the swipe direction
        _rotationAnimation = Tween<double>(
          begin: _currentSlide.dx * 0.2,
          end: targetOffset.dx * 0.2,
        ).animate(
          CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
        );
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
            (_dragUpdateY - _dragStartY) / height,
          ),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
        );

        _rotationAnimation = Tween<double>(
          begin: (_dragUpdateX - _dragStartX) / width * 0.2,
          end: 0.0,
        ).animate(
          CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
        );

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

  Future<void> _handleLike(ProfileData likedProfile) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final likesRef = FirebaseFirestore.instance.collection('Likes');
      final matchesRef = FirebaseFirestore.instance.collection('Matches');

      // Check if already liked
      final existingLikeQuery =
          await likesRef
              .where('likedBy', isEqualTo: currentUser.uid)
              .where('likedUser', isEqualTo: likedProfile.userId)
              .get();

      // If already liked, don't add another like
      if (existingLikeQuery.docs.isNotEmpty) {
        print('Already liked this profile');
        return;
      }

      // Add like to Likes collection
      await likesRef
          .add({
            'likedBy': currentUser.uid,
            'likedUser': likedProfile.userId,
            'timestamp': FieldValue.serverTimestamp(),
          })
          .then((value) => print('Like added with ID: ${value.id}'))
          .catchError((error) => print('Error adding like: $error'));

      // Check if the other user has already liked current user
      final querySnapshot =
          await likesRef
              .where('likedBy', isEqualTo: likedProfile.userId)
              .where('likedUser', isEqualTo: currentUser.uid)
              .get();

      // If there's a mutual like, create a match
      if (querySnapshot.docs.isNotEmpty) {
        print('Found mutual like, creating match');

        // Get current user's name
        final currentUserDoc =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUser.uid)
                .get();

        final currentUserName = currentUserDoc.data()?['nama'] ?? '';

        // Create match document
        await matchesRef
            .add({
              'users': [currentUser.uid, likedProfile.userId],
              'userNames': [currentUserName, likedProfile.name],
              'userPhotos': [
                (await _getCurrentUserPhoto()) ?? '',
                likedProfile.images.isNotEmpty ? likedProfile.images[0] : '',
              ],
              'timestamp': FieldValue.serverTimestamp(),
              'lastMessage': null,
              'lastMessageTimestamp': null,
            })
            .then((value) => print('Match created with ID: ${value.id}'))
            .catchError((error) => print('Error creating match: $error'));

        // Show match dialog
        if (mounted) {
          _showMatchDialog(likedProfile);
        }
      }
    } catch (e) {
      print('Error handling like: $e');
    }
  }

  Future<String?> _getCurrentUserPhoto() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.uid)
              .get();

      if (userDoc.exists) {
        final photos = List<String>.from(userDoc.data()?['photos'] ?? []);
        return photos.isNotEmpty ? photos[0] : null;
      }
      return null;
    } catch (e) {
      print('Error getting current user photo: $e');
      return null;
    }
  }

  void _showMatchDialog(ProfileData matchedProfile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  constraints: BoxConstraints(
                    maxWidth: 400, // Batas maksimum lebar dialog
                  ),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'It\'s a Match!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF426D),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'You and ${matchedProfile.name} liked each other',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                              ),
                              child: Text('Skip'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                // Navigate to match page using named route
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                  arguments: 1,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF426D),
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Message'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _swipeRight() {
    if (_isAnimating) return;

    final currentProfile = _profiles[_currentProfileIndex];
    _handleLike(currentProfile);

    setState(() {
      _isAnimating = true;

      _slideAnimation = Tween<Offset>(
        begin: _currentSlide,
        end: Offset(1.5, 0),
      ).animate(
        CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
      );

      _rotationAnimation = Tween<double>(
        begin: _currentSlide.dx * 0.2,
        end: 0.2,
      ).animate(
        CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
      );
    });

    _swipeController.forward(from: 0.0);
  }

  void _swipeLeft() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;

      _slideAnimation = Tween<Offset>(
        begin: _currentSlide,
        end: Offset(-1.5, 0),
      ).animate(
        CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
      );

      _rotationAnimation = Tween<double>(
        begin: _currentSlide.dx * 0.2,
        end: -0.2,
      ).animate(
        CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
      );
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: \n' + (_profilesError ?? 'Unknown error')),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchProfilesFromApi,
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_profiles.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFFFDF7F6),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No users found.'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchProfilesFromApi,
                child: Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentProfile = _profiles[_currentProfileIndex];
    final nextProfile =
        _profiles[(_currentProfileIndex + 1) % _profiles.length];

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
                            final offset =
                                _isDragging
                                    ? _currentSlide
                                    : _slideAnimation.value;
                            final rotation =
                                _isDragging
                                    ? (_currentSlide.dx * 0.2)
                                    : _rotationAnimation.value;
                            return Transform.translate(
                              offset:
                                  offset * MediaQuery.of(context).size.width,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                profile.images.isNotEmpty
                    ? PageView.builder(
                      itemCount: profile.images.length,
                      onPageChanged: (index) {
                        _currentImageIndex.value = index;
                      },
                      itemBuilder: (context, index) {
                        return ImageHelper.loadCachedImage(
                          imageUrl: profile.images[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                    : Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.person, size: 80, color: Colors.grey),
                    ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(1)],
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
          child: Center(child: Icon(icon, color: iconColor, size: 32)),
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
                          itemBuilder: (context, index) {
                            return ImageHelper.loadCachedImage(
                              imageUrl: profile.images[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
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
                                    color:
                                        index == currentIndex
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
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
    );
  }
}
