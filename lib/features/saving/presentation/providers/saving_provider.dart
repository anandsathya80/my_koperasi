import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/saving_model.dart';

class SavingProvider extends ChangeNotifier {
  final box = Hive.box<Saving>('savings');

  List<Saving> getByMember(String memberId) {
    return box.values
        .where((e) => e.memberId == memberId)
        .toList();
  }

  double getTotal(String memberId) {
    final data = getByMember(memberId);
    return data.fold(0.0, (sum, item) => sum + item.amount);
  }

  void addSaving(String memberId, double amount, String note) {
    final data = Saving(
      id: const Uuid().v4(),
      memberId: memberId,
      amount: amount,
      note: note,
      date: DateTime.now(),
    );

    box.put(data.id, data);
    notifyListeners();
  }

  void updateSaving(Saving saving, double amount, String note) {
    saving.amount = amount;
    saving.note = note;
    saving.save();
    notifyListeners();
  }

  void deleteSaving(String id) {
    box.delete(id);
    notifyListeners();
  }
}