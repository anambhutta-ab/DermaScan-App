import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/scan_data.dart';


 class DeletedScanCard extends StatelessWidget {
  final ScanData scan;
  final VoidCallback onRestore;
  final VoidCallback onHardDelete;

  const DeletedScanCard({
    super.key,
    required this.scan,
    required this.onRestore,
    required this.onHardDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(scan.imagePath),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          title: Text(
            scan.condition,
            style: const TextStyle(
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "DELETED: ${DateFormat('MMM d, y').format(scan.date)}",
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // --- Custom Trailing Action Buttons ---
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.restore, color: Color(0xFF2E8BC0)),
                tooltip: 'Restore Scan',
                onPressed: onRestore,
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                tooltip: 'Delete Permanently',
                onPressed: onHardDelete,
              ),
            ],
          ),
          // ------------------------------------
        ),
      ),
    );
  }
}


