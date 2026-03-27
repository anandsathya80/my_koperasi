import 'package:hive/hive.dart';

part 'saving_model.g.dart';

@HiveType(typeId: 1)
class Saving extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String note;

  @HiveField(4)
  DateTime date;

  Saving({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.note,
    required this.date,
  });
}