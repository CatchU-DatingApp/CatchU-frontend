import 'package:flutter/material.dart';
import 'package:catchu/auth/sign_up/sign_up8_picture.dart';
import 'package:catchu/sign_up_data_holder.dart';

class SignUpPage7 extends StatefulWidget {
  final SignUpDataHolder dataHolder;
  const SignUpPage7({Key? key, required this.dataHolder}) : super(key: key);

  @override
  State<SignUpPage7> createState() => _SignUpPage7State();
}

class _SignUpPage7State extends State<SignUpPage7> {
  List<String> selectedInterests = [];

  final List<Map<String, dynamic>> interests = [
    {"label": "Reading", "icon": Icons.menu_book},
    {"label": "Photography", "icon": Icons.camera_alt},
    {"label": "Gaming", "icon": Icons.videogame_asset},
    {"label": "Music", "icon": Icons.music_note},
    {"label": "Travel", "icon": Icons.flight},
    {"label": "Painting", "icon": Icons.brush},
    {"label": "Politics", "icon": Icons.how_to_vote},
    {"label": "Charity", "icon": Icons.volunteer_activism},
    {"label": "Cooking", "icon": Icons.restaurant_menu},
    {"label": "Pets", "icon": Icons.pets},
    {"label": "Sports", "icon": Icons.sports_soccer},
    {"label": "Fashion", "icon": Icons.checkroom},
  ];

  void toggleInterest(String label) {
    setState(() {
      if (selectedInterests.contains(label)) {
        selectedInterests.remove(label);
      } else {
        if (selectedInterests.length < 3) {
          selectedInterests.add(label);
        }
      }
    });
  }

  Widget _buildInterestButton(String label, IconData icon) {
    final isSelected = selectedInterests.contains(label);

    return GestureDetector(
      onTap: () => toggleInterest(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink[400] : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.pink.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.pink[400],
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
              value: 0.75,
              backgroundColor: const Color.fromARGB(255, 255, 233, 241),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Text(
              "Select Up To 3 Interest",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Tell us what piques your curiosity and passions",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children:
                  interests
                      .map(
                        (interest) => _buildInterestButton(
                          interest['label'],
                          interest['icon'],
                        ),
                      )
                      .toList(),
            ),
            Spacer(),
            ElevatedButton(
              onPressed:
                  selectedInterests.isEmpty
                      ? null
                      : () {
                        widget.dataHolder.interest = selectedInterests;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    SignUpPage8(dataHolder: widget.dataHolder),
                          ),
                        );
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
              child: Text("Continue", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
