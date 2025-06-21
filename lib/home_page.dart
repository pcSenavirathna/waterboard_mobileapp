import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool loading = true;

  final TextEditingController meterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMeterDetails();
  }

  Future<void> fetchMeterDetails() async {
    setState(() => loading = true);
    final url =
        Uri.parse(
        'https://waterboard-api.vercel.app/meter-details/${widget.customerId}');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null) {
        setState(() {
          previousMeter = (data['data']['previous_meter'] as num?)?.toDouble();
          currentMeter = (data['data']['current_meter'] as num?)?.toDouble();
        });
      } else {
        setState(() {
          previousMeter = null;
          currentMeter = null;
        });
      }
    } catch (e) {
      setState(() {
        previousMeter = null;
        currentMeter = null;
      });
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy/MM/dd').format(now);

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer ID: ${widget.customerId}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Name: ${widget.name}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Date: $formattedDate', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            loading
                ? const CircularProgressIndicator()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Previous Meter: ${previousMeter?.toString() ?? "-"}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current Meter: ${currentMeter?.toString() ?? "-"}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
            const Text('Enter this month\'s current meter:', style: TextStyle(fontSize: 18)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final meterValue = meterController.text;
                  if (meterValue.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please enter the current meter value')),
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
                  if (previousMeter != null && enteredValue < previousMeter!) {
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
                    final data = jsonDecode(response.body);
                    if (data['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(data['message'] ?? 'Success!')),
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
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}