import 'package:catchu/sign_up10_Rules.dart';
import 'package:flutter/material.dart';

class EnableLocationPage extends StatelessWidget {
  final String phoneNumber;

  const EnableLocationPage({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFCF9),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset('assets/LocationImage.png', height: 200)),
            SizedBox(height: 40),
            Text(
              'Enable Your Location',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Choose your location to start find people\naround you',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SignUpRulesPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF2E63),
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
