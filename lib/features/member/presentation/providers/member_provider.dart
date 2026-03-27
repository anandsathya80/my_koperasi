import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/member_model.dart';

class MemberProvider extends ChangeNotifier {
  final box = Hive.box<Member>('members');

  List<Member> get members => box.values.toList();

  void addMember(String name, String phone) {
    final newMember = Member(
      id: const Uuid().v4(),
      name: name,
      phone: phone,
      createdAt: DateTime.now(),
    );

    box.put(newMember.id, newMember);
    notifyListeners();
  }

  void updateMember(Member member, String name, String phone) {
    member.name = name;
    member.phone = phone;
    member.save();
    notifyListeners();
  }

  void deleteMember(String id) {
    box.delete(id);
    notifyListeners();
  }
}