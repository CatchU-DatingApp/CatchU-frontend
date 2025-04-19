import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: DiscoverPage());
  }
}

class DiscoverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF7F6),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Text(
              'Discover',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Profile Card
          Stack(
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
                    color: Colors.white,
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
                          'assets/jawa.png',
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
                              'Rohini',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '10 miles away',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '2',
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
          ),

          Spacer(),

          // 2 Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionButton(
                  icon: Icons.clear,
                  iconColor: Colors.red,
                  shadowColor: Colors.redAccent.withOpacity(0.4),
                ),
                _actionButton(
                  icon: Icons.favorite,
                  iconColor: Colors.pink,
                  shadowColor: Colors.pinkAccent.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
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
      child: Center(child: Icon(icon, color: iconColor, size: 32)),
    );
  }
}
