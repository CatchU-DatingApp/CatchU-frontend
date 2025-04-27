import 'dart:async';

import 'package:flutter/material.dart';
import 'sign_up3.dart'; // Halaman berikutnya
import 'package:catchu/sign_up_data_holder.dart'; // jika perlu

class SignUpOtpPage extends StatefulWidget {
  final SignUpDataHolder dataHolder;
  const SignUpOtpPage({Key? key, required this.dataHolder}) : super(key: key);

  @override
  State<SignUpOtpPage> createState() => _SignUpOtpPageState();
}

class _SignUpOtpPageState extends State<SignUpOtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCountdown = 30;
  bool _isResending = false;
  Timer? _resendTimer;

  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length < 4) {
      setState(() => _errorMessage = 'Masukkan 4 digit kode OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isResending = true;
      _resendCountdown = 30;
      _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _resendCountdown--;
        });
        if (_resendCountdown <= 0) {
          _resendTimer?.cancel();
          _isResending = false;
        }
      });
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() => _isLoading = false);

      if (otp == '1234') {
        // Buat objek dataHolder dan isi nomor telepon
        final dataHolder = SignUpDataHolder(phoneNumber: widget.dataHolder.phoneNumber);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage3(dataHolder: dataHolder),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Kode OTP salah. Coba lagi.';
        });
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

  void _resendOtp() {
    setState(() {
      _isResending = true;
      _resendCountdown = 30;
      _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _resendCountdown--;
        });
        if (_resendCountdown <= 0) {
          _resendTimer?.cancel();
          _isResending = false;
        }
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
        title: Container(
          margin: EdgeInsets.only(right: 48),
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: 0.125,
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
                    text: widget.dataHolder.phoneNumber,
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