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
              // Logo
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
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
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
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pinkAccent),
        borderRadius: BorderRadius.circular(20),
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
          ],
        ),
      ),
    );
  }
}
