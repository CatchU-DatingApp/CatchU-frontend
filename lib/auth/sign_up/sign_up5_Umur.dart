import 'package:catchu/auth/auth_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:catchu/auth/sign_up/sign_up6_gender.dart';
import 'package:catchu/sign_up_data_holder.dart';

class SignUpPage5 extends StatefulWidget {
  final SignUpDataHolder dataHolder;
  const SignUpPage5({Key? key, required this.dataHolder}) : super(key: key);

  @override
  State<SignUpPage5> createState() => _SignUpPage5State();
}

class _SignUpPage5State extends State<SignUpPage5> {
  int selectedAge = 17;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: const Color.fromARGB(255, 253, 250, 246),
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _goToNextStep() {
    setState(() => _isLoading = true);
    Future.delayed(Duration(seconds: 1), () {
      setState(() => _isLoading = false);
      widget.dataHolder.umur = selectedAge;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpPage6(dataHolder: widget.dataHolder),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 250, 246),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () async {
                      final authController = AuthController();
                      await authController.deleteCurrentUserWithReauth();
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 48),
                      height: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: LinearProgressIndicator(
                          value: 0.5,
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            233,
                            241,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.pink[400]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24),
                  Text(
                    "How Old Are You?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please provide your age in years",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CupertinoPicker(
                    backgroundColor: Colors.transparent,
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedAge - 17,
                    ),
                    itemExtent: 60,
                    magnification: 1.2,
                    useMagnifier: true,
                    squeeze: 1.2,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedAge = 17 + index;
                      });
                    },
                    children: List<Widget>.generate(44, (index) {
                      final age = 17 + index;
                      return Center(
                        child: Text(
                          '$age',
                          style: TextStyle(
                            fontSize: 24,
                            color:
                                age == selectedAge
                                    ? Colors.pink[400]
                                    : Colors.black,
                            fontWeight:
                                age == selectedAge
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _goToNextStep,
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
}
