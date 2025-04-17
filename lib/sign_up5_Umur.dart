import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:catchu/sign_up6_gender.dart';

class SignUpPage5 extends StatefulWidget {
  final String phoneNumber;

  const SignUpPage5({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _SignUpPage5State createState() => _SignUpPage5State();
}

class _SignUpPage5State extends State<SignUpPage5> {
  int selectedAge = 17;
  bool _isLoading = false;

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
              value: 0.5, // 50% progress for step 5
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
              "How Old Are You?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),

            // Subtitle
            Text(
              "Please provide your age in years",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0),

            // Age Picker (Cupertino)
            Expanded(
              child: CupertinoPicker(
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
                children: List<Widget>.generate(
                  44, // 17 - 60
                  (index) {
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
                  },
                ),
              ),
            ),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          setState(() => _isLoading = true);
                          Future.delayed(Duration(seconds: 1), () {
                            setState(() => _isLoading = false);
                            // TODO: Ganti dengan halaman berikutnya
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SignUpPage6(
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
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
