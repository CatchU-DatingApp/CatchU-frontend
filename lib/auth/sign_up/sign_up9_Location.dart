import 'package:catchu/auth/sign_up/sign_up10_Rules.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // ADD THIS

class EnableLocationPage extends StatelessWidget {
  final String phoneNumber;

  const EnableLocationPage({Key? key, required this.phoneNumber})
    : super(key: key);

  Future<void> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return;
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print('Current location: ${position.latitude}, ${position.longitude}');

    // After getting location, navigate to the next page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SignUpRulesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 250, 246),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/LocationImage.png',
                height: 200,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Enable Your Location',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Choose your location to start find people around you',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Langsung lanjut ke halaman berikutnya
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignUpRulesPage(), // Ganti dengan page setelah EnableLocation
                  ),
                );
              },
              child: Text('Skip For Now'),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: () {
                  _getCurrentLocation(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF2E63),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.pink[200],
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Allow Location Access',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
