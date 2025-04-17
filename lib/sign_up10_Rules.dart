import 'package:flutter/material.dart';

class SignUpRulesPage extends StatelessWidget {
  const SignUpRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFCF9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/LogoCatchURules.png',
                  height: 80,
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Welcome to CatchU',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please follow these App Rules',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 30),

              // Rules
              _buildRuleCard(
                title: 'Be yourself.',
                description:
                    'Make sure your photos, age, and bio are true to who you are.',
              ),
              SizedBox(height: 12),
              _buildRuleCard(
                title: 'Stay safe.',
                description:
                    "Don't be too quick to give out personal information. ",
                extra: TextSpan(
                  text: 'Date Safely',
                  style: TextStyle(
                    color: Colors.pink,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 12),
              _buildRuleCard(
                title: 'Play it cool.',
                description:
                    'Respect others and treat them as you would like to be treated.',
              ),
              SizedBox(height: 12),
              _buildRuleCard(
                title: 'Be proactive.',
                description: 'Go catch some love :)',
                forceHeight: true, // biar ukurannya setara dengan yang lain
              ),

              Spacer(),

              // I AGREE Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to next page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF2E63),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: Text('I AGREE', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required String title,
    required String description,
    TextSpan? extra,
    bool forceHeight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pinkAccent, width: 2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        color: Colors.white,
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$title\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: description),
            if (extra != null) extra,
            if (forceHeight)
              TextSpan(
                text: '\n\n\n',
                style: TextStyle(color: Colors.transparent, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
