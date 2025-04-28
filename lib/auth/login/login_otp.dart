import 'dart:async';
import 'package:flutter/material.dart';
import 'package:catchu/auth/auth_controller.dart';
import 'package:catchu/home/homepage1.dart';
import 'package:catchu/services/session_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginOtpPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final AuthController authController;

  const LoginOtpPage({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    required this.authController,
  }) : super(key: key);

  @override
  _LoginOtpPageState createState() => _LoginOtpPageState();
}

class _LoginOtpPageState extends State<LoginOtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 30;
  Timer? _resendTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        _resendTimer?.cancel();
        setState(() {
          _isResending = false;
        });
      }
    });
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter complete OTP code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    widget.authController
        .verifyOtp(verificationId: widget.verificationId, smsCode: otp)
        .then((userCredential) async {
          // Save session after successful login
          await SessionManager.saveSession(
            userId: userCredential.user!.uid,
            email: userCredential.user!.email!,
            name: userCredential.user!.displayName ?? 'User',
          );

          setState(() => _isLoading = false);
          // Navigate to home and remove all previous routes
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        })
        .catchError((error) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Invalid OTP code. Please try again';
          });
          _clearOtpFields();
        });
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(_focusNodes[0]);
  }

  void _resendOtp() {
    if (_isResending || _resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _resendCountdown = 30;
      _errorMessage = null;
    });

    // First check if phone number is still registered
    widget.authController
        .checkPhoneNumberRegistered(widget.phoneNumber)
        .then((isRegistered) {
          if (isRegistered) {
            // Phone number is registered, resend OTP
            widget.authController.sendOtp(
              phoneNumber: widget.phoneNumber,
              verificationCompleted: (PhoneAuthCredential credential) {
                // Auto-verification
              },
              verificationFailed: (FirebaseAuthException e) {
                setState(() {
                  _isResending = false;
                  _errorMessage = e.message ?? 'Verification failed';
                });
              },
              codeSent: (String verificationId, int? resendToken) {
                setState(() {
                  _isResending = false;
                });
                _startResendTimer();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('OTP has been resent')));
              },
            );
          } else {
            // Phone number is not registered anymore
            setState(() {
              _isResending = false;
              _errorMessage =
                  'Nomor telepon belum terdaftar. Please sign up first.';
            });

            // Navigate back to login after a delay
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pop(context);
            });
          }
        })
        .catchError((error) {
          setState(() {
            _isResending = false;
            _errorMessage = 'Error checking phone number. Please try again.';
          });
        });
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Image.asset(
                  'assets/images/CatchU_Logo.png',
                  height: 150,
                ),
              ),
            ),

            // Title
            Text(
              'Verification Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            // Description
            Text.rich(
              TextSpan(
                text: 'Please enter code we just send to\n',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                children: [
                  TextSpan(
                    text: widget.phoneNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Container(
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          _errorMessage != null
                              ? Colors.red
                              : Colors.grey.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        FocusScope.of(
                          context,
                        ).requestFocus(_focusNodes[index + 1]);
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(
                          context,
                        ).requestFocus(_focusNodes[index - 1]);
                      }
                      setState(() => _errorMessage = null);
                    },
                  ),
                );
              }),
            ),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            SizedBox(height: 24),
            Center(
              child:
                  _resendCountdown > 0
                      ? Text(
                        'Resend code in $_resendCountdown seconds',
                        style: TextStyle(color: Colors.grey),
                      )
                      : TextButton(
                        onPressed: _isResending ? null : _resendOtp,
                        child:
                            _isResending
                                ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  'Resend Code',
                                  style: TextStyle(
                                    color: Colors.pink[400],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
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
                          'Verify',
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
}
