import 'package:flutter/material.dart';
import 'sign_up2_otp.dart';
import 'package:catchu/sign_up_data_holder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class SignUpPhonePage extends StatefulWidget {
  final SignUpDataHolder dataHolder;
  const SignUpPhonePage({Key? key, required this.dataHolder}) : super(key: key);

  @override
  State<SignUpPhonePage> createState() => _SignUpPhonePageState();
}

class _SignUpPhonePageState extends State<SignUpPhonePage> {
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

  void _submitForm() async {
    _validateInput(_phoneNumber);
    if (_errorMessage == null) {
      setState(() {
        _isLoading = true;
      });

      final formattedPhoneNumber = '$_countryCode$_phoneNumber';

      try {
        // Cek apakah nomor telepon sudah terdaftar
        final phoneCheckSnapshot =
            await FirebaseFirestore.instance
                .collection('Users')
                .where('nomorTelepon', isEqualTo: formattedPhoneNumber)
                .get();

        if (phoneCheckSnapshot.docs.isNotEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Nomor telepon sudah terdaftar. Silakan login atau gunakan nomor lain.';
          });
          return;
        }

        // Simpan nomor ke dataHolder dan langsung pindah ke halaman OTP
        widget.dataHolder.phoneNumber = formattedPhoneNumber;
        setState(() {
          _isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpOtpPage(dataHolder: widget.dataHolder),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                  value: 0, // 0% progress for step 1
                  backgroundColor: const Color.fromARGB(255, 255, 233, 241),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
                ),
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24),
                  // Title
                  Text(
                    'My Number Is',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),

                  Text(
                    "We'll need your phone number to send an OTP for verification.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),

                  Container(
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
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _countryCode,
                              icon: Icon(Icons.arrow_drop_down, size: 24),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              items:
                                  ['+62', '+1', '+44', '+81'].map((
                                    String value,
                                  ) {
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
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.grey,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                        ),

                        Expanded(
                          child: TextField(
                            autofocus: true,
                            onChanged: (value) {
                              if (_phoneNumber != value) {
                                setState(() {
                                  _phoneNumber = value;
                                });
                                _validateInput(value);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Enter phone number",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: _errorMessage != null ? 24 : 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
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
          ),
        ),
      ],
    );
  }
}
