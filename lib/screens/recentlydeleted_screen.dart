import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/scan_history_service.dart';
import '../models/scan_data.dart';
import '../widgets/deletescan_card.dart';
class RecentlyDeletedScreen extends StatefulWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  State<RecentlyDeletedScreen> createState() => _RecentlyDeletedScreenState();
}

class _RecentlyDeletedScreenState extends State<RecentlyDeletedScreen> {
  List<ScanData> _deletedScans = [];
  final ScanHistoryService _scanService = ScanHistoryService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadDeletedScans();
  }

  Future<void> _loadDeletedScans() async {
    if (_userId == null) return;
    final scans = await _scanService.getDeletedScansForUser(_userId);
    setState(() {
      _deletedScans = scans;
    });
  }

  Future<void> _restoreScan(ScanData scan) async {
    await _scanService.restoreScan(scan);
    _loadDeletedScans();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Scan restored to history")));
    }
  }

  Future<void> _hardDeleteScan(ScanData scan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently Delete?'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this scan forever?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete Forever',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _scanService.hardDeleteScan(scan);
      _loadDeletedScans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scan permanently deleted")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recently Deleted',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2E8BC0),
        elevation: 0,
      ),
      body: _deletedScans.isEmpty
          ? const Center(
              child: Text(
                'No recently deleted scans.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _deletedScans.length,
              itemBuilder: (context, index) {
                final scan = _deletedScans[index];

                // --- Using the new DeletedScanCard ---
                return DeletedScanCard(
                  scan: scan,
                  onRestore: () => _restoreScan(scan),
                  onHardDelete: () => _hardDeleteScan(scan),
                );
                // ------------------------------------
              },
            ),
    );
  }
}