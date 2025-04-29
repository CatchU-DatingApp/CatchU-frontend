import 'package:catchu/auth/sign_up/sign_up5_Umur.dart';
import 'package:flutter/material.dart';
import 'package:catchu/sign_up_data_holder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage4 extends StatefulWidget {
  final SignUpDataHolder dataHolder;
  const SignUpPage4({Key? key, required this.dataHolder}) : super(key: key);

  @override
  State<SignUpPage4> createState() => _SignUpPage4State();
}

class _SignUpPage4State extends State<SignUpPage4> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    if (!value.endsWith('@gmail.com')) {
      return 'Email must use @gmail.com domain';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 250, 246),
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
              value: 0.375,
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
              "Email Address",
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
              controller: _emailController,
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
                errorText: _emailError,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
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
                    (_emailController.text.isEmpty ||
                            _isLoading ||
                            _emailError != null)
                        ? null
                        : () async {
                          setState(() => _isLoading = true);

                          try {
                            // Cek apakah email sudah terdaftar
                            final emailCheckSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .where(
                                      'email',
                                      isEqualTo: _emailController.text,
                                    )
                                    .get();

                            if (emailCheckSnapshot.docs.isNotEmpty) {
                              setState(() {
                                _isLoading = false;
                                _emailError =
                                    'Email sudah terdaftar. Silakan login atau gunakan email lain.';
                              });
                              return;
                            }

                            // Jika email belum terdaftar, lanjutkan ke halaman berikutnya
                            widget.dataHolder.email = _emailController.text;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SignUpPage5(
                                      dataHolder: widget.dataHolder,
                                    ),
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                              _emailError = 'Terjadi kesalahan: $e';
                            });
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
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
    _emailController.dispose();
    super.dispose();
  }
}
