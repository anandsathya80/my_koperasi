import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/service/pdf_service.dart';
import '../../../saving/data/models/saving_model.dart';
import '../../../saving/presentation/providers/saving_provider.dart';
import '../../../withdrawal/data/models/withdrawal_model.dart';
import '../../../withdrawal/presentation/providers/withdrawal_provider.dart';
import '../../data/models/member_model.dart';

class MemberDetailPage extends StatelessWidget {
  final Member member;

  const MemberDetailPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final savingProvider = Provider.of<SavingProvider>(context);
    final withdrawalProvider = Provider.of<WithdrawalProvider>(context);

    final savings = savingProvider.getByMember(member.id);
    final withdrawals = withdrawalProvider.getByMember(member.id);

    final totalSaving = savingProvider.getTotal(member.id);
    final totalWithdrawal = withdrawalProvider.getTotal(member.id);

    final balance = totalSaving - totalWithdrawal;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Detail Member"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(member, balance),
            _summaryCard(totalSaving, totalWithdrawal),
            _actionButton(context, balance),
            _transactionList(context, savings, withdrawals),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(Member member, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Text(
              member.name[0].toUpperCase(),
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ),
          const SizedBox(height: 10),
          Text(member.name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Text(member.phone, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          const Text("Total Saldo", style: TextStyle(color: Colors.white70)),
          Text(
            "Rp ${balance.toStringAsFixed(0)}",
            style: const TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summaryCard(double saving, double withdrawal) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _summaryItem("Tabungan", saving, Colors.green),
          const SizedBox(width: 10),
          _summaryItem("Penarikan", withdrawal, Colors.red),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              "Rp ${amount.toStringAsFixed(0)}",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACTION =================
  Widget _actionButton(BuildContext context, double balance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _menuItem(
            context,
            "Tambah Tabungan",
            Icons.arrow_downward,
            Colors.green,
            () => _showSavingForm(context, member.id),
          ),
          const SizedBox(height: 10),
          _menuItem(
            context,
            "Tarik Saldo",
            Icons.arrow_upward,
            Colors.red,
            () => _showWithdrawalForm(context, member.id, balance),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.1),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // ================= LIST =================
  Widget _transactionList(BuildContext context, List<Saving> savings,
      List<Withdrawal> withdrawals) {
    final all = [
      ...savings.map((e) => {'type': 'in', 'data': e}),
      ...withdrawals.map((e) => {'type': 'out', 'data': e}),
    ];

    all.sort((a, b) {
      final dateA = (a['data'] as dynamic).date;
      final dateB = (b['data'] as dynamic).date;
      return dateB.compareTo(dateA);
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: all.length,
      itemBuilder: (context, index) {
        final item = all[index];
        final isIn = item['type'] == 'in';

        if (isIn) {
          final data = item['data'] as Saving;
          return _transactionTile(true, data.amount, data.note, data.date);
        } else {
          final data = item['data'] as Withdrawal;
          return _transactionTile(false, data.amount, data.note, data.date);
        }
      },
    );
  }

  Widget _transactionTile(
      bool isIn, double amount, String note, DateTime date) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          isIn ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIn ? Colors.green : Colors.red,
        ),
        title: Text(
          "Rp ${amount.toStringAsFixed(0)}",
          style: TextStyle(
              color: isIn ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(note),
        trailing: Text("${date.day}/${date.month}/${date.year}"),
      ),
    );
  }

  // ================= PRINT DIALOG =================
  Future<void> _showPrintDialog({
    required BuildContext context,
    required String type,
    required double amount,
    required String note,
    required DateTime date,
    required double balance,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cetak Bukti?"),
        content: const Text("Ingin mencetak bukti transaksi?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Tidak")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Ya")),
        ],
      ),
    );

    if (result == true) {
      await PdfService.generateTransactionPdf(
        name: member.name,
        type: type,
        amount: amount,
        note: note,
        date: date,
        balance: balance,
      );
    }
  }

  // ================= FORM TABUNGAN =================
  void _showSavingForm(BuildContext context, String memberId,
      {Saving? saving}) {
    final amountController =
        TextEditingController(text: saving?.amount.toString() ?? "");
    final noteController = TextEditingController(text: saving?.note ?? "");

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 🔝 HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      ),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          saving == null ? "Tambah Tabungan" : "Edit Tabungan",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // 📄 FORM
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Nominal wajib diisi";
                              }
                              final value = double.tryParse(v);
                              if (value == null) return "Harus angka";
                              if (value <= 0) return "Harus > 0";
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Nominal",
                              prefixIcon: const Icon(Icons.attach_money),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: noteController,
                            decoration: InputDecoration(
                              labelText: "Catatan",
                              prefixIcon: const Icon(Icons.note),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                final provider = Provider.of<SavingProvider>(
                                    context,
                                    listen: false);

                                final amount =
                                    double.parse(amountController.text);
                                final now = DateTime.now();

                                provider.addSaving(
                                    memberId, amount, noteController.text);

                                final totalSaving = provider.getTotal(memberId);

                                final withdrawalTotal =
                                    Provider.of<WithdrawalProvider>(context,
                                            listen: false)
                                        .getTotal(memberId);

                                final newBalance =
                                    totalSaving - withdrawalTotal;

                                Navigator.pop(context);

                                _showSnackBar(context, "Tabungan berhasil 💰");

                                await _showPrintDialog(
                                  context: context,
                                  type: "Tabungan",
                                  amount: amount,
                                  note: noteController.text,
                                  date: now,
                                  balance: newBalance,
                                );
                              },
                              child: const Text("Simpan"),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= FORM PENARIKAN =================
  void _showWithdrawalForm(
      BuildContext context, String memberId, double balance,
      {Withdrawal? item}) {
    final amountController =
        TextEditingController(text: item?.amount.toString() ?? "");
    final noteController = TextEditingController(text: item?.note ?? "");

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 🔝 HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.orange],
                      ),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Tarik Saldo",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Saldo: Rp ${balance.toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  // FORM
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Nominal wajib diisi";
                              }
                              final value = double.tryParse(v);
                              if (value == null) return "Harus angka";
                              if (value <= 0) return "Harus > 0";
                              if (value > balance) {
                                return "Saldo tidak cukup!";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Nominal",
                              prefixIcon: const Icon(Icons.money_off),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: noteController,
                            decoration: InputDecoration(
                              labelText: "Catatan",
                              prefixIcon: const Icon(Icons.note),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                final provider =
                                    Provider.of<WithdrawalProvider>(context,
                                        listen: false);

                                final amount =
                                    double.parse(amountController.text);
                                final now = DateTime.now();

                                provider.addWithdrawal(
                                    memberId, amount, noteController.text);

                                final savingTotal = Provider.of<SavingProvider>(
                                        context,
                                        listen: false)
                                    .getTotal(memberId);

                                final withdrawalTotal =
                                    provider.getTotal(memberId);

                                final newBalance =
                                    savingTotal - withdrawalTotal;

                                Navigator.pop(context);

                                _showSnackBar(context, "Penarikan berhasil 💸");

                                await _showPrintDialog(
                                  context: context,
                                  type: "Penarikan",
                                  amount: amount,
                                  note: noteController.text,
                                  date: now,
                                  balance: newBalance,
                                );
                              },
                              child: const Text("Tarik Saldo"),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
