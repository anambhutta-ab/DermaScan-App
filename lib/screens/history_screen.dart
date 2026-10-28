import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/scan_card.dart';
import '../models/scan_data.dart';
import '../screens/scan_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  // Use the Hive model type
  final List<ScanData> allScans;
  final Function(ScanData) onDelete;

  const HistoryScreen({
    super.key,
    required this.allScans,
    required this.onDelete,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _sortOrder = 'Newest First';
  String? _selectedFilter;

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

  // Uses the Hive model type
  List<ScanData> _getFilteredAndSortedScans() {
    List<ScanData> scans = List.from(widget.allScans);

    // Apply filter
    if (_selectedFilter != null && _selectedFilter != 'All') {
      final filterLower = _selectedFilter!
          .trim()
          .toLowerCase(); // Normalize filter string

      scans = scans.where((scan) {
        // --- FIX: Normalize the stored condition before comparison ---
        final scanConditionLower = scan.condition.trim().toLowerCase();
        return scanConditionLower == filterLower;
        // -----------------------------------------------------------
      }).toList();
    }
    // Apply sort
    if (_sortOrder == 'Newest First') {
      scans.sort((a, b) => b.date.compareTo(a.date));
    } else {
      scans.sort((a, b) => a.date.compareTo(b.date));
    }

    return scans;
  }

  List<String> _getAllConditions() {
    return [
      'All',
      'Eczema',
      'Melanoma',
      'Acne',
      'Psoriasis',
      'Ringworm',
      'Lupus',
      'Acintic Enfeksiyonel',
      'Warts',
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds automatically when widget.allScans changes from parent (HomeScreen)
    final filteredScans = _getFilteredAndSortedScans();
    final allConditions = _getAllConditions();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2E8BC0), // Primary blue
        elevation: 0,
        actions: [
          // Sort Icon
          PopupMenuButton<String>(
            icon: const Icon(Icons.swap_vert, size: 24),
            tooltip: 'Sort',
            onSelected: (String value) {
              setState(() {
                _sortOrder = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Newest First',
                child: Row(
                  children: [
                    Icon(
                      _sortOrder == 'Newest First'
                          ? Icons.check
                          : Icons.schedule,
                      color: const Color(0xFF2E8BC0),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Newest First'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Oldest First',
                child: Row(
                  children: [
                    Icon(
                      _sortOrder == 'Oldest First'
                          ? Icons.check
                          : Icons.history,
                      color: const Color(0xFF2E8BC0),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Oldest First'),
                  ],
                ),
              ),
            ],
          ),
          // Filter Icon
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune, size: 24),
            tooltip: 'Filter',
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) =>
                allConditions.map((String value) {
                  return PopupMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          (_selectedFilter ?? 'All') == value
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: const Color(0xFF2E8BC0),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          value,
                          style: TextStyle(
                            fontWeight: value == 'All'
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: value == 'All'
                                ? const Color(0xFF2E8BC0)
                                : const Color(0xFF3A4F5B),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredScans.isEmpty
                ? Center(
                    child: Text(
                      widget.allScans.isEmpty
                          ? "No scan history available."
                          : "No scans match the selected filter.",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7F9DAC),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: filteredScans.length,
                    itemBuilder: (context, index) {
                      final scan = filteredScans[index];
                      return Dismissible(
                        // Use HiveObject key for persistent deletion
                        key: ValueKey(scan.key ?? scan.date.toIso8601String()),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Scan'),
                                content: const Text(
                                  'Are you sure you want to delete this scan?',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE63946),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        onDismissed: (_) {
                          widget.onDelete(
                            scan,
                          ); // Calls _deleteScan in HomeScreen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Scan deleted")),
                          );
                        },
                        child: ScanCard(
                          imagePath: scan.imagePath,
                          condition: scan.condition,
                          confidence: scan.confidence,
                          date: scan.date,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E8BC0), Color(0xFF0C4160)],
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
          ),
        ],
      ),
    );
  }
}
