import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/withdrawal_model.dart';

class WithdrawalProvider extends ChangeNotifier {
  final box = Hive.box<Withdrawal>('withdrawals');

  List<Withdrawal> getByMember(String memberId) {
    return box.values.where((e) => e.memberId == memberId).toList();
  }

  double getTotal(String memberId) {
    final data = getByMember(memberId);
    return data.fold(0.0, (sum, item) => sum + item.amount);
  }

  void addWithdrawal(String memberId, double amount, String note) {
    final data = Withdrawal(
      id: const Uuid().v4(),
      memberId: memberId,
      amount: amount,
      note: note,
      date: DateTime.now(),
    );

    box.put(data.id, data);
    notifyListeners();
  }

  void updateWithdrawal(Withdrawal item, double amount, String note) {
    item.amount = amount;
    item.note = note;
    item.save();
    notifyListeners();
  }

  void deleteWithdrawal(String id) {
    box.delete(id);
    notifyListeners();
  }
}
