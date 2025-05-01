import 'package:flutter/material.dart';
import 'dart:ui';

class ProfileCompletionPopup extends StatefulWidget {
  final ValueNotifier<double> profileCompletionNotifier;
  final ValueNotifier<Map<String, Map<String, dynamic>>> profileItemsNotifier;

  const ProfileCompletionPopup({
    Key? key,
    required this.profileCompletionNotifier,
    required this.profileItemsNotifier,
  }) : super(key: key);

  @override
  State<ProfileCompletionPopup> createState() => _ProfileCompletionPopupState();
}

class _ProfileCompletionPopupState extends State<ProfileCompletionPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ValueListenableBuilder<double>(
        valueListenable: widget.profileCompletionNotifier,
        builder: (context, profileCompletion, _) {
          return ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
            valueListenable: widget.profileItemsNotifier,
            builder: (context, profileItems, __) {
              return GestureDetector(
                onTap: () {
                  // Ensure any focus is removed when tapping on the dialog
                  FocusScope.of(context).unfocus();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // color: const Color(0xFFFF375F).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress indicator
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Center(
                              child: Text(
                                '${(profileCompletion * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Motivational text
                          const Text(
                            'Just a little bit more!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Transform your profile from solid to stellar.',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            'The finer points matter!',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // Profile completion grid
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            children:
                                profileItems.entries.map((entry) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          entry.value['icon'],
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${entry.value['completed']} of ${entry.value['total']} added',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // Close button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFFF375F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Close",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
