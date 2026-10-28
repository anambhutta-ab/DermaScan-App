import 'package:hive/hive.dart';

part 'scan_data.g.dart';

@HiveType(typeId: 0)
class ScanData extends HiveObject {
  @HiveField(0)
  late String imagePath;

  @HiveField(1)
  late String condition;

  @HiveField(2)
  late int confidence;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late String userId;

  @HiveField(5) // <--- NEW FIELD FOR SOFT DELETE
  late bool isDeleted;

  ScanData({
    required this.imagePath,
    required this.condition,
    required this.confidence,
    required this.date,
    required this.userId,
    this.isDeleted = false, // Initialize to false
  });
}
