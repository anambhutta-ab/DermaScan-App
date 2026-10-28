import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scan_data.dart';
import '../services/scan_history_service.dart';
import '../services/report_service.dart';
import 'chat_screen.dart';

class ScanResultScreen extends StatefulWidget {
  final File? imageFile;
  final String? imageUrl;
  final String? preAnalyzedCondition;
  final int? preAnalyzedConfidence;
  final String? preAnalyzedExplanation;
  final String? preAnalyzedIcd10Code;
  final String? preAnalyzedHeatmapBase64;
  final bool isFromHistory;

  const ScanResultScreen({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.preAnalyzedCondition,
    this.preAnalyzedConfidence,
    this.preAnalyzedExplanation,
    this.preAnalyzedIcd10Code,
    this.preAnalyzedHeatmapBase64,
    this.isFromHistory = false,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  String condition = "Analyzing...";
  String icd10Code = "N/A";
  int confidence = 0;
  String explanation = "";
  String? heatmapBase64;
  bool isLoading = true;
  String? errorMessage;
  bool _actionTaken = false;

  final ScanHistoryService historyService = ScanHistoryService();
  final String backendUrl = "http://192.168.27.42:8000/predict";

  final Map<String, String> icd10Mapping = {
    'actinic_keratosis': 'L57.0',
    'acne': 'L70.9',
    'melanoma': 'C43.9',
    'psoriasis': 'L40.9',
    'eczema': 'L30.9',
    'lupus': 'M32.9',
    'ringworm': 'B35.9',
    'warts': 'B07.9',
  };

  @override
  void initState() {
    super.initState();
    // If pre-analyzed data is provided, use it instead of analyzing again
    if (widget.preAnalyzedCondition != null) {
      setState(() {
        condition = widget.preAnalyzedCondition!;
        confidence = widget.preAnalyzedConfidence ?? 0;
        explanation =
            widget.preAnalyzedExplanation ?? "No detailed analysis available.";
        icd10Code = widget.preAnalyzedIcd10Code ?? 'None';
        heatmapBase64 = widget.preAnalyzedHeatmapBase64;
        isLoading = false;
      });
    } else if (widget.imageFile != null) {
      // Check if file exists before analyzing
      if (widget.imageFile!.existsSync()) {
        _analyzeImage(widget.imageFile!);
      } else {
        setState(() {
          errorMessage =
              "Image file not found. The file may have been deleted or moved.";
          isLoading = false;
        });
      }
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    try {
      final uri = Uri.parse(backendUrl);
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Backend response: $responseBody');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody);

        print('Parsed JSON: $jsonData');
        print('Status field: ${jsonData['status']}');

        // Handle both disease detected (status: true) and normal skin (status: false)
        if (jsonData['status'] == true ||
            (jsonData['status'] == false &&
                jsonData['disease_class'] != null)) {
          if (mounted) {
            setState(() {
              condition = jsonData['disease_class'] ?? "Unknown";
              confidence = ((jsonData['probability'] ?? 0.0) * 100).toInt();
              explanation =
                  jsonData['explanation'] ?? "No detailed analysis available.";
              heatmapBase64 = jsonData['heatmap_base64'];
              icd10Code =
                  icd10Mapping[condition.toLowerCase().replaceAll(' ', '_')] ??
                  'None';
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              errorMessage = "Analysis failed. Status: ${jsonData['status']}";
              isLoading = false;
            });
          }
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print('Error in _analyzeImage: $e');
      if (mounted) {
        setState(() {
          errorMessage = "Connection failed.\nError: $e";
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleFindSpecialist() async {
    String query = "Dermatologist near me";

    // Smart search based on severity
    if (condition.toLowerCase().contains("melanoma") ||
        condition.toLowerCase().contains("carcinoma") ||
        condition.toLowerCase().contains("keratosis")) {
      query = "Skin cancer specialist near me";
    } else if (condition.toLowerCase().contains("acne")) {
      query = "Cosmetic dermatologist near me";
    }

    // Open Google Maps
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}",
    );

    try {
      if (!await launchUrl(url)) {
        throw 'Could not launch maps';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Maps application')),
        );
      }
    }
  }

  Future<void> saveScan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        widget.imageFile != null &&
        widget.imageFile!.existsSync()) {
      final newScan = ScanData(
        imagePath: widget.imageFile!.path,
        condition: condition,
        confidence: confidence,
        date: DateTime.now(),
        userId: user.uid,
      );
      await historyService.saveScan(newScan);
      if (!mounted) return;
      setState(() => _actionTaken = true);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (widget.imageFile == null || !widget.imageFile!.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image file not found. Cannot save scan.'),
        ),
      );
    }
  }

  Future<void> discardScan() async {
    if (widget.imageFile != null && widget.imageFile!.existsSync()) {
      final discardedScan = ScanData(
        imagePath: widget.imageFile!.path,
        condition: condition,
        confidence: confidence,
        date: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser?.uid ?? 'guest',
        isDeleted: true,
      );
      await historyService.saveScan(discardedScan);
      if (!mounted) return;
      setState(() => _actionTaken = true);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image file not found. Cannot discard scan.'),
        ),
      );
    }
  }

  void showConfirmDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Widget infoBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.isFromHistory || _actionTaken,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !widget.isFromHistory) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please Save or Discard the scan before going back.",
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            "Analysis Result",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2E8BC0),
          automaticallyImplyLeading: widget.isFromHistory || _actionTaken,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E8BC0)),
              )
            : errorMessage != null
            ? Center(
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child:
                            widget.imageFile != null &&
                                widget.imageFile!.existsSync()
                            ? Image.file(widget.imageFile!, fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Result Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              condition,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E8BC0),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                infoBadge("ICD-10", icd10Code, Colors.blueGrey),
                                infoBadge(
                                  "Confidence",
                                  "$confidence%",
                                  Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _actionButton(
                      Icons.chat_bubble_outline,
                      "Chat with AI Doctor",
                      const Color(0xFF2E8BC0),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              initialContext:
                                  "Patient has $condition ($confidence% confidence). AI Explanation: $explanation",
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    _actionButton(
                      Icons.visibility_outlined,
                      "View Report",
                      const Color(0xFF2E8BC0),
                      () async {
                        if (widget.imageFile != null &&
                            widget.imageFile!.existsSync()) {
                          Uint8List originalBytes = await widget.imageFile!
                              .readAsBytes();
                          Uint8List heatmapBytes = (heatmapBase64 != null)
                              ? base64Decode(heatmapBase64!)
                              : originalBytes;
                          await ReportService.generateAndDisplayReport(
                            diseaseName: condition,
                            confidence: confidence / 100,
                            icd10Code: icd10Code,
                            originalImageBytes: originalBytes,
                            heatmapImageBytes:
                                heatmapBytes, // Heatmap only in report [cite: 72, 100]
                            explanation: explanation,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Image file not found. Cannot generate report.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Find Nearest Specialist with Permission [cite: 551, 624]
                    _actionButton(
                      Icons.location_on_outlined,
                      "Find Nearest Specialist",
                      const Color(0xFF2E8BC0),
                      _handleFindSpecialist,
                    ),
                    const SizedBox(height: 12),

                    if (!widget.isFromHistory) ...[
                      _actionButton(
                        Icons.save_alt,
                        "Save Scan",
                        const Color(0xFF3498DB),
                        () {
                          showConfirmDialog(
                            "Save Scan",
                            "Would you like to save this result to your history?",
                            saveScan,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _actionButton(
                        Icons.delete_forever_outlined,
                        "Discard Scan",
                        Colors.redAccent,
                        () {
                          showConfirmDialog(
                            "Discard Scan",
                            "Are you sure? This will move the scan to Recently Deleted.",
                            discardScan,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
