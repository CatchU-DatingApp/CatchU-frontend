import 'dart:async';
import 'package:catchu/auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:catchu/auth/sign_up/sign_up1_phone.dart';
import 'package:catchu/home/homepage1.dart';
import 'package:catchu/sign_up_data_holder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:catchu/services/session_manager.dart';
import 'login_otp.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  String _countryCode = '+62';
  String _phoneNumber = '';
  bool _isLoading = false;
  bool _isGoogleLoading = false; // Separate loading state for Google
  String? _errorMessage;
  String? _googleErrorMessage; // Separate error message for Google

  void _validateInput(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorMessage = 'Please enter your phone number';
      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        _errorMessage = 'Only numbers are allowed';
      } else if (value.length < 8) {
        _errorMessage = 'Phone number is too short';
      } else {
        _errorMessage = null;
      }
    });
  }

  void _submitForm() {
    _validateInput(_phoneNumber);
    if (_errorMessage == null) {
      setState(() {
        _isLoading = true;
      });

      // Format phone number
      final formattedPhoneNumber = '$_countryCode$_phoneNumber';
      print('Checking phone number: $formattedPhoneNumber'); // Debug log

      _authController
          .checkPhoneNumberRegistered(formattedPhoneNumber)
          .then((isRegistered) {
            print('Is registered: $isRegistered'); // Debug log
            if (isRegistered) {
              _sendOtp();
            } else {
              setState(() {
                _isLoading = false;
                _errorMessage =
                    'Nomor telepon belum terdaftar. Please sign up first.';
              });
            }
          })
          .catchError((error) {
            print('Error checking phone: $error'); // Debug log
            setState(() {
              _isLoading = false;
              _errorMessage = 'Error checking phone number. Please try again.';
            });
          });
    }
  }

  void _sendOtp() {
    final formattedPhoneNumber = '$_countryCode$_phoneNumber';
    print('Sending OTP to: $formattedPhoneNumber'); // Debug log

    _authController.sendOtp(
      phoneNumber: formattedPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        _authController.verifyOtp(verificationId: '', smsCode: '').then((
          userCredential,
        ) async {
          // Save session after successful login
          await SessionManager.saveSession(
            userId: userCredential.user!.uid,
            email: userCredential.user!.email!,
            name: userCredential.user!.displayName ?? 'User',
          );

          // Navigate to home and remove all previous routes
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}'); // Debug log
        setState(() {
          _isLoading = false;
          _errorMessage = e.message ?? 'Verification failed';
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        print('OTP sent successfully'); // Debug log
        setState(() {
          _isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => LoginOtpPage(
                  phoneNumber: formattedPhoneNumber,
                  verificationId: verificationId,
                  authController: _authController,
                ),
          ),
        );
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _googleErrorMessage = null;
    });

    try {
      print('Starting Google login process...');
      final userCredential = await _authController.signInWithGoogle();
      print('Google login successful, saving session...');

      // Save session after successful Google login
      await SessionManager.saveSession(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userCredential.user!.displayName ?? 'User',
      );
      print('Session saved successfully');

      setState(() {
        _isGoogleLoading = false;
      });

      // Navigate to home and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      print('Error during Google login: $e');
      setState(() {
        _isGoogleLoading = false;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'google-sign-in-cancelled':
              _googleErrorMessage = 'Login dibatalkan oleh pengguna.';
              break;
            case 'user-not-found':
              _googleErrorMessage =
                  'Email belum terdaftar. Silakan sign up terlebih dahulu.';
              break;
            case 'firestore-access-denied':
              _googleErrorMessage =
                  'Tidak dapat mengakses database. Silakan coba lagi nanti.';
              break;
            default:
              _googleErrorMessage =
                  e.message ?? 'Login dengan Google gagal. Silakan coba lagi.';
          }
        } else {
          _googleErrorMessage = 'Login dengan Google gagal. Silakan coba lagi.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 250, 246),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Let's start with your number",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            _errorMessage != null
                                ? Colors.red
                                : _phoneNumber.isNotEmpty
                                ? Colors.pink[400]!
                                : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        // Country Code Dropdown
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButton<String>(
                            value: _countryCode,
                            underline: Container(),
                            icon: const Icon(Icons.arrow_drop_down, size: 24),
                            items:
                                ['+62', '+1', '+44', '+81'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _countryCode = newValue!;
                              });
                            },
                          ),
                        ),

                        // Vertical Divider
                        Container(height: 24, width: 1, color: Colors.grey),

                        // Phone Number Field (tanpa validator)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: "Enter phone number",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 8,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(15),
                              ],
                              onChanged: (value) {
                                if (_phoneNumber != value) {
                                  setState(() {
                                    _phoneNumber = value;
                                  });
                                  _validateInput(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Error Message - TAMPIL DI BAWAH KOTAK INPUT
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, top: 4.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // OR Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('OR', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Google Login Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      OutlinedButton(
                        onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_logo.png',
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            _isGoogleLoading
                                ? Row(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                )
                                : const Text(
                                  'Login with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                          ],
                        ),
                      ),
                      if (_googleErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _googleErrorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Sign Up Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SignUpPhonePage(
                                  dataHolder: SignUpDataHolder(),
                                ),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.pink[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtpVerificationPageLogin extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final AuthController authController;

  const OtpVerificationPageLogin({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    required this.authController,
  }) : super(key: key);

  @override
  _OtpVerificationPageLoginState createState() =>
      _OtpVerificationPageLoginState();
}

class _OtpVerificationPageLoginState extends State<OtpVerificationPageLogin> {
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

    // Pindahkan auto-focus ke didChangeDependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Alternatif: bisa juga dipindahkan ke sini
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
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  void _resendOtp() {
    setState(() {
      _isResending = true;
      _resendCountdown = 30;
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
