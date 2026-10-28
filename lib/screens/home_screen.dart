import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/scan_card.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import '../screens/scan_result_screen.dart';
import '../models/scan_data.dart';
import '../services/scan_history_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<ScanData> _allScans = [];
  List<ScanData> _recentScans = [];
  final ScanHistoryService _scanService = ScanHistoryService();

  final Map<String, String> icd10Mapping = {
    'actinic keratosis': 'L57.0',
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
    _loadScansFromHive();
  }

  Future<void> _loadScansFromHive() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final allScans = await _scanService.getActiveScansForUser(currentUser.uid);

    setState(() {
      _allScans = allScans;
      _recentScans = allScans.take(5).toList();
    });
  }

  // --- NEW RELOAD HANDLER ---
  void _handleReloadHistory() {
    // This method is called from ProfileScreen to refresh data
    _loadScansFromHive();
  }

  void _removeScanFromList(ScanData scan) {
    setState(() {
      _allScans.removeWhere((s) => s.key == scan.key);
      _recentScans.removeWhere((s) => s.key == scan.key);
    });
  }

  Future<void> _softDeleteScan(ScanData scan) async {
    await _scanService.softDeleteScan(scan);
  }

  void _handleDeleteFromHistory(ScanData scan) async {
    _removeScanFromList(scan);
    await _softDeleteScan(scan);
  }

  Widget _buildHistoryScreen() {
    return HistoryScreen(
      allScans: _allScans,
      onDelete: (scan) {
        _handleDeleteFromHistory(scan);
      },
    );
  }

  List<Widget> _buildScreens() {
    return [
      _buildHomeContent(),
      _buildHistoryScreen(), // Calling the new getter
      ChatScreen(),
      ProfileScreen(onReloadHistory: _handleReloadHistory),
    ];
  }
  // --- END FIX ---

  Widget _buildHomeContent() {
    const int opacity4C = 0x4C2E8BC0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Camera and Gallery Cards
            Row(
              children: [
                // Take a Photo Card
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera),
                    child: Container(
                      height: 160,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E8BC0), Color(0xFF0C4160)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(opacity4C),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(64),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Take a Photo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Upload from Gallery Card
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      height: 160,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E8BC0), Color(0xFF0C4160)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(opacity4C),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(64),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Upload from Gallery',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Recent Scans Section
            const Text(
              'Recent Scans',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0C4160),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),

            _recentScans.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        "No recent scans yet.\nStart by scanning an image.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xCC2E8BC0), 
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentScans.length,
                    itemBuilder: (context, index) {
                      final scan = _recentScans[index];
                      return Dismissible(
                        key: ValueKey(scan.key ?? scan.date.toString()),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmation(context);
                        },
                        onDismissed: (direction) {
                          _removeScanFromList(scan);
                          _softDeleteScan(scan);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Scan sent to Recently Deleted'),
                            ),
                          );
                        },
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE63946),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        child: ScanCard(
                          imagePath: scan.imagePath,
                          condition: scan.condition,
                          confidence: scan.confidence,
                          date: scan.date,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB1D4E0), Color(0xFF2E8BC0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScanResultScreen(
                                  imageFile: File(scan.imagePath),
                                  preAnalyzedCondition: scan.condition,
                                  preAnalyzedConfidence: scan.confidence,
                                  preAnalyzedIcd10Code: icd10Mapping[scan.condition.toLowerCase().replaceAll(' ', '_')] ?? 'L98.9',
                                  preAnalyzedExplanation: "Previously analyzed result from history.",
                                  isFromHistory: true,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // 3. Privacy Dialog First
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Privacy Assurance"),
        content: const Text(
            "The image you upload is used strictly for disease detection. "
            "It will NOT be shared with third parties or used for model training."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("I Understand")),
        ],
      ),
    );

    if (proceed != true) return;

    final permission = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();

    if (!permission.isGranted) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanResultScreen(imageFile: imageFile)),
    );

    if (mounted) {
      await _loadScansFromHive();
    }
  }
 Widget _buildActionCard(String title, IconData icon, int shadowColor) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E8BC0), Color(0xFF0C4160)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Color(shadowColor), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withAlpha(64), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Move to Deleted'),
          content: const Text(
            'Are you sure you want to move this scan to Recently Deleted?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Derma Scan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
