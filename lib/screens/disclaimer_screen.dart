import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'disease_info_screen.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  Future<void> _onOkPressed(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenDisclaimer', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DiseaseInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E8BC0), Color(0xFF0C4160)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 10,
              color: const Color(0xFFF8FAFC), // Light background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(seconds: 1),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: value,
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: Color(0xFF2E8BC0), // Primary blue
                            size: 90,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Important Notice",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E8BC0), // Primary blue
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "DermaScan provides AI-powered preliminary diagnosis for skin conditions. "
                      "It is not a substitute for a certified dermatologist. "
                      "For any health concerns, please consult a professional.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => _onOkPressed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF2E8BC0,
                        ), // Primary blue
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 5,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "I Understand",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
