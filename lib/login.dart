import 'dart:async';
import 'package:flutter/material.dart';
import 'sign_up1_dan_2.dart';
import 'homepage1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _countryCode = '+62';
  String _phoneNumber = '';
  bool _isLoading = false;
  String? _errorMessage;

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

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OtpVerificationPageLogin(
                  phoneNumber: '$_countryCode$_phoneNumber',
                ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 250, 246),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
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

              // Phone Number Input with Validation
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                            onChanged: (value) {
                              setState(() {
                                _phoneNumber = value;
                              });
                              _validateInput(value);
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
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
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
                child: OutlinedButton(
                  onPressed: () {},
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
                      Image.asset('assets/images/google_logo.png', height: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Login with Google',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
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
                          builder: (context) => const SignUpPage1(),
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
    );
  }
}

class OtpVerificationPageLogin extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPageLogin({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  _OtpVerificationPageLoginState createState() =>
      _OtpVerificationPageLoginState();
}

class _OtpVerificationPageLoginState extends State<OtpVerificationPageLogin> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
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

    // Simulate API call
    Future.delayed(Duration(seconds: 1), () {
      setState(() => _isResending = false);
      _startResendTimer();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP has been resent')));
    });
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length < 4) {
      setState(() => _errorMessage = 'Please enter complete OTP code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate API verification
    Future.delayed(Duration(seconds: 2), () {
      setState(() => _isLoading = false);

      // Mock verification - in real app, check with your backend
      if (otp == '1234') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DiscoverPage()),
        );
        // Replace with actual verification and actual homepage
      } else {
        setState(() => _errorMessage = 'Invalid OTP code. Please try again');
        _clearOtpFields();
      }
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
              children: List.generate(4, (index) {
                return Container(
                  width: 60,
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
                      if (value.length == 1 && index < 3) {
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
