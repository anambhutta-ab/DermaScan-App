import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_data.dart';

class ScanHistoryService {
  static const String boxName = 'scanHistoryBox';

  Future<Box<ScanData>> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      // Use Hive.openBox to open the box only once
      return await Hive.openBox<ScanData>(boxName);
    }
    return Hive.box<ScanData>(boxName);
  }

  // 1. Save a new scan result
  Future<void> saveScan(ScanData scan) async {
    final box = await _openBox();
    await box.add(scan);
  }

  // 2. Get all scans for a specific user
  Future<List<ScanData>> getScansForUser(String userId) async {
    final box = await _openBox();
    // Filter the scans to only show those belonging to the current user
    return box.values
        .where((scan) => scan.userId == userId)
        .toList()
        .reversed 
        .toList();
  }

  // 3. Clear all scans 
  Future<void> clearAllScans() async {
    final box = await _openBox();
    await box.clear();
  }

  Future<List<ScanData>> getActiveScansForUser(String userId) async {
    final box = await _openBox();
    return box.values
        .where(
          (scan) => scan.userId == userId && scan.isDeleted == false,
        ) // <--- FILTER FOR ACTIVE
        .toList()
        .reversed
        .toList();
  }

  // Get ALL DELETED scans for a specific user
  Future<List<ScanData>> getDeletedScansForUser(String userId) async {
    final box = await _openBox();
    return box.values
        .where(
          (scan) => scan.userId == userId && scan.isDeleted == true,
        ) // <--- FILTER FOR DELETED
        .toList()
        .reversed
        .toList();
  }

  // Soft Delete (Move to Recently Deleted)
  Future<void> softDeleteScan(ScanData scan) async {
    scan.isDeleted = true;
    await scan.save(); // Save the HiveObject instance
  }

  // Restore (Move back to Active)
  Future<void> restoreScan(ScanData scan) async {
    scan.isDeleted = false;
    await scan.save(); // Save the HiveObject instance
  }

  // Permanent Delete (Remove from Hive box)
  Future<void> hardDeleteScan(ScanData scan) async {
    await scan.delete(); // Permanently remove the object
  }
}
