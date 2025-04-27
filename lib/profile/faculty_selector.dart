import 'package:flutter/material.dart';

class FacultySelectorBottomSheet extends StatefulWidget {
  final String? selectedFaculty;
  final List<String> faculties;
  final Function(String?) onSave;

  const FacultySelectorBottomSheet({
    Key? key,
    required this.selectedFaculty,
    required this.faculties,
    required this.onSave,
  }) : super(key: key);

  @override
  _FacultySelectorBottomSheetState createState() => _FacultySelectorBottomSheetState();
}

class _FacultySelectorBottomSheetState extends State<FacultySelectorBottomSheet> {
  String? tempSelectedFaculty;

  @override
  void initState() {
    super.initState();
    tempSelectedFaculty = widget.selectedFaculty;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select Faculty",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.faculties.map((faculty) {
              final isSelected = tempSelectedFaculty == faculty;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (tempSelectedFaculty == faculty) {
                      tempSelectedFaculty = null;
                    } else {
                      tempSelectedFaculty = faculty;
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
                  child: Text(
                    faculty,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
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
              widget.onSave(tempSelectedFaculty);
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
