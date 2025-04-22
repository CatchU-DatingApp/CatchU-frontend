import 'package:flutter/material.dart';
import 'package:catchu/auth/sign_up/sign_up7_interest.dart';

class SignUpPage6 extends StatefulWidget {
  final String phoneNumber;

  const SignUpPage6({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _SignUpPage6State createState() => _SignUpPage6State();
}

class _SignUpPage6State extends State<SignUpPage6> {
  String? selectedGender;
  bool _isLoading = false;

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
              value: 0.625,
              backgroundColor: const Color.fromARGB(255, 255, 233, 241),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24),
                      Text(
                        "What’s Your Gender?",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tell us about your gender",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            _buildGenderButton(
                              "Male",
                              Icons.male,
                              Colors.pink[400]!,
                            ),
                            SizedBox(height: 20),
                            _buildGenderButton(
                              "Female",
                              Icons.female,
                              Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      selectedGender == null || _isLoading
                          ? null
                          : () {
                            setState(() => _isLoading = true);
                            Future.delayed(Duration(seconds: 1), () {
                              setState(() => _isLoading = false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SignUpPage7(
                                        phoneNumber: widget.phoneNumber,
                                      ),
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
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender, IconData icon, Color color) {
    final isSelected = selectedGender == gender;

    double screenWidth = MediaQuery.of(context).size.width;
    double buttonSize = screenWidth * 0.4;
    double iconSize = screenWidth * 0.1;
    double fontSize = screenWidth * 0.05;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        height: buttonSize.clamp(140.0, 220.0),
        width: buttonSize.clamp(140.0, 220.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink[400] : Colors.pink[50],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize.clamp(32.0, 64.0),
                color: isSelected ? Colors.white : Colors.black,
              ),
              SizedBox(height: 12),
              Text(
                gender,
                style: TextStyle(
                  fontSize: fontSize.clamp(14.0, 24.0),
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Untuk menghilangkan efek scroll glow
class NoGlowScrollBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}
