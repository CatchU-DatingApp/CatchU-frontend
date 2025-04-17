import 'package:catchu/sign_up5_umur.dart';
import 'package:flutter/material.dart';

class SignUpPage4 extends StatefulWidget {
  final String phoneNumber;

  const SignUpPage4({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _SignUpPage4State createState() => _SignUpPage4State();
}

class _SignUpPage4State extends State<SignUpPage4> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _emailError; // Menyimpan pesan error untuk validasi

  // Fungsi untuk memvalidasi email
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }

    // Regex pattern untuk validasi email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
              value: 0.375, // 37,5% progress for step 4
              backgroundColor: const Color.fromARGB(255, 255, 233, 241),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            Text(
              "Email Address", // Mengoreksi enjadi "Email Address"
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "We'll need your email to stay in touch",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter your email address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.pink[400]!),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.red),
                ),
                errorText: _emailError, // Menampilkan pesan error
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              keyboardType:
                  TextInputType.emailAddress, // Menambahkan tipe keyboard email
              style: TextStyle(fontSize: 16),
              onChanged: (value) {
                setState(() {
                  _emailError = _validateEmail(value);
                });
              },
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_nameController.text.isEmpty ||
                            _isLoading ||
                            _emailError != null)
                        ? null
                        : () {
                          setState(() => _isLoading = true);
                          Future.delayed(Duration(seconds: 1), () {
                            setState(() => _isLoading = false);
                            // signup5
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SignUpPage5(
                                      phoneNumber: widget.phoneNumber,
                                    ), // Replace with your next page
                              ),
                            );
                          });
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
                child:
                    _isLoading
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
