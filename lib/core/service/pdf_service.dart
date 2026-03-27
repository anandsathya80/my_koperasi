import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateTransactionPdf({
    required String name,
    required String type, // "Tabungan" / "Penarikan"
    required double amount,
    required String note,
    required DateTime date,
    required double balance,
  }) async {
    final pdf = pw.Document();

    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "BUKTI TRANSAKSI",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                _row("Nama", name),
                _row("Jenis", type),
                _row("Nominal", formatCurrency.format(amount)),
                _row("Saldo Akhir", formatCurrency.format(balance)),
                _row("Tanggal", DateFormat('dd MMM yyyy HH:mm').format(date)),
                _row("Catatan", note.isEmpty ? "-" : note),
                pw.Divider(),
                pw.SizedBox(height: 30),
                pw.Center(
                  child: pw.Text(
                    "Terima kasih 🙏",
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.Widget _row(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
