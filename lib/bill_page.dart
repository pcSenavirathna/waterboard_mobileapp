import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BillPage extends StatelessWidget {
  final String customerId;
  final String name;
  final String date;
  final double? previousMeter;
  final double? currentMeter;
  final double? outstanding;
  final double monthCharge;
  final double totalAmount;

  const BillPage({
    super.key,
    required this.customerId,
    required this.name,
    required this.date,
    required this.previousMeter,
    required this.currentMeter,
    required this.outstanding,
    required this.monthCharge,
    required this.totalAmount,
  });

  Future<void> _generateAndSharePdf(BuildContext context) async {
    final pdf = pw.Document();
    final logo = await imageFromAssetBundle('assets/images/waterlogo.jpg');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Image(logo, width: 80, height: 80),
                  pw.SizedBox(height: 8),
                  pw.Text('Waterboard Bill', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Customer ID: $customerId'),
            pw.Text('Name: $name'),
            pw.Text('Date: $date'),
            pw.SizedBox(height: 8),
            pw.Text('Previous Meter: ${previousMeter?.toInt() ?? "-"}'),
            pw.Text('Current Meter: ${currentMeter?.toInt() ?? "-"}'),
            pw.Text('Outstanding: Rs: ${outstanding?.toStringAsFixed(2) ?? "0"}'),
            pw.Text('Permanent Charge: Rs: 200.00'),
            pw.Text('This Month\'s Charge: Rs: ${monthCharge.toStringAsFixed(2)}'),
            pw.SizedBox(height: 8),
            pw.Text('Total Amount: Rs: ${totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'waterboard_bill.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF4F5BD5),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Prevents overflow
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/waterlogo.jpg',
                        width: 80, height: 80),
                    const SizedBox(height: 8),
                    Text(
                      'Waterboard Bill',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Field')),
                  DataColumn(label: Text('Value')),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('Customer ID')),
                    DataCell(Text(customerId)),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Name')),
                    DataCell(Text(name)),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Date')),
                    DataCell(Text(date)),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Previous Meter')),
                    DataCell(Text(previousMeter != null
                        ? previousMeter!.toInt().toString()
                        : "-")),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Current Meter')),
                    DataCell(Text(currentMeter != null
                        ? currentMeter!.toInt().toString()
                        : "-")),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Outstanding')),
                    DataCell(Text(
                      outstanding != null
                          ? 'Rs: ${outstanding!.toStringAsFixed(2)}'
                          : "0",
                      style: TextStyle(
                        color:
                            (outstanding ?? 0) <= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Permanent Charge')),
                    const DataCell(Text(
                      'Rs: 200.00',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text("This Month Charge")),
                    DataCell(Text(
                      monthCharge > 0
                          ? 'Rs: ${monthCharge.toStringAsFixed(2)}'
                          : "-",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Total Amount')),
                    DataCell(Text(
                      'Rs: ${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )),
                  ]),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Share/Download Bill PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _generateAndSharePdf(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}