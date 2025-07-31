import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BillPage extends StatelessWidget {
  final String customerId;
  final String name;
  final String date;
  final double? previousMeter;
  final double? currentMeter;
  final double? outstanding;
  final double monthCharge;
  final double totalAmount;

  BillPage({
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

  final GlobalKey _globalKey = GlobalKey();

  Future<void> _captureAndShareBill() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/waterboard_bill.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Waterboard Bill');
    } catch (e) {
      print('Error: $e');
    }
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: _globalKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Image.asset('assets/images/waterlogo.jpg',
                                width: 80, height: 80),
                            const SizedBox(height: 8),
                            const Text(
                              'ශ්‍රී ශාන්තිනිකේතන ප්‍රජා ජල සංවිධානය',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Waterboard Bill',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      DataTable(
                        columns: const [
                          DataColumn(
                              label: Text('Field',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Value',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
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
                            const DataCell(Text('Number of Units')),
                            DataCell(Text(
                              (currentMeter != null && previousMeter != null)
                                  ? (currentMeter! - previousMeter!)
                                      .toInt()
                                      .toString()
                                  : "-",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            )),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text('Outstanding')),
                            DataCell(Text(
                              outstanding != null
                                  ? 'Rs: ${outstanding!.toStringAsFixed(2)}'
                                  : "0",
                              style: TextStyle(
                                color: (outstanding ?? 0) <= 0
                                    ? Colors.green
                                    : Colors.red,
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
                                fontSize: 18,
                              ),
                            )),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Share/Download Bill Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _captureAndShareBill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}