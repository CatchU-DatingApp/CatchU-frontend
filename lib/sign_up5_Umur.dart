import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpPage5 extends StatefulWidget {
  @override
  _SignUpPage5State createState() => _SignUpPage5State();
}

class _SignUpPage5State extends State<SignUpPage5> {
  int selectedAge = 20;
  final List<int> ages = List.generate(60 - 17 + 1, (index) => 17 + index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header & progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LinearProgressIndicator(
                        value: 0.5,
                        backgroundColor: Color(0xFFFCE8F0),
                        valueColor: AlwaysStoppedAnimation(Color(0xFFFF3A6E)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 40),
            Text(
              'How Old Are You?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please provide your age in years',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: selectedAge - 17,
                ),
                itemExtent: 40,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedAge = ages[index];
                  });
                },
                children: ages.map((age) {
                  final isSelected = age == selectedAge;
                  return Center(
                    child: Text(
                      '$age',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Color(0xFFFF3A6E) : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    print('Selected Age: $selectedAge');
                    // Arahkan ke halaman berikutnya kalau ada
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => NextPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF3A6E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
