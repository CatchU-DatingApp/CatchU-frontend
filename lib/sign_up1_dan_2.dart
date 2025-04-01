import 'package:flutter/material.dart';

class SignUpPage1 extends StatefulWidget {
  const SignUpPage1({Key? key}) : super(key: key);

  @override
  _SignUpPage1State createState() => _SignUpPage1State();
}

class _SignUpPage1State extends State<SignUpPage1> {
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
                (context) => OtpVerificationPageSignUp(
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
              value: 0.125, // 12.5% progress for step 1
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

              // Description
              Text(
                "We'll need your phone number to send an OTP for verification.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              // Phone Number Input with Validation
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
                    // Country Code Dropdown
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _countryCode,
                          icon: Icon(Icons.arrow_drop_down, size: 24),
                          style: TextStyle(fontSize: 16, color: Colors.black87),
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
                    ),

                    // Vertical Divider
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.grey,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                    ),

                    // Phone Number Field
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _phoneNumber = value;
                          });
                          _validateInput(value);
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
                      ),
                    ),
                  ],
                ),
              ),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: _errorMessage != null ? 24 : 40),

              // Continue Button
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
    );
  }
}

class OtpVerificationPageSignUp extends StatelessWidget {
  final String phoneNumber;

  const OtpVerificationPageSignUp({Key? key, required this.phoneNumber})
    : super(key: key);

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
              value: 0.25, // 25% progress for step 2
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

            // Phone Number
            Text.rich(
              TextSpan(
                text: 'Please enter code we just send to\n',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                children: [
                  TextSpan(
                    text: phoneNumber,
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

            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 24),

            // Resend Code
            Center(
              child: Text.rich(
                TextSpan(
                  text: "Didn't receive OTP? ",
                  style: TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: 'Resend Code',
                      style: TextStyle(
                        color: Colors.pink[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle verification logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Verify',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
