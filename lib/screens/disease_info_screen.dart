import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class DiseaseInfoScreen extends StatelessWidget {
  const DiseaseInfoScreen({super.key});

  Future<void> _onDonePressed(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenDiseaseInfo', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diseases = [
      {"name": "Eczema", "icon": Icons.healing},
      {"name": "Melanoma", "icon": Icons.brightness_high},
      {"name": "Warts", "icon": Icons.coronavirus},
      {"name": "Acne", "icon": Icons.spa},
      {"name": "Lupus", "icon": Icons.local_hospital},
      {"name": "Ringworm", "icon": Icons.circle_outlined},
      {"name": "Psoriasis", "icon": Icons.medical_information},
      {"name": "Actinic Keratosis", "icon": Icons.warning},
    ];

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
                    const Icon(
                      Icons.medical_services_rounded,
                      color: Color(0xFF2E8BC0), // Primary blue
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Diseases Detected",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E8BC0), // Primary blue
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Our AI model is trained to identify the following skin conditions:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                      ), // Dark gray for better readability
                    ),
                    const SizedBox(height: 24),

                    // Animated disease list
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: diseases.length,
                        itemBuilder: (context, index) {
                          final disease = diseases[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 300 + index * 150),
                            builder: (context, value, child) => Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: child,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(
                                  0xFFE2F0F6,
                                ), // Light blue background
                                child: Icon(
                                  disease["icon"] as IconData,
                                  color: const Color(
                                    0xFF2E8BC0,
                                  ), // Primary blue
                                ),
                              ),
                              title: Text(
                                disease["name"] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _onDonePressed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF2E8BC0,
                        ), // Primary blue
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 18),
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
