import 'package:flutter/material.dart';

class InterestSelectorBottomSheet extends StatefulWidget {
  final List<String> selectedInterests;
  final List<Map<String, dynamic>> interests;
  final Function(List<String>) onSave;

  const InterestSelectorBottomSheet({
    Key? key,
    required this.selectedInterests,
    required this.interests,
    required this.onSave,
  }) : super(key: key);

  @override
  _InterestSelectorBottomSheetState createState() => _InterestSelectorBottomSheetState();
}

class _InterestSelectorBottomSheetState extends State<InterestSelectorBottomSheet> {
  late List<String> tempSelected;

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select Interests (Max 3)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.interests.map((interest) {
              final label = interest['label'];
              final icon = interest['icon'];
              final isSelected = tempSelected.contains(label);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      tempSelected.remove(label);
                    } else {
                      if (tempSelected.length < 3) {
                        tempSelected.add(label);
                      }
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                      const SizedBox(width: 6),
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
            }).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              widget.onSave(tempSelected);
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
