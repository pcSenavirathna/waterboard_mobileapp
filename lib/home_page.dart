import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bill_page.dart'; // <-- import the BillPage

class HomePage extends StatefulWidget {
  final String customerId;
  final String name;

  const HomePage({super.key, required this.customerId, required this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? previousMeter;
  double? currentMeter;
  double? outstanding;
  bool loading = true;

  final TextEditingController meterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMeterDetails();
  }

  Future<void> fetchMeterDetails() async {
    setState(() => loading = true);
    final url = Uri.parse(
        'https://waterboard-api.vercel.app/meter-details/${widget.customerId}');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null) {
        setState(() {
          previousMeter = (data['data']['previous_meter'] as num?)?.toDouble();
          currentMeter = (data['data']['current_meter'] as num?)?.toDouble();
          outstanding = (data['data']['Current_Outstanding'] as num?)
              ?.toDouble(); // <-- use exact key
        });
      } else {
        setState(() {
          previousMeter = null;
          currentMeter = null;
          outstanding = null;
        });
      }
    } catch (e) {
      setState(() {
        previousMeter = null;
        currentMeter = null;
        outstanding = null;
      });
    }
    setState(() => loading = false);
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  double calculateVariableCharge(double diff) {
    if (diff <= 0) return 0;
    if (diff <= 10) {
      return diff * 15;
    } else if (diff <= 20) {
      return 10 * 15 + (diff - 10) * 20;
    } else if (diff <= 30) {
      return 10 * 15 + 10 * 20 + (diff - 20) * 25;
    } else if (diff <= 40) {
      return 10 * 15 + 10 * 20 + 10 * 25 + (diff - 30) * 30;
    } else {
      return 10 * 15 + 10 * 20 + 10 * 25 + 10 * 30 + (diff - 40) * 50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy/MM/dd').format(now);

    // Calculate this month's charge
    double diff = (currentMeter ?? 0) - (previousMeter ?? 0);
    double monthCharge = calculateVariableCharge(diff);
    double permanentCharge = 200;
    double totalAmount = (outstanding ?? 0) + permanentCharge + monthCharge;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          TextButton(
            onPressed: () {
              // Optionally clear session or shared preferences here
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
        backgroundColor: const Color(0xFF4F5BD5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'ශ්‍රී ශාන්තිනිකේතන ප්‍රජා ජල සංවිධානය',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F5BD5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DataTable(
                    headingRowColor:
                        MaterialStateProperty.all(const Color(0xFF4F5BD5)),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    columns: const [
                      DataColumn(label: Text('Field')),
                      DataColumn(label: Text('Value')),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('Customer ID')),
                        DataCell(Text(
                          widget.customerId,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Name')),
                        DataCell(Text(widget.name)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Date')),
                        DataCell(Text(formattedDate)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Previous Meter')),
                        DataCell(Text(
                          previousMeter != null
                              ? previousMeter!.toInt().toString()
                              : "-",
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Current Meter')),
                        DataCell(Text(
                          currentMeter != null
                              ? currentMeter!.toInt().toString()
                              : "-",
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Number of Units')),
                        DataCell(Text(
                          (currentMeter != null && previousMeter != null)
                              ? (currentMeter! - previousMeter!).toInt().toString()
                              : "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                            fontSize: 18,
                          ),
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Current Outstanding')),
                        DataCell(Text(
                          outstanding != null
                              ? 'Rs: ${outstanding!.toStringAsFixed(2)}'
                              : "0",
                          style: TextStyle(
                            color: (outstanding ?? 0) <= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
                            fontSize: 18,
                          ),
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text("This Month's Charge")),
                        DataCell(Text(
                          monthCharge > 0
                              ? 'Rs: ${monthCharge.toStringAsFixed(2)}'
                              : "-",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
                  const SizedBox(height: 24),
                  const Text('Enter this month\'s current meter:',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: meterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Current Meter value',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F5BD5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final meterValue = meterController.text;
                        if (meterValue.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please enter the current meter value')),
                          );
                          return;
                        }
                        final enteredValue = double.tryParse(meterValue);
                        if (enteredValue == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter a valid number')),
                          );
                          return;
                        }
                        if (previousMeter != null &&
                            enteredValue < previousMeter!) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Invalid Value'),
                              content: const Text(
                                  'Current meter value cannot be less than previous meter value.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        showLoadingDialog(context);
                        try {
                          final url = Uri.parse(
                              'https://waterboard-api.vercel.app/submit-meter');
                          final response = await http.post(
                            url,
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'customerId': widget.customerId,
                              'currentMeter': meterValue,
                            }),
                          );
                          Navigator.pop(context); // Hide loading dialog
                          final data = jsonDecode(response.body);
                          if (data['success']) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(data['message'] ?? 'Success!')),
                            );
                            meterController.clear();
                            fetchMeterDetails();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed: ${data['error'] ?? 'Unknown error'}')),
                            );
                          }
                        } catch (e) {
                          Navigator.pop(context); // Hide loading dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Cannot connect to server. Please try again later.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (currentMeter != null && currentMeter! > 0) ...[
                    const SizedBox(height: 12), // Add some space
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BillPage(
                                customerId: widget.customerId,
                                name: widget.name,
                                date: formattedDate,
                                previousMeter: previousMeter,
                                currentMeter: currentMeter,
                                outstanding: outstanding,
                                monthCharge: monthCharge,
                                totalAmount: (outstanding ?? 0) +
                                    200 +
                                    monthCharge, // <-- updated calculation
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Show Bill',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
