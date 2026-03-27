import 'package:hive/hive.dart';

part 'member_model.g.dart';

@HiveType(typeId: 0)
class Member extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  DateTime createdAt;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
  });
}