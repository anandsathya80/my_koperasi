import 'package:hive/hive.dart';

part 'withdrawal_model.g.dart';

@HiveType(typeId: 2)
class Withdrawal extends HiveObject {
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

  Withdrawal({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.note,
    required this.date,
  });
}