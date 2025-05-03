import 'package:flutter/material.dart';
import 'homepage1.dart';
import 'match.dart';
import '../profile/profile.dart';

class MainPage extends StatefulWidget {
  final int? initialIndex;

  const MainPage({Key? key, this.initialIndex}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class CurvedPainter extends CustomPainter {
  final double position;

  CurvedPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    var paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    var shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    var path = Path();

    // Calculate curve position
    final curvePosition = size.width * position;
    final curveRadius = 24.0;

    // Start from top-left
    path.moveTo(0, curveRadius);

    // Top-left corner
    path.quadraticBezierTo(0, 0, curveRadius, 0);

    // Top edge before curve
    path.lineTo(curvePosition - 40, 0);

    // Left part of curve
    path.quadraticBezierTo(curvePosition - 30, 0, curvePosition - 20, -5);

    // Center of curve
    path.quadraticBezierTo(curvePosition, -10, curvePosition + 20, -5);

    // Right part of curve
    path.quadraticBezierTo(curvePosition + 30, 0, curvePosition + 40, 0);

    // Top edge after curve
    path.lineTo(size.width - curveRadius, 0);

    // Top-right corner
    path.quadraticBezierTo(size.width, 0, size.width, curveRadius);

    // Right edge
    path.lineTo(size.width, size.height);

    // Bottom edge
    path.lineTo(0, size.height);

    // Close path
    path.close();

    // Draw shadow first
    canvas.drawPath(path, shadowPaint);

    // Then draw the main path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _curveAnimation;
  late int _currentIndex;

  final List<Widget> _pages = [DiscoverPage(), MatchPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;

    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize curve animation with the starting position
    final initialPosition = (_currentIndex + 0.5) / 3;
    _curveAnimation = Tween<double>(
      begin: initialPosition,
      end: initialPosition,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    final double currentPosition = (_currentIndex + 0.5) / 3;
    final double targetPosition = (index + 0.5) / 3;

    setState(() {
      _currentIndex = index;

      _curveAnimation = Tween<double>(
        begin: currentPosition,
        end: targetPosition,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Stack(
        children: [
          Container(
            height: 80,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _curveAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(MediaQuery.of(context).size.width, 80),
                      painter: CurvedPainter(_curveAnimation.value),
                    );
                  },
                ),
                Container(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(0, Icons.home),
                      _buildNavItem(1, Icons.chat),
                      _buildNavItem(2, Icons.person),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, isSelected ? -5 : 0, 0),
              child: Icon(
                icon,
                color: isSelected ? Colors.pinkAccent : Colors.grey,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
