import 'package:flutter/material.dart';
import 'package:catchu/sign_up9_Location.dart';

class SignUpPage8 extends StatefulWidget {
  @override
  _SignUpPage8State createState() => _SignUpPage8State();
  final String phoneNumber;
  const SignUpPage8({Key? key, required this.phoneNumber}) : super(key: key);
}

class _SignUpPage8State extends State<SignUpPage8> {
  List<ImageProvider> uploadedImages = [
    AssetImage('assets/images/jawa.png'), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEF9F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 253, 250, 246),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          margin: EdgeInsets.only(right: 48),
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: 0.9, // Progress step ke-9
              backgroundColor: const Color.fromARGB(255, 255, 233, 241),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Text(
              "Upload Your Photo",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "We'd love to see you. Upload a photo for your dating journey.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(6, (index) {
                if (index < uploadedImages.length) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(
                      image: uploadedImages[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      // Aksi saat klik tambah gambar (implementasi sesuai kebutuhan)
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.pink.shade200,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.add, color: Colors.pink, size: 30),
                    ),
                  );
                }
              }),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnableLocationPage(phoneNumber: widget.phoneNumber),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[400],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.pink[200],
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text("Continue", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
