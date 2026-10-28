import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScanService {
  static const String _deletedScansKey = 'deleted_scans';
  final int _maxRecentDeletions = 5;

  Future<List<Map<String, dynamic>>> _getStoredScans() async {
    final prefs = await SharedPreferences.getInstance();
    final scansJson = prefs.getStringList(_deletedScansKey) ?? [];
    return scansJson
        .map((scan) => Map<String, dynamic>.from(json.decode(scan)))
        .toList();
  }

  Future<void> _saveScans(List<Map<String, dynamic>> scans) async {
    final prefs = await SharedPreferences.getInstance();
    final scansJson = scans.map((scan) => json.encode(scan)).toList();
    await prefs.setStringList(_deletedScansKey, scansJson);
  }

  // Add a deleted scan
  Future<void> addDeletedScan({
    required String scanId,
    required String scanName,
    required Map<String, dynamic> scanData,
  }) async {
    final scans = await _getStoredScans();
    
    // Remove if already exists (update case)
    scans.removeWhere((scan) => scan['id'] == scanId);
    
    // Add new scan at the beginning
    scans.insert(0, {
      'id': scanId,
      'name': scanName,
      'data': scanData,
      'deletedAt': DateTime.now().toIso8601String(),
      'isRestored': false,
    });

    // Keep only the most recent scans
    if (scans.length > _maxRecentDeletions) {
      scans.removeRange(_maxRecentDeletions, scans.length);
    }

    await _saveScans(scans);
  }

  // Get recently deleted scans (not yet restored)
  Stream<List<Map<String, dynamic>>> getRecentlyDeletedScans() async* {
    final scans = await _getStoredScans();
    // Only return non-restored scans
    yield scans.where((scan) => scan['isRestored'] != true).toList();
  }

  // Restore a deleted scan
  Future<bool> restoreScan(String scanId) async {
    final scans = await _getStoredScans();
    final index = scans.indexWhere((scan) => scan['id'] == scanId);
    
    if (index != -1) {
      // Mark as restored instead of removing
      scans[index]['isRestored'] = true;
      await _saveScans(scans);
      return true;
    }
    return false;
  }

  // Permanently delete a scan
  Future<void> permanentlyDeleteScan(String scanId) async {
    final scans = await _getStoredScans();
    scans.removeWhere((scan) => scan['id'] == scanId);
    await _saveScans(scans);
  }
}
