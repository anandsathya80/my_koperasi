import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/service/pdf_service.dart';
import '../../../saving/data/models/saving_model.dart';
import '../../../saving/presentation/providers/saving_provider.dart';
import '../../../withdrawal/data/models/withdrawal_model.dart';
import '../../../withdrawal/presentation/providers/withdrawal_provider.dart';
import '../../data/models/member_model.dart';

class MemberDetailPage extends StatelessWidget {
  final Member member;

  const MemberDetailPage({super.key, required this.member});

  String formatRupiah(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

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
      appBar: AppBar(title: const Text("Detail Member")),
      body: Column(
        children: [
          _header(balance),
          _summary(totalSaving, totalWithdrawal),
          Expanded(
            child: _transactionList(
              context,
              savings,
              withdrawals,
              balance,
            ),
          ),
        ],
      ),
      floatingActionButton: _fab(context, balance),
    );
  }

  // ================= HEADER =================
  Widget _header(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        ),
      ),
      child: Column(
        children: [
          Text(member.name, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Text(formatRupiah(balance),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summary(double saving, double withdrawal) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _card("Tabungan", saving, Colors.green),
          const SizedBox(width: 10),
          _card("Penarikan", withdrawal, Colors.red),
        ],
      ),
    );
  }

  Widget _card(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        constraints: const BoxConstraints(minHeight: 100), // tinggi minimal
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatRupiah(amount),
                style: TextStyle(
                    color: color, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LIST =================
  Widget _transactionList(
    BuildContext context,
    List<Saving> savings,
    List<Withdrawal> withdrawals,
    double balance,
  ) {
    if (savings.isEmpty && withdrawals.isEmpty) {
      return const Center(child: Text("Belum ada transaksi"));
    }

    final all = [
      ...savings.map((e) => {'type': 'in', 'data': e}),
      ...withdrawals.map((e) => {'type': 'out', 'data': e}),
    ];

    all.sort((a, b) {
      final aDate = (a['data'] as dynamic)?.date ?? DateTime.now();
      final bDate = (b['data'] as dynamic)?.date ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    return ListView.builder(
      itemCount: all.length,
      itemBuilder: (context, index) {
        final item = all[index];
        final isIn = item['type'] == 'in';

        // cast data sesuai tipe
        final data = item['data'];

        // periksa tipe data
        double amount = 0;
        String note = '-';
        DateTime date = DateTime.now();

        if (isIn && data is Saving) {
          amount = data.amount ?? 0;
          note = data.note ?? '-';
          date = data.date ?? DateTime.now();
        } else if (!isIn && data is Withdrawal) {
          amount = data.amount ?? 0;
          note = data.note ?? '-';
          date = data.date ?? DateTime.now();
        }

        return _transactionTile(
          context,
          isIn,
          amount,
          note,
          date,
          balance,
        );
      },
    );
  }

  // ================= TILE =================
  Widget _transactionTile(
    BuildContext context,
    bool isIn,
    double amount,
    String note,
    DateTime date,
    double balance,
  ) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(
          isIn ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIn ? Colors.green : Colors.red,
        ),
        title: Text(formatRupiah(amount)),
        subtitle: Text(note.isEmpty ? "-" : note),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(formatDate(date), style: const TextStyle(fontSize: 10)),
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () async {
                await _showPrintDialog(
                  context: context,
                  type: isIn ? "Tabungan" : "Penarikan",
                  amount: amount,
                  note: note,
                  date: date,
                  balance: balance,
                );
              },
            )
          ],
        ),
      ),
    );
  }

  // ================= FAB =================
  Widget _fab(BuildContext context, double balance) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "add",
          onPressed: () => _showSavingForm(context, member.id),
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: "withdraw",
          backgroundColor: Colors.red,
          onPressed: () => _showWithdrawalForm(context, member.id, balance),
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }

  // ================= PRINT =================
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
  void _showSavingForm(BuildContext context, String memberId) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                      child: Column(children: [
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
                          const Text(
                            "Tambah Tabungan",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                    if (!formKey.currentState!.validate())
                                      return;

                                    final amount = double.tryParse(
                                            amountController.text) ??
                                        0;

                                    Provider.of<SavingProvider>(context,
                                            listen: false)
                                        .addSaving(memberId, amount,
                                            noteController.text);

                                    Navigator.pop(context);
                                  },
                                  child: const Text("Simpan"),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ]))));
        });

    // ================= FORM TARIK =================
  }

  void _showWithdrawalForm(
      BuildContext context, String memberId, double balance) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(children: [
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
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
                                        if (!formKey.currentState!.validate())
                                          return;

                                        final amount = double.tryParse(
                                                amountController.text) ??
                                            0;

                                        Provider.of<WithdrawalProvider>(context,
                                                listen: false)
                                            .addWithdrawal(memberId, amount,
                                                noteController.text);

                                        Navigator.pop(context);
                                      },
                                      child: const Text("Tarik"),
                                    ))
                              ],
                            )),
                      ),
                    ]),
                  )));
        });
  }
}
